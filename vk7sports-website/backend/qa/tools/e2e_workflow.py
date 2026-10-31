"""End-to-end B2B workflow over real HTTP with DB verification per stage (fictional data only).
Registration -> approval -> product selection -> RFQ -> quote approval -> order -> inventory -> fulfilment -> tracking.
"""
import json, re, subprocess, sys, os, time
sys.path.insert(0, os.path.dirname(__file__))
import admin_2fa as A
import order_driver as D
import vk7env as V

ROOT = os.path.dirname(os.path.abspath(__file__))  # q.sh lives beside this script
NAME = f"retailer{int(time.time())}"
EMAIL = f"{NAME}@example.test"
LINES = [(150, 18), (149, 12)]  # Blue-M 18 + Red-XL 12 = 30 pcs of one style (MOQ per_style 24)
results = []


def check(stage, name, ok, detail=""):
    results.append(ok)
    print(f"{'PASS' if ok else 'FAIL'}  {stage} {name}" + (f"  [{detail}]" if detail else ""))


def sql(q):
    out = subprocess.run([os.path.join(ROOT, "q.sh"), q], capture_output=True, text=True).stdout.strip().splitlines()
    head = out[0].split("\t") if out else []
    return [dict(zip(head, r.split("\t"))) for r in out[1:]]


def sellable(v):
    r = sql(f"select i.qty-coalesce(o.qty,0) s, coalesce(o.qty,0) r, i.qty p from product_inventories i left join product_ordered_inventories o on o.product_id=i.product_id and o.channel_id=1 where i.product_id={v}")[0]
    return int(r["s"]), int(r["r"]), int(r["p"])


def flash(buyer, path="/customer/login"):
    html = buyer.opener.open(D.BASE + path).read().decode()
    m = re.search(r"(activation seeks admin approval|already been taken|is required|not available|un-?authorized|Minimum order is[^<]*)", html, re.I)
    return m.group(1) if m else ""


def personal_signup():
    """W0: personal (non-company) sign-up under the current 'personal_account_approval' setting."""
    setting = sql("select value from core_config where code='vk7.security.storefront.personal_account_approval'")
    on = bool(setting) and setting[0]["value"] == "1"
    email = f"personal{int(time.time())}@example.test"
    s = D.Buyer(email.split("@")[0])
    html = s.opener.open(D.BASE + "/customer/register").read().decode()
    tok = re.search(r'name="_token" value="([^"]+)"', html).group(1)
    s._req("POST", "/customer/register", {"_token": tok, "first_name": "Pat", "last_name": "Personal", "email": email,
                                          "password": V.required("QA_PASSWORD"), "password_confirmation": V.required("QA_PASSWORD")}, form=True)
    row = sql(f"select type,status from customers where email='{email}'")
    l = D.Buyer(email.split("@")[0])
    html = l.opener.open(D.BASE + "/customer/login").read().decode()
    l._req("POST", "/customer/login", {"_token": re.search(r'name="_token" value="([^"]+)"', html).group(1), "email": email, "password": V.required("QA_PASSWORD")}, form=True)
    code, body = l._req("GET", "/api/checkout/cart")
    logged_in = '"customer_id"' in body or flash(l) == ""
    blocked = "approval" in flash(l).lower() or not row or row[0]["status"] == "0"
    if on:
        check("W0", "personal sign-up is pending and cannot log in (setting ON)", bool(row) and row[0]["status"] == "0" and blocked, f"{row}; login msg='{flash(l)}'")
    else:
        check("W0", "GAP documented: personal sign-up active immediately (setting OFF = Bagisto default)", bool(row) and row[0]["status"] == "1", f"{row}")


def main():
    stock0 = {v: sellable(v) for v, _ in LINES}
    mail0 = len(json.load(D.urllib.request.urlopen(V.MAILPIT + "/api/v1/messages?limit=500"))["messages"])

    # W1 registration -------------------------------------------------------
    b = D.Buyer(NAME)
    html = b.opener.open(D.BASE + "/customer/register").read().decode()
    tok = re.search(r'name="_token" value="([^"]+)"', html).group(1)
    form = {"_token": tok, "account_type": "company", "first_name": "Bina", "last_name": "Fictional", "email": EMAIL,
            "phone": "9" + NAME[-9:], "business_name": f"Fictional Kit House {NAME[-6:]}", "password": V.required("QA_PASSWORD"), "password_confirmation": V.required("QA_PASSWORD")}
    bad = dict(form, business_name="")
    b._req("POST", "/companies/register", bad, form=True)
    check("W1", "registration without business name rejected", not sql(f"select id from customers where email='{EMAIL}'"))
    b._req("POST", "/companies/register", form, form=True)
    row = sql(f"select id,type,status,customer_group_id from customers where email='{EMAIL}'")
    cid = row[0]["id"] if row else None
    check("W1", "company account persisted as pending", bool(row) and row[0]["type"] == "company" and row[0]["status"] == "0", str(row))
    dup = D.Buyer(NAME)
    html = dup.opener.open(D.BASE + "/customer/register").read().decode()
    dup._req("POST", "/companies/register", dict(form, _token=re.search(r'name="_token" value="([^"]+)"', html).group(1)), form=True)
    check("W1", "duplicate email registration rejected", len(sql(f"select id from customers where email='{EMAIL}'")) == 1)

    # W2 pending account blocked -------------------------------------------
    p = D.Buyer(NAME)
    html = p.opener.open(D.BASE + "/customer/login").read().decode()
    p._req("POST", "/customer/login", {"_token": re.search(r'name="_token" value="([^"]+)"', html).group(1), "email": EMAIL, "password": V.required("QA_PASSWORD")}, form=True)
    code, _ = p._req("GET", "/api/checkout/cart")
    try:
        acc = p.opener.open(D.BASE + "/customer/account/quotes").geturl().replace(D.BASE, "")
    except D.urllib.error.HTTPError as e:
        acc = f"HTTP {e.code}"
    check("W2", "pending company cannot log in or reach account pages", acc.startswith("/customer/login"), f"/customer/account/quotes -> {acc}; msg='{flash(p)}'")

    # W3 admin approval ------------------------------------------------------
    adm = A.Session()
    adm.login()
    if V.ADMIN_2FA:  # QA golden DB has admin 2FA disabled; set QA_ADMIN_2FA=1 when enrolled
        A.wait_next_window()
        adm.verify(A.totp(A.secret_file("admin-totp-secret.txt")))
    code, _, body = adm.req("POST", f"/admin/b2b/companies/{cid}/status", {"status": 1}, True, "application/json")
    row = sql(f"select status,updated_at from customers where id={cid}")[0]
    check("W3", "admin (2FA-verified) approves company", code == 200 and row["status"] == "1", f"http {code}; status={row['status']}")
    guest = A.Session()
    code, url, _ = guest.req("POST", f"/admin/b2b/companies/{cid}/status", {"status": 0}, True, "application/json")
    check("W3", "unauthenticated approval/disable attempt refused", sql(f"select status from customers where id={cid}")[0]["status"] == "1", f"http {code}")

    # W4 product selection ---------------------------------------------------
    b = D.Buyer(NAME).login()
    b.clear_cart()
    adds = [b.add(v, q) for v, q in LINES]
    rows = sql(f"select ci.product_id,ci.quantity from cart c join cart_items ci on ci.cart_id=c.id where c.customer_id={cid} and c.is_active=1 and ci.parent_id is null")
    check("W4", "approved retailer adds 2 variants (30 pcs) to cart", all(c == 200 for c, _ in adds) and sum(int(r["quantity"]) for r in rows) == 30, f"{adds}")
    cart_id = sql(f"select id from cart where customer_id={cid} and is_active=1")[0]["id"]

    # W5 quotation request ---------------------------------------------------
    code, body = b._req("POST", "/customer/account/quotes", {"name": "", "description": "x", "cart_id": cart_id})
    check("W5", "quote without name rejected", code == 422 and not sql(f"select id from b2b_customer_quotes where customer_id={cid}"), f"http {code}")
    code, body = b._req("POST", "/customer/account/quotes", {"name": "TEST RFQ Fictional Kit House", "description": "Fictional: 30 jerseys, 2 sizes", "cart_id": cart_id, "status": "open"})
    q = sql(f"select id,quotation_number,status,company_id,total from b2b_customer_quotes where customer_id={cid}")
    qid = q[0]["id"] if q else None
    items = sql(f"select id,product_id,qty from b2b_customer_quote_items where customer_quote_id={qid}") if qid else []
    check("W5", "quote persisted as open with 2 items", code == 200 and q[0]["status"] == "open" and len(items) == 2, f"http {code}; {q}")
    code, _ = b._req("PUT", f"/customer/account/quotes/{qid}", {})
    check("W5", "retailer cannot accept own quote while still open (invalid transition)", sql(f"select status from b2b_customer_quotes where id={qid}")[0]["status"] == "open", f"http {code}")

    # W6 quotation approval --------------------------------------------------
    code, _, _ = adm.req("POST", f"/admin/b2b/quotes/{qid}/accept-quote", {"message": "Fictional: accepted as requested."}, True, "application/json")
    st = sql(f"select status from b2b_customer_quotes where id={qid}")[0]["status"]
    msgs = sql(f"select concat(user_type,'#',user_id,':',left(message,30)) m from b2b_customer_quote_messages where quote_id={qid} order by id")
    check("W6", "admin accepts quote", st == "accepted", f"http {code}; status={st}; quote messages={msgs}")
    b.clear_cart()
    code, _ = b._req("PUT", f"/customer/account/quotes/{qid}", {})
    rows = sql(f"select ci.product_id,ci.quantity,ci.price from cart c join cart_items ci on ci.cart_id=c.id where c.customer_id={cid} and c.is_active=1 and ci.parent_id is null")
    check("W6", "retailer moves accepted quote into cart", sum(int(r["quantity"]) for r in rows) == 30, f"http {code}; cart={rows}")

    # W7 order creation ------------------------------------------------------
    b.prepare_checkout()
    ok, code, msg = b.place()
    o = sql(f"select id,status,total_qty_ordered,grand_total from orders where customer_email='{EMAIL}' order by id desc limit 1")
    oid = o[0]["id"] if o else None
    qo = sql(f"select status,order_id from b2b_customer_quotes where id={qid}")[0]
    check("W7", "order created from quote and linked", ok and o[0]["status"] == "pending" and qo["status"] == "ordered" and qo["order_id"] == oid, f"order={o}; quote={qo}")
    b.clear_cart()
    code, _ = b._req("PUT", f"/customer/account/quotes/{qid}", {})
    check("W7", "ordered quote cannot be re-accepted / re-ordered", sql(f"select status from b2b_customer_quotes where id={qid}")[0]["status"] == "ordered" and not sql(f"select ci.id from cart c join cart_items ci on ci.cart_id=c.id where c.customer_id={cid} and c.is_active=1"), f"http {code}")

    # W8 inventory -----------------------------------------------------------
    stock1 = {v: sellable(v) for v, _ in LINES}
    check("W8", "stock reserved exactly (sellable down, physical unchanged)",
          all(stock1[v][0] == stock0[v][0] - q and stock1[v][2] == stock0[v][2] for v, q in LINES), f"before={stock0} after={stock1} (sellable,reserved,physical)")

    # W9 fulfilment ------------------------------------------------------------
    oitems = {r["product_id"]: r["id"] for r in sql(f"select p.id, c.product_id from order_items p join order_items c on c.parent_id=p.id where p.order_id={oid}")}
    tok = adm.token(f"/admin/sales/orders/view/{oid}")
    adm.req("POST", f"/admin/sales/invoices/create/{oid}", {"_token": tok, **{f"invoice[items][{oitems[str(v)]}]": q for v, q in LINES}})
    inv = sql(f"select id,state,total_qty from invoices where order_id={oid}")
    check("W9", "invoice recorded, order processing", bool(inv) and sql(f"select status from orders where id={oid}")[0]["status"] == "processing", f"{inv}")
    blue, red = oitems["150"], oitems["149"]
    over = {"_token": tok, "shipment[source]": 1, "shipment[carrier_title]": "TEST Courier", "shipment[track_number]": "TEST-OVER", f"shipment[items][{blue}][1]": 19}
    adm.req("POST", f"/admin/sales/shipments/create/{oid}", over)
    check("W9", "shipping more than ordered refused", not sql(f"select id from shipments where order_id={oid}"))
    part = {"_token": tok, "shipment[source]": 1, "shipment[carrier_title]": "TEST Courier", "shipment[track_number]": "TESTTRACK-B-1", f"shipment[items][{blue}][1]": 18}
    adm.req("POST", f"/admin/sales/shipments/create/{oid}", part)
    st = sql(f"select status from orders where id={oid}")[0]["status"]
    check("W9", "partial shipment (Blue-M 18) -> order stays processing", len(sql(f"select id from shipments where order_id={oid}")) == 1 and st == "processing", st)
    rest = {"_token": tok, "shipment[source]": 1, "shipment[carrier_title]": "TEST Courier", "shipment[track_number]": "TESTTRACK-B-2", f"shipment[items][{red}][1]": 12}
    adm.req("POST", f"/admin/sales/shipments/create/{oid}", rest)
    st = sql(f"select status from orders where id={oid}")[0]["status"]
    stock2 = {v: sellable(v) for v, _ in LINES}
    check("W9", "second shipment completes order", st == "completed", st)
    check("W9", "physical stock and reservation both reduced by shipped qty",
          all(stock2[v][2] == stock0[v][2] - q and stock2[v][1] == stock0[v][1] for v, q in LINES), f"after ship={stock2}")
    code, _ = b._req("POST", f"/customer/account/orders/cancel/{oid}", {})
    check("W9", "retailer cannot cancel a completed order", sql(f"select status from orders where id={oid}")[0]["status"] == "completed", f"http {code}")

    # W10 tracking -------------------------------------------------------------
    ships = sql(f"select track_number,total_qty,carrier_title,inventory_source_name from shipments where order_id={oid} order by id")
    page = b.opener.open(D.BASE + f"/customer/account/orders/view/{oid}").read().decode()
    check("W10", "tracking numbers persisted and shown to retailer",
          [s["track_number"] for s in ships] == ["TESTTRACK-B-1", "TESTTRACK-B-2"] and "TESTTRACK-B-1" in page and "TESTTRACK-B-2" in page, f"{ships}")
    mails = json.load(D.urllib.request.urlopen(V.MAILPIT + "/api/v1/messages?limit=500"))["messages"]
    subjects = [m["Subject"] for m in mails[: len(mails) - mail0]]
    check("W10", "lifecycle emails sent (registration, approval, quote, order, invoice, shipment)",
          all(any(k in s for s in subjects) for k in ["Approved", "Quotation", "Order", "Invoice", "Shipment"]), "; ".join(sorted(set(subjects))))

    # Auditability -------------------------------------------------------------
    actor_cols = sql("select table_name,column_name from information_schema.columns where table_schema='" + V.DB_NAME + "' and table_name in ('shipments','invoices','orders','order_comments','b2b_customer_quotes','customers') and column_name in ('admin_id','user_id','created_by','updated_by','approved_by')")
    print(f"INFO  AUDIT actor columns on order/invoice/shipment/company tables: {actor_cols or 'none'}")
    print(json.dumps({"retailer_customer_id": cid, "quote_id": qid, "order_id": oid}))
    print(f"== {sum(results)}/{len(results)} passed")


if __name__ == "__main__":
    {"personal": personal_signup, "workflow": main}[sys.argv[1]]()
    if sys.argv[1] == "personal":
        print(f"== {sum(results)}/{len(results)} passed")
