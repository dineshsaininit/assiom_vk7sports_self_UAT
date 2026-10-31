"""Sandbox check: N wrong-password logins against admin and customer forms; report status codes (429 = throttled)."""
import http.cookiejar, re, sys, urllib.parse, urllib.request, urllib.error
import vk7env as V
B = V.BASE
def attempts(login_path, email, n=12):
    jar = http.cookiejar.CookieJar()
    op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar), urllib.request.HTTPRedirectHandler())
    codes = []
    for i in range(n):
        html = op.open(B + login_path).read().decode()
        tok = re.search(r'name="_token" value="([^"]+)"', html).group(1)
        data = urllib.parse.urlencode({"_token": tok, "email": email, "password": f"wrong-{i}"}).encode()
        req = urllib.request.Request(B + login_path, data=data, method="POST")
        try:
            with op.open(req) as r:
                body = r.read().decode()
                codes.append(f"{r.status}{'(locked-msg)' if re.search(r'too many|try again in', body, re.I) else ''}")
        except urllib.error.HTTPError as e:
            codes.append(str(e.code))
    return codes
print("admin    /admin/login   :", " ".join(attempts("/admin/login", V.required("QA_STAFF_EMAIL"))))
print("customer /customer/login:", " ".join(attempts("/customer/login", V.env("QA_RETAILER_EMAIL", "qa.alpha@example.test"))))
