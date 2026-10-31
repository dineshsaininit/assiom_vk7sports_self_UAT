"""Sandbox admin 2FA test over real HTTP. Secrets/backup codes go to .secrets/ (0600) and are never printed.

  python3 tests/admin_2fa.py enable   -> T1-T4  (enable 2FA on the owner admin)
  python3 tests/admin_2fa.py login    -> T5-T14 (enforcement, wrong/right/replayed codes, backup code, logout, remember-me)
"""
import base64, hashlib, hmac, http.cookiejar, json, os, re, struct, sys, time, urllib.error, urllib.parse, urllib.request
import vk7env as V

B = V.BASE
SEC = V.SECRETS_DIR
EMAIL = V.cred("QA_ADMIN_EMAIL", "admin-email.txt")
PASSWORD = V.cred("QA_ADMIN_PASSWORD", "admin-password.txt")
results = []


def check(name, ok, detail=""):
    results.append(ok)
    print(f"{'PASS' if ok else 'FAIL'}  {name}" + (f"  [{detail}]" if detail else ""))


def secret_file(name, data=None):
    path = os.path.join(SEC, name)
    if data is not None:
        with open(os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600), "w") as f:
            f.write(data)
    return open(path).read().strip()


def totp(secret, offset=0):
    key = base64.b32decode(secret.upper() + "=" * (-len(secret) % 8))
    counter = int(time.time()) // 30 + offset
    h = hmac.new(key, struct.pack(">Q", counter), hashlib.sha1).digest()
    o = h[-1] & 0x0F
    return str((struct.unpack(">I", h[o:o + 4])[0] & 0x7FFFFFFF) % 1000000).zfill(6)


def wait_next_window():
    time.sleep(31 - int(time.time()) % 30)


class Session:
    def __init__(self):
        self.jar = http.cookiejar.CookieJar()
        self.op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.jar))

    def cookie(self, name):
        return next((c.value for c in self.jar if c.name == name), None)

    def req(self, method, path, data=None, json_body=False, accept="text/html"):
        headers = {"Accept": accept}
        if self.cookie("XSRF-TOKEN"):
            headers["X-XSRF-TOKEN"] = urllib.parse.unquote(self.cookie("XSRF-TOKEN"))
        body = None
        if data is not None:
            body = json.dumps(data).encode() if json_body else urllib.parse.urlencode(data).encode()
            headers["Content-Type"] = "application/json" if json_body else "application/x-www-form-urlencoded"
        try:
            with self.op.open(urllib.request.Request(B + path, data=body, method=method, headers=headers)) as r:
                return r.status, r.geturl().replace(B, ""), r.read().decode()
        except urllib.error.HTTPError as e:
            return e.code, path, e.read().decode()

    def token(self, path):
        _, _, html = self.req("GET", path)
        m = re.search(r'name="_token" value="([^"]+)"', html)
        return m.group(1) if m else None

    def login(self, remember=False):
        data = {"_token": self.token("/admin/login"), "email": EMAIL, "password": PASSWORD}
        if remember:
            data["remember"] = "1"
        return self.req("POST", "/admin/login", data)

    def verify(self, code):
        return self.req("POST", "/admin/two-factor/verify", {"_token": self.token("/admin/two-factor/verify"), "code": code})


def enable():
    s = Session()
    s.req("GET", "/admin/login")
    before = s.cookie("bagisto_session")
    code, url, _ = s.login()
    check("T1 password login reaches dashboard (2FA not yet on)", url.startswith("/admin/dashboard"), url)
    check("T1b session id regenerated on login (no fixation)", before and s.cookie("bagisto_session") != before)
    code, _, body = s.req("GET", "/admin/two-factor/setup", accept="application/json")
    m = re.search(r"secret=([A-Z2-7]+)", urllib.parse.unquote(body))
    check("T2 setup returns provisioning data", code == 200 and bool(m), f"http {code}, secret received: {'yes' if m else 'no'} (not printed)")
    secret = secret_file("admin-totp-secret.txt", m.group(1))
    code, _, body = s.req("POST", "/admin/two-factor/enable", {"code": str((int(totp(secret)) + 1) % 1000000).zfill(6)}, True, "application/json")
    check("T3 enable with WRONG code rejected", code == 422, f"http {code}")
    code, _, body = s.req("POST", "/admin/two-factor/enable", {"code": totp(secret)}, True, "application/json")
    codes = json.loads(body).get("backup_codes", []) if code == 200 else []
    if codes:
        secret_file("admin-backup-codes.txt", "\n".join(codes))
    check("T4 enable with CORRECT code accepted", code == 200 and len(codes) == 8, f"http {code}, {len(codes)} backup codes stored in .secrets (not printed)")


def login_tests():
    secret = secret_file("admin-totp-secret.txt")
    pending = Session()
    _, url, _ = pending.login()
    check("T5 password-only login is held at 2FA verify", "two-factor/verify" in url, url)
    gated = []
    for p in ["/admin/dashboard", "/admin/sales/orders", "/admin/settings/users", "/admin/b2b/companies", "/admin/configuration/vk7/moq", "/admin/account"]:
        _, u, _ = pending.req("GET", p)
        gated.append((p, u))
    check("T6 every admin page redirects to verify before code", all("two-factor/verify" in u for _, u in gated), "; ".join(f"{p}->{u}" for p, u in gated))
    c1, _, _ = pending.req("GET", "/admin/two-factor/setup", accept="application/json")
    c2, u2, _ = pending.req("POST", "/admin/two-factor/disable", {}, True, "application/json")
    check("T6b cannot read setup secret or disable 2FA before code", c1 == 401 and ("two-factor/verify" in u2 or c2 in (401, 403, 419)), f"setup http {c1}; disable -> {c2} {u2}")
    _, url, html = pending.verify(str((int(totp(secret)) + 3) % 1000000).zfill(6))
    _, u, _ = pending.req("GET", "/admin/dashboard")
    check("T7 WRONG code rejected, session still gated", "two-factor/verify" in u, f"after wrong code dashboard -> {u}")
    wait_next_window()
    good = totp(secret)
    _, url, _ = pending.verify(good)
    _, u, _ = pending.req("GET", "/admin/dashboard")
    check("T8 CORRECT code accepted, dashboard reachable", u.startswith("/admin/dashboard"), u)
    replay = Session()
    replay.login()
    replay.verify(good)
    _, u, _ = replay.req("GET", "/admin/dashboard")
    check("T9 replayed (already used) code rejected in new session", "two-factor/verify" in u, u)
    backup = secret_file("admin-backup-codes.txt").splitlines()
    b1 = Session()
    b1.login()
    b1.verify(backup[0])
    _, u, _ = b1.req("GET", "/admin/dashboard")
    check("T10 backup code accepted once", u.startswith("/admin/dashboard"), u)
    b2 = Session()
    b2.login()
    b2.verify(backup[0])
    _, u, _ = b2.req("GET", "/admin/dashboard")
    check("T11 same backup code rejected on reuse", "two-factor/verify" in u, u)
    secret_file("admin-backup-codes.txt", "\n".join(backup[1:]))
    tok = pending.token("/admin/dashboard")
    pending.req("POST", "/admin/logout", {"_token": tok, "_method": "DELETE"})
    _, u, _ = pending.req("GET", "/admin/dashboard")
    check("T12 after logout the old session cannot reach admin", "/admin/login" in u, u)
    r = Session()
    r.login(remember=True)
    wait_next_window()
    r.verify(totp(secret))
    remember_cookie = next((c for c in r.jar if c.name.startswith("remember_admin")), None)
    for c in list(r.jar):
        if c.name == "bagisto_session":
            r.jar.clear(c.domain, c.path, c.name)
    _, u, _ = r.req("GET", "/admin/dashboard")
    check("T13 remember-me cookie alone does not skip 2FA", "two-factor/verify" in u or "/admin/login" in u,
          f"remember cookie set: {'yes' if remember_cookie else 'no'}; fresh session -> {u}")
    flood = Session()
    flood.login()
    codes = [flood.verify("000000")[0] for _ in range(7)]
    check("T14 brute force of verify endpoint throttled (429)", 429 in codes, f"status codes: {codes}")


if __name__ == "__main__" and sys.argv[1] in ("enable", "login"):
    {"enable": enable, "login": login_tests}[sys.argv[1]]()
    print(f"== {sum(results)}/{len(results)} passed")


def backup_test():
    codes = secret_file("admin-backup-codes.txt").splitlines()
    first = Session()
    first.login()
    status, _, _ = first.verify(codes[0])
    _, u, _ = first.req("GET", "/admin/dashboard")
    check("T10 backup code accepted once", u.startswith("/admin/dashboard"), f"verify http {status}; dashboard -> {u}")
    again = Session()
    again.login()
    status, _, _ = again.verify(codes[0])
    _, u, _ = again.req("GET", "/admin/dashboard")
    check("T11 same backup code rejected on reuse", "two-factor/verify" in u, f"verify http {status}; dashboard -> {u}")
    secret_file("admin-backup-codes.txt", "\n".join(codes[1:]))
    print(f"== {sum(results)}/{len(results)} passed")


if __name__ == "__main__" and sys.argv[1] == "backup":
    backup_test()


def enforce_test():
    staff, staff_pw = V.required("QA_STAFF_EMAIL"), V.required("QA_STAFF_PASSWORD")

    def staff_login(s):
        return s.req("POST", "/admin/login", {"_token": s.token("/admin/login"), "email": staff, "password": staff_pw})

    s = Session()
    _, url, _ = staff_login(s)
    probes = {p: s.req("GET", p)[1] for p in ["/admin/dashboard", "/admin/sales/orders", "/admin/sales/orders/view/1"]}
    check("E1 enforced: staff without 2FA is sent to enrol, not to work pages",
          all(u.startswith("/admin/account") for u in probes.values()), f"login -> {url}; " + "; ".join(f"{p}->{u}" for p, u in probes.items()))
    code, _, _ = s.req("GET", "/admin/account")
    check("E1b account (enrolment) page reachable", code == 200, f"http {code}")
    code, _, body = s.req("GET", "/admin/two-factor/setup", accept="application/json")
    secret = secret_file("staff-totp-secret.txt", re.search(r"secret=([A-Z2-7]+)", urllib.parse.unquote(body)).group(1))
    code, _, body = s.req("POST", "/admin/two-factor/enable", {"code": totp(secret)}, True, "application/json")
    if code == 200:
        secret_file("staff-backup-codes.txt", "\n".join(json.loads(body)["backup_codes"]))
    _, u, _ = s.req("GET", "/admin/sales/orders")
    check("E2 staff enrols (setup + enable) and can then work", code == 200 and u.startswith("/admin/sales/orders"), f"enable http {code}; orders -> {u}")
    s2 = Session()
    _, url, _ = staff_login(s2)
    _, u, _ = s2.req("GET", "/admin/sales/orders")
    check("E3 next staff login needs a code (password alone blocked)", "two-factor/verify" in u, f"login -> {url}; orders -> {u}")
    wait_next_window()
    s2.verify(totp(secret))
    _, u, _ = s2.req("GET", "/admin/sales/orders")
    check("E3b staff with correct code reaches orders", u.startswith("/admin/sales/orders"), u)
    o = Session()
    o.login()
    o.verify(totp(secret_file("admin-totp-secret.txt")))
    _, u, _ = o.req("GET", "/admin/dashboard")
    check("E4 owner admin (already enrolled) unaffected", u.startswith("/admin/dashboard"), u)
    print(f"== {sum(results)}/{len(results)} passed")


if __name__ == "__main__" and sys.argv[1] == "enforce":
    enforce_test()
