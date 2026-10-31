"""QA fixtures: register fictional companies via the real /companies/register endpoint, approve via the real admin API.
Run once on a clean DB (reset.sh restores a snapshot that already contains them)."""
import http.cookiejar, json, os, re, subprocess, urllib.error, urllib.parse, urllib.request
import vk7env as V

BASE = V.BASE
HERE = os.path.dirname(os.path.abspath(__file__))
PASSWORD = V.required("QA_PASSWORD")
COMPANIES = [  # (email local part, first, last, business, phone, approve)
    ("qa.alpha", "Asha", "Alpha", "QA Retail Alpha", "9100000001", True),
    ("qa.beta", "Bala", "Beta", "QA Retail Beta", "9100000002", True),
    ("qa.gamma", "Gita", "Gamma", "QA Retail Gamma", "9100000003", True),
    ("qa.delta", "Dev", "Delta", "QA Retail Delta", "9100000004", True),
    ("qa.epsilon", "Esha", "Epsilon", "QA Retail Epsilon", "9100000005", True),
    ("qa.zeta", "Zoya", "Zeta", "QA Retail Zeta", "9100000006", True),
    ("qa.pending", "Pia", "Pending", "QA Retail Pending", "9100000009", False),
]


def sql(q):
    out = subprocess.run([os.path.join(HERE, "q.sh"), q], capture_output=True, text=True).stdout.strip().splitlines()
    head = out[0].split("\t") if out else []
    return [dict(zip(head, r.split("\t"))) for r in out[1:]]


class Session:
    def __init__(self):
        self.jar = http.cookiejar.CookieJar()
        self.op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.jar))

    def token(self, path):
        return re.search(r'name="_token" value="([^"]+)"', self.op.open(BASE + path).read().decode()).group(1)

    def post(self, path, data, as_json=False):
        headers = {"Accept": "application/json" if as_json else "text/html"}
        xsrf = next((c.value for c in self.jar if c.name == "XSRF-TOKEN"), None)
        if xsrf:
            headers["X-XSRF-TOKEN"] = urllib.parse.unquote(xsrf)
        body = json.dumps(data).encode() if as_json else urllib.parse.urlencode(data).encode()
        headers["Content-Type"] = "application/json" if as_json else "application/x-www-form-urlencoded"
        try:
            with self.op.open(urllib.request.Request(BASE + path, data=body, method="POST", headers=headers)) as r:
                return r.status, r.geturl().replace(BASE, "")
        except urllib.error.HTTPError as e:
            return e.code, path


def main():
    for local, first, last, business, phone, _ in COMPANIES:
        s = Session()
        tok = s.token("/customer/register")
        code, url = s.post("/companies/register", {"_token": tok, "first_name": first, "last_name": last, "email": f"{local}@example.test",
                                                   "phone": phone, "business_name": business, "password": PASSWORD, "password_confirmation": PASSWORD})
        print(f"registered {local:12} -> http {code}")
    admin = Session()
    admin.post("/admin/login", {"_token": admin.token("/admin/login"), "email": V.cred("QA_ADMIN_EMAIL", "admin-email.txt"), "password": V.cred("QA_ADMIN_PASSWORD", "admin-password.txt")})
    for local, *_, approve in COMPANIES:
        if approve:
            cid = sql(f"select id from customers where email='{local}@example.test'")[0]["id"]
            code, _ = admin.post(f"/admin/b2b/companies/{cid}/status", {"status": 1}, as_json=True)
            print(f"approved   {local:12} (customer {cid}) -> http {code}")
    for r in sql("select c.id, c.email, c.type, c.status, (select count(*) from b2b_customer_companies cc where cc.customer_id=c.id) company_link, "
                 "(select count(*) from b2b_company_roles r where r.customer_id=c.id) roles from customers c order by c.id"):
        print(r)


if __name__ == "__main__":
    main()
