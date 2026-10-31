"""Sandbox order driver: real storefront HTTP flows, one cookie session per fictional buyer.

Usage (examples):
  python3 qa/tools/order_driver.py place qa.alpha 147:3            # one buyer, one order
  python3 order_driver.py race 147:3 qa.alpha qa.beta ... # carts first, then all orders fired at once
Lines are VARIANT_ID:QTY; several lines make a mixed size/colour cart.
"""
import http.cookiejar, json, os, re, sys, threading, urllib.error, urllib.parse, urllib.request
import vk7env as V

BASE = V.BASE
PASSWORD = V.required("QA_PASSWORD")
PARENT = 144
SUPER = {  # variant id -> (color option, size option); sleeve is always option 25
    145: (1, 6), 146: (41, 6), 147: (1, 7), 148: (1, 8),
    149: (1, 9), 150: (41, 7), 151: (41, 8), 152: (41, 9),
}
BILLING = {
    "company_name": "Fictional Test Shop", "first_name": "Buyer", "last_name": "Test",
    "email": "buyer@example.test", "address": ["1 Test Street"], "country": "IN",
    "state": "DL", "city": "Testpur", "postcode": "110001", "phone": "9000000001",
    "use_for_shipping": True,
}


class Buyer:
    def __init__(self, name):
        self.name = name
        self.jar = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.jar))

    def _req(self, method, path, data=None, form=False):
        headers = {"Accept": "application/json", "X-Requested-With": "XMLHttpRequest"}
        xsrf = next((c.value for c in self.jar if c.name == "XSRF-TOKEN"), None)
        if xsrf:
            headers["X-XSRF-TOKEN"] = urllib.parse.unquote(xsrf)
        body = None
        if data is not None:
            if form:
                body = urllib.parse.urlencode(data).encode()
                headers["Content-Type"] = "application/x-www-form-urlencoded"
            else:
                body = json.dumps(data).encode()
                headers["Content-Type"] = "application/json"
        req = urllib.request.Request(BASE + path, data=body, method=method, headers=headers)
        try:
            with self.opener.open(req, timeout=60) as r:
                return r.status, r.read().decode()
        except urllib.error.HTTPError as e:
            return e.code, e.read().decode()

    def login(self):
        html = self.opener.open(BASE + "/customer/login").read().decode()
        token = re.search(r'name="_token" value="([^"]+)"', html).group(1)
        self._req("POST", "/customer/login", {
            "email": f"{self.name}@example.test", "password": PASSWORD, "_token": token}, form=True)
        code, body = self._req("GET", "/api/checkout/cart")
        assert code == 200, f"{self.name} login/cart failed: {code}"
        return self

    def clear_cart(self):
        _, body = self._req("GET", "/api/checkout/cart")
        for item in (json.loads(body).get("data") or {}).get("items", []):
            self._req("DELETE", "/api/checkout/cart", {"cart_item_id": item["id"]})

    def add(self, variant, qty):
        color, size = SUPER[variant]
        code, body = self._req("POST", "/api/checkout/cart", {
            "product_id": PARENT, "quantity": qty, "is_buy_now": 0,
            "selected_configurable_option": variant,
            "super_attribute": {"23": color, "24": size, "34": 25}})
        return code, _msg(body)

    def prepare_checkout(self):
        steps = [("/api/checkout/onepage/addresses", {"billing": BILLING}),
                 ("/api/checkout/onepage/shipping-methods", {"shipping_method": "free_free"}),
                 ("/api/checkout/onepage/payment-methods", {"payment": {"method": "moneytransfer"}})]
        out = []
        for path, data in steps:
            code, body = self._req("POST", path, data)
            out.append((path.rsplit("/", 1)[1], code, _msg(body)))
        return out

    def place(self):
        code, body = self._req("POST", "/api/checkout/onepage/orders", {})
        ok = code == 200 and _msg(body).endswith("/checkout/onepage/success")
        return ok, code, _msg(body) if ok else self.shown_error(_msg(body))

    def shown_error(self, fallback):
        html = self.opener.open(BASE + "/checkout/cart").read().decode()
        m = re.search(r"(Minimum order is[^<\"]*|The requested quantity is not available[^<\"]*)", html)
        return m.group(1) if m else fallback


def _msg(body):
    try:
        d = json.loads(body)
    except ValueError:
        return body[:120]
    data = d.get("data") if isinstance(d.get("data"), dict) else {}
    return d.get("message") or data.get("message") or data.get("redirect_url") or str(d)[:120]


def parse_lines(args):
    return [tuple(int(x) for x in a.split(":")) for a in args]


def build_cart(name, lines):
    b = Buyer(name).login()
    b.clear_cart()
    adds = [(v, q, *b.add(v, q)) for v, q in lines]
    return b, adds


def place(name, lines):
    b, adds = build_cart(name, lines)
    prep = b.prepare_checkout()
    result = b.place()
    print(json.dumps({"buyer": name, "add": adds, "placed": result[0],
                      "http": result[1], "message": result[2]}))


def race(lines, names):
    buyers = []
    for n in names:
        b, adds = build_cart(n, lines)
        prep = b.prepare_checkout()
        buyers.append((b, adds, prep))
    barrier = threading.Barrier(len(buyers))
    results = {}

    def fire(b):
        barrier.wait()
        results[b.name] = b.place()

    threads = [threading.Thread(target=fire, args=(b,)) for b, _, _ in buyers]
    [t.start() for t in threads]
    [t.join() for t in threads]
    for b, adds, prep in buyers:
        ok, code, msg = results[b.name]
        print(json.dumps({"buyer": b.name, "add": adds, "placed": ok, "http": code, "message": msg}))
    print(json.dumps({"summary": {"fired": len(buyers),
                                  "placed": sum(r[0] for r in results.values())}}))


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "place":
        place(sys.argv[2], parse_lines(sys.argv[3:]))
    elif cmd == "race":
        split = next(i for i, a in enumerate(sys.argv[2:], 2) if not a[0].isdigit())
        race(parse_lines(sys.argv[2:split]), sys.argv[split:])
