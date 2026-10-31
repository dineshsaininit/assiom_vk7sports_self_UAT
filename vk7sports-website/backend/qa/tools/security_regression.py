"""Security regression over real HTTP (fictional accounts). Secrets stay in .secrets/ and are never printed."""
import json, os, re, sys, time, urllib.error, urllib.parse, urllib.request
sys.path.insert(0, os.path.dirname(__file__))
import admin_2fa as A
import order_driver as D
import vk7env as V
from e2e_workflow import sql

B = D.BASE
results = []


def check(area, name, ok, detail=""):
    results.append(ok)
    print(f"{'PASS' if ok else 'FAIL'}  {area} {name}" + (f"  [{detail}]" if detail else ""))


class _NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *a, **k):
        return None


def raw(method, path, data=None, headers=None):
    opener = urllib.request.build_opener(_NoRedirect)
    req = urllib.request.Request(B + path, data=urllib.parse.urlencode(data or {}).encode() if method != "GET" else None,
                                 method=method, headers=headers or {})
    try:
        with opener.open(req) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code


def customer(email, password):
    s = D.Buyer(email.split("@")[0])
    html = s.opener.open(B + "/customer/login").read().decode()
    s._req("POST", "/customer/login", {"_token": re.search(r'name="_token" value="([^"]+)"', html).group(1), "email": email, "password": password}, form=True)
    return s


def final_url(s, path):
    try:
        return s.opener.open(B + path).geturl().replace(B, "")
    except urllib.error.HTTPError as e:
        return f"HTTP {e.code}"


def staff_session():
    staff, pw = V.required("QA_STAFF_EMAIL"), V.required("QA_STAFF_PASSWORD")
    s = A.Session()
    s.req("POST", "/admin/login", {"_token": s.token("/admin/login"), "email": staff, "password": pw})
    if sql("select two_factor_enabled from admins where email='" + staff + "'")[0]["two_factor_enabled"] == "0":
        _, _, body = s.req("GET", "/admin/two-factor/setup", accept="application/json")
        secret = A.secret_file("staff-totp-secret.txt", re.search(r"secret=([A-Z2-7]+)", urllib.parse.unquote(body)).group(1))
        s.req("POST", "/admin/two-factor/enable", {"code": A.totp(secret)}, True, "application/json")
    else:
        A.wait_next_window()
        s.verify(A.totp(A.secret_file("staff-totp-secret.txt")))
    return s


def csrf():
    for p in ["/customer/login", "/admin/login", "/companies/register", "/customer/register", "/api/checkout/cart",
              "/api/checkout/onepage/orders", "/customer/account/quotes", "/admin/sales/invoices/create/1"]:
        code = raw("POST", p, {"x": "1"}, {"Accept": "application/json"})
        check("CSRF", f"POST {p} without token rejected", code == 419, f"http {code}")
    a = D.Buyer("csrf-a")
    a.opener.open(B + "/customer/login")
    foreign = urllib.parse.unquote(next(c.value for c in a.jar if c.name == "XSRF-TOKEN"))
    code = raw("POST", "/api/checkout/cart", {"product_id": 144}, {"Accept": "application/json", "X-XSRF-TOKEN": foreign})
    check("CSRF", "token from another session rejected", code == 419, f"http {code}")


def authn():
    g = D.Buyer("guest")
    for p in ["/customer/account/orders", "/customer/account/quotes", "/customer/account/company-profile"]:
        u = final_url(g, p)
        check("AUTHN", f"guest {p} -> login", u.startswith("/customer/login"), u)
    for p in ["/admin/dashboard", "/admin/sales/orders", "/admin/configuration/vk7/security"]:
        u = final_url(g, p)
        check("AUTHN", f"guest {p} -> admin login", u.startswith("/admin/login"), u)
    code = raw("GET", "/admin/sales/orders", headers={"Accept": "application/json", "X-Requested-With": "XMLHttpRequest"})
    check("AUTHN", "guest admin JSON request refused", code in (401, 302), f"http {code}")
    c = customer(V.env("QA_RETAILER_EMAIL", "qa.alpha@example.test"), V.required("QA_PASSWORD"))
    u = final_url(c, "/admin/dashboard")
    check("AUTHN", "logged-in retailer cannot use admin (separate guard)", u.startswith("/admin/login"), u)
    w = customer(V.env("QA_RETAILER_EMAIL", "qa.alpha@example.test"), "wrong-password")
    u = final_url(w, "/customer/account/orders")
    check("AUTHN", "wrong retailer password does not log in", u.startswith("/customer/login"), u)


def authz():
    s = staff_session()
    code, u, _ = s.req("GET", "/admin/sales/orders")
    check("AUTHZ", "staff (view orders) can open orders", code == 200 and u.startswith("/admin/sales/orders"), f"{code} {u}")
    for p in ["/admin/catalog/products", "/admin/settings/users", "/admin/b2b/companies", "/admin/b2b/quotes",
              "/admin/configuration/vk7/moq", "/admin/configuration/sales/order_settings", "/admin/customers"]:
        code, u, _ = s.req("GET", p)
        check("AUTHZ", f"staff denied {p}", code in (401, 403), f"http {code}")
    target = sql("select id,status from customers where type='company' order by id desc limit 1")[0]
    tok = s.token("/admin/sales/orders")
    code, _, _ = s.req("POST", f"/admin/b2b/companies/{target['id']}/status", {"status": 0}, True, "application/json")
    after = sql(f"select status from customers where id={target['id']}")[0]["status"]
    check("AUTHZ", "staff cannot approve/disable companies", code in (401, 403) and after == target["status"], f"http {code}")
    pend = sql("select id from orders where status='pending' order by id desc limit 1")[0]["id"]
    n0 = len(sql(f"select id from invoices where order_id={pend}"))
    code, _, _ = s.req("POST", f"/admin/sales/invoices/create/{pend}", {"_token": tok})
    check("AUTHZ", "staff cannot create invoices", code in (401, 403) and len(sql(f"select id from invoices where order_id={pend}")) == n0, f"http {code}")
    q = sql("select id,status from b2b_customer_quotes order by id desc limit 1")[0]
    code, _, _ = s.req("POST", f"/admin/b2b/quotes/{q['id']}/accept-quote", {"message": "x"}, True, "application/json")
    check("AUTHZ", "staff cannot accept quotes", code in (401, 403) and sql(f"select status from b2b_customer_quotes where id={q['id']}")[0]["status"] == q["status"], f"http {code}")
    sql("update admins set status=0 where email='" + V.required("QA_STAFF_EMAIL") + "'")
    _, u, _ = s.req("GET", "/admin/sales/orders")
    sql("update admins set status=1 where email='" + V.required("QA_STAFF_EMAIL") + "'")
    check("AUTHZ", "deactivated admin is logged out on next request", u.startswith("/admin/login"), u)


def isolation():
    ravi = sql("select id from customers where email='" + V.env("QA_RETAILER_EMAIL", "qa.alpha@example.test") + "'")[0]["id"]
    other = sql("select c.id,c.email from customers c join b2b_customer_quotes q on q.customer_id=c.id where c.id<>" + ravi + " order by q.id desc limit 1")[0]
    pairs = [("ravi", customer(V.env("QA_RETAILER_EMAIL", "qa.alpha@example.test"), V.required("QA_PASSWORD")), other["id"]),
             ("other", customer(other["email"], V.required("QA_PASSWORD")), ravi)]
    for who, s, victim in pairs:
        o = sql(f"select id,status from orders where customer_id={victim} order by id limit 1")[0]
        inv = sql(f"select id from invoices where order_id in (select id from orders where customer_id={victim}) limit 1")
        q = sql(f"select id,status,quotation_number,customer_email from b2b_customer_quotes where customer_id={victim} order by id limit 1")[0]
        marks = [q["quotation_number"], q["customer_email"], f"Order #{o['id']}"]
        msgs0 = len(sql(f"select id from b2b_customer_quote_messages where quote_id={q['id']}"))
        reads = {f"orders/view/{o['id']}": f"/customer/account/orders/view/{o['id']}",
                 f"quotes/{q['id']}": f"/customer/account/quotes/{q['id']}",
                 f"quotes/{q['id']}/messages": f"/customer/account/quotes/{q['id']}/messages"}
        if inv:
            reads[f"invoice print {inv[0]['id']}"] = f"/customer/account/orders/print/Invoice/{inv[0]['id']}"
        for label, p in reads.items():
            code, body = s._req("GET", p)
            leaked = [m for m in marks if m in body]
            check("ISOLATION", f"{who} cannot read victim {label}", code in (401, 403, 404) or not leaked,
                  f"http {code}; final {final_url(s, p)}; victim data present: {leaked or 'none'}")
        s._req("POST", f"/customer/account/orders/cancel/{o['id']}", {})
        s._req("POST", f"/customer/account/quotes/{q['id']}/send-message", {"message": "intrusion"})
        s._req("POST", f"/customer/account/quotes/{q['id']}/reject-quote", {})
        s._req("PUT", f"/customer/account/quotes/{q['id']}", {})
        ok = (sql(f"select status from orders where id={o['id']}")[0]["status"] == o["status"]
              and sql(f"select status from b2b_customer_quotes where id={q['id']}")[0]["status"] == q["status"]
              and len(sql(f"select id from b2b_customer_quote_messages where quote_id={q['id']}")) == msgs0)
        check("ISOLATION", f"{who} cannot cancel/reject/message/accept victim's order & quote", ok)


if __name__ == "__main__":
    for part in sys.argv[1:]:
        {"csrf": csrf, "authn": authn, "authz": authz, "isolation": isolation}[part]()
    print(f"== {sum(results)}/{len(results)} passed")
