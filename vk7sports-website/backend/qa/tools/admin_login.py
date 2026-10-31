"""Sandbox: admin login over HTTP. admin_login.py EMAIL PASSWORD_FILE|- -> prints OK/REJECTED (password never printed)."""
import http.cookiejar, re, sys, urllib.parse, urllib.request
import vk7env as V
B = V.BASE
def login(email, password):
    op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
    tok = re.search(r'name="_token" value="([^"]+)"', op.open(B + "/admin/login").read().decode()).group(1)
    r = op.open(urllib.request.Request(B + "/admin/login", method="POST",
        data=urllib.parse.urlencode({"_token": tok, "email": email, "password": password}).encode()))
    return op, r.geturl()
if __name__ == "__main__":
    email, src = sys.argv[1], sys.argv[2]
    pw = open(src).read().strip() if src != "-" else sys.argv[3]
    _, url = login(email, pw)
    print("OK -> " + url.replace(B, "") if "/admin/dashboard" in url or "two-factor" in url else "REJECTED -> " + url.replace(B, ""))
