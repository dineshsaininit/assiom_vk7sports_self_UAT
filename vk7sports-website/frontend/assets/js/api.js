/* VK7.api is the only way pages talk to data. Every method returns a Promise.
   This file is a stand-in backend that runs in the browser so the whole journey can be
   clicked through before Bagisto is connected. To connect the real backend, replace each
   method body with a fetch() call and keep the same return shapes. INTEGRATION.md maps
   each method to its Bagisto route.

   The rules here (price hiding, MOQ, stock, ownership) are only a demonstration.
   The server must enforce all of them itself: browser code can always be changed. */
(function () {
  const VK7 = window.VK7 = window.VK7 || {};
  const KEY = 'vk7.demo.db.v1';
  const SESSION = 'vk7.demo.session.v1';
  const DAY = 86400000, HOUR = 3600000;

  class ApiError extends Error {
    constructor(message, opts = {}) { super(message); this.name = 'ApiError'; this.code = opts.code || 'error'; this.fields = opts.fields || null; this.status = opts.status || 400; }
  }
  VK7.ApiError = ApiError;

  const STANDARD_FLOW = ['Awaiting advance', 'Confirmed', 'Packing', 'Dispatched', 'Delivered', 'Paid in full'];
  const CUSTOM_FLOW = ['Quote ready', 'Artwork awaiting approval', 'Artwork approved', 'Awaiting advance', 'Production authorised', 'In production', 'Awaiting balance', 'Dispatched', 'Delivered'];
  VK7.FLOWS = { standard: STANDARD_FLOW, custom: CUSTOM_FLOW };

  const PERMS = {
    Owner: ['dashboard', 'retailers', 'enquiries', 'quotes', 'orders', 'payments', 'dispatch', 'products', 'inventory', 'reports', 'notifications', 'staff', 'settings', 'audit'],
    Administrator: ['dashboard', 'notifications', 'staff', 'settings', 'audit', 'retailers', 'products'],
    Sales: ['dashboard', 'retailers', 'enquiries', 'quotes', 'orders', 'notifications'],
    Inventory: ['dashboard', 'products', 'inventory', 'orders', 'notifications'],
    Warehouse: ['dashboard', 'orders', 'dispatch', 'notifications'],
    Finance: ['dashboard', 'payments', 'orders', 'retailers', 'reports', 'notifications']
  };
  VK7.PERMS = PERMS;

  const iso = ms => new Date(ms).toISOString();
  const now = () => Date.now();
  const clone = o => JSON.parse(JSON.stringify(o));
  const uid = p => p + '-' + Math.random().toString(36).slice(2, 9);
  const round2 = n => Math.round(n * 100) / 100;

  let memory = null;   // used when browser storage is blocked
  const store = {
    get(k) { try { return localStorage.getItem(k); } catch (e) { return memory && memory[k] || null; } },
    set(k, v) { try { localStorage.setItem(k, v); } catch (e) { memory = memory || {}; memory[k] = v; } },
    del(k) { try { localStorage.removeItem(k); } catch (e) { if (memory) delete memory[k]; } }
  };

  function seedDb() {
    const S = window.VK7_SEED, t = now();
    const db = {
      categories: clone(S.categories), products: clone(S.products), settings: clone(S.settings),
      retailers: clone(S.retailers).map(r => ({ ...r, appliedAt: iso(t + r.appliedAt * DAY), approvedAt: r.status === 'approved' ? iso(t + (r.appliedAt + 1) * DAY) : null, rejectReason: null })),
      staff: clone(S.staff),
      carts: {}, quotes: [], orders: [], enquiries: [], notifications: [], audit: [], stockLog: [],
      seq: { order: 100, quote: 40, enquiry: 20, payment: 500 }
    };
    db.products.forEach(p => { p.held = {}; });
    seedTransactions(db);
    return db;
  }

  function line(db, productId, colour, size, qty, price) {
    const p = db.products.find(x => x.id === productId);
    const c = p.colours.find(x => x.name === colour);
    return { productId, name: p.name, style: p.style, sku: skuOf(p, c, size), colour, size, qty, unitPrice: price == null ? p.price : price, image: c.images[0] };
  }
  const skuOf = (p, c, size) => p.style + '-' + c.code + '-' + size;

  function seedTransactions(db) {
    const t = now(), S = db.settings;
    const mk = (retailerId, type, status, lines, ageDays, extra = {}) => {
      const subtotal = lines.reduce((s, l) => s + l.qty * l.unitPrice, 0);
      const pct = type === 'custom' ? S.customAdvancePct : S.advancePct;
      const created = t - ageDays * DAY;
      const r = db.retailers.find(x => x.id === retailerId);
      const o = {
        id: uid('o'), number: nextNumber(db, 'order'), type, retailerId, company: r.company, phone: r.phone, lines, subtotal,
        advancePct: pct, advanceDue: round2(subtotal * pct / 100), balanceDue: round2(subtotal - subtotal * pct / 100),
        status, holdUntil: null, address: r.addresses[0], poRef: '', notes: '', quoteId: null, payments: [], shipment: null,
        artwork: null, history: [{ status: 'Order placed', at: iso(created), by: r.contact, note: '' }], createdAt: iso(created), ...extra
      };
      db.orders.push(o);
      return o;
    };
    const pay = (o, kind, amount, status, days) => {
      o.payments.push({ id: 'pay-' + (++db.seq.payment), kind, amount, method: 'UPI', ref: 'DEMO' + (100000 + db.seq.payment), status, at: iso(t - days * DAY), by: status === 'verified' ? 'Demo Finance' : null, reason: null });
    };
    const hist = (o, status, days, by) => o.history.push({ status, at: iso(t - days * DAY), by, note: '' });

    let o = mk('r-alpha', 'standard', 'Paid in full', [line(db, 'p-tee', 'Sky Blue', 'M', 24), line(db, 'p-tee', 'Sky Blue', 'L', 24), line(db, 'p-singlet', 'Violet', 'M', 24)], 34);
    pay(o, 'advance', o.advanceDue, 'verified', 33); pay(o, 'balance', o.balanceDue, 'verified', 24);
    hist(o, 'Confirmed', 33, 'Demo Finance'); hist(o, 'Packing', 32, 'Demo Warehouse'); hist(o, 'Dispatched', 30, 'Demo Warehouse'); hist(o, 'Delivered', 25, 'Demo Warehouse'); hist(o, 'Paid in full', 24, 'Demo Finance');
    o.shipment = { courier: 'Demo Transport Co.', lr: 'LR-DEMO-1001', date: iso(t - 30 * DAY), url: '' };

    o = mk('r-alpha', 'standard', 'Dispatched', [line(db, 'p-cargo', 'Charcoal', 'L', 18), line(db, 'p-cargo', 'Charcoal', 'XL', 12)], 9);
    pay(o, 'advance', o.advanceDue, 'verified', 8);
    hist(o, 'Confirmed', 8, 'Demo Finance'); hist(o, 'Packing', 6, 'Demo Warehouse'); hist(o, 'Dispatched', 3, 'Demo Warehouse');
    o.shipment = { courier: 'Demo Transport Co.', lr: 'LR-DEMO-1002', date: iso(t - 3 * DAY), url: '' };

    o = mk('r-alpha', 'standard', 'Awaiting advance', [line(db, 'p-tee', 'Mint Green', 'M', 12), line(db, 'p-tee', 'Mint Green', 'S', 12), line(db, 'p-tee', 'Lemon', 'M', 12)], 0.2, { holdUntil: iso(t + 44 * HOUR) });
    hold(db, o, 1);

    o = mk('r-charlie', 'standard', 'Packing', [line(db, 'p-singlet', 'White', 'L', 30), line(db, 'p-jacket', 'Coral', 'M', 24)], 4);
    pay(o, 'advance', o.advanceDue, 'verified', 3);
    hist(o, 'Confirmed', 3, 'Demo Finance'); hist(o, 'Packing', 1, 'Demo Warehouse'); hold(db, o, 1);

    o = mk('r-charlie', 'standard', 'Awaiting advance', [line(db, 'p-tee', 'Aqua', 'L', 30)], 0.8, { holdUntil: iso(t + 29 * HOUR) });
    pay(o, 'advance', o.advanceDue, 'submitted', 0.1); hold(db, o, 1);

    o = mk('r-alpha', 'custom', 'Artwork awaiting approval', [line(db, 'p-tee', 'Steel Blue', 'M', 60, 340), line(db, 'p-tee', 'Steel Blue', 'L', 60, 340)], 3);
    o.artwork = { status: 'awaiting', version: 1, image: 'assets/img/products/tee-steel-action.jpg', note: 'Team logo on chest, numbers on back. Fictional sample proof.', at: iso(t - DAY), reply: null };
    o.designBrief = 'TEST-ALPHA Cricket Club: chest logo and player numbers.';

    db.quotes.push(mkQuote(db, 'r-alpha', 'Quote ready', [line(db, 'p-jacket', 'Coral', 'M', 30), line(db, 'p-jacket', 'Coral', 'L', 30)], 1, { offer: 640, note: 'Looking for a better rate on 60 pieces.', reply: 'We can offer ₹640 per piece on this quantity.' }));
    db.quotes.push(mkQuote(db, 'r-charlie', 'Quote requested', [line(db, 'p-cargo', 'Ash Grey', 'L', 40), line(db, 'p-cargo', 'Ash Grey', 'XL', 20)], 0.4, { note: 'Regular reorder expected if the price works.' }));

    db.enquiries.push({ id: uid('e'), number: nextNumber(db, 'enquiry'), type: 'bulk', name: 'Sunil Patil', organisation: 'TEST Public School', orgType: 'School or college', phone: '9000000011', email: 'school@example.test', city: 'Nashik', message: 'Sports day T-shirts for students.', quantity: '100 to 250 pieces', status: 'New', notes: [], followUp: null, retailerId: null, createdAt: iso(t - 0.3 * DAY) });
    db.enquiries.push({ id: uid('e'), number: nextNumber(db, 'enquiry'), type: 'custom', name: 'Priya Iyer', organisation: 'TEST Riders Cycling Club', orgType: 'Club or team', phone: '9000000012', email: 'club@example.test', city: 'Chennai', message: 'Club singlets with our logo.', quantity: '100 to 250 pieces', status: 'In follow-up', notes: [{ at: iso(t - DAY), by: 'Demo Sales', text: 'Called. Waiting for logo file.' }], followUp: iso(t + 2 * DAY), retailerId: null, createdAt: iso(t - 3 * DAY) });

    db.audit.push({ id: uid('l'), at: iso(t - 2 * DAY), by: 'Demo Finance', action: 'Verified advance payment', target: db.orders[3].number, detail: '' });
    db.notifications.push({ id: uid('n'), to: 'staff', title: 'New retailer application: TEST-BRAVO Sports', link: 'admin-retailers.html', at: iso(t - DAY), read: false });
    db.notifications.push({ id: uid('n'), to: 'staff', title: 'Advance reference submitted for review', link: 'admin-payments.html', at: iso(t - 0.1 * DAY), read: false });
    db.notifications.push({ id: uid('n'), to: 'r-alpha', title: 'Your quote is ready to review', link: 'account-quotes.html', at: iso(t - 0.5 * DAY), read: false });
    db.notifications.push({ id: uid('n'), to: 'r-alpha', title: 'Artwork proof is ready for your approval', link: 'account-orders.html', at: iso(t - DAY), read: false });
  }

  function mkQuote(db, retailerId, status, lines, ageDays, o = {}) {
    const t = now(), r = db.retailers.find(x => x.id === retailerId);
    const q = {
      id: uid('q'), number: nextNumber(db, 'quote'), retailerId, company: r.company, status, lines: lines.map(l => ({ ...l, listPrice: l.unitPrice, offerPrice: o.offer || null })),
      note: o.note || '', shortageAcknowledged: false, messages: [], validUntil: null, createdAt: iso(t - ageDays * DAY), orderId: null
    };
    if (o.note) q.messages.push({ from: 'retailer', by: r.contact, text: o.note, at: q.createdAt });
    if (o.offer) {
      q.messages.push({ from: 'staff', by: 'Demo Sales', text: o.reply || 'Offer sent.', at: iso(t - 0.5 * DAY) });
      q.validUntil = iso(t + db.settings.quoteValidityDays * DAY - 0.5 * DAY);
    }
    return q;
  }

  function nextNumber(db, kind) {
    db.seq[kind] += 1;
    const y = new Date().getFullYear();
    const prefix = { order: 'VK7-ORD', quote: 'VK7-QT', enquiry: 'VK7-ENQ' }[kind];
    return prefix + '-' + y + '-' + String(db.seq[kind]).padStart(5, '0');
  }

  function hold(db, order, dir) {
    order.lines.forEach(l => {
      const p = db.products.find(x => x.id === l.productId); if (!p) return;
      const k = l.colour + '|' + l.size;
      p.held[k] = Math.max(0, (p.held[k] || 0) + dir * l.qty);
    });
  }

  function load() {
    const raw = store.get(KEY);
    let db = null;
    if (raw) { try { db = JSON.parse(raw); } catch (e) { db = null; } }
    if (!db) { db = seedDb(); save(db); }
    if (expireHolds(db)) save(db);
    return db;
  }
  function save(db) { store.set(KEY, JSON.stringify(db)); }

  function expireHolds(db) {
    let changed = false;
    db.orders.forEach(o => {
      if (o.type === 'standard' && o.status === 'Awaiting advance' && o.holdUntil && new Date(o.holdUntil).getTime() < now() &&
        !o.payments.some(p => p.status === 'submitted' || p.status === 'verified')) {
        hold(db, o, -1); o.status = 'Expired'; o.holdUntil = null;
        o.history.push({ status: 'Expired', at: iso(now()), by: 'System', note: 'No advance received within the hold period. Stock released.' });
        notify(db, o.retailerId, 'Order ' + o.number + ' expired: no advance received', 'account-order.html?id=' + o.id);
        changed = true;
      }
    });
    db.quotes.forEach(q => {
      if (q.status === 'Quote ready' && q.validUntil && new Date(q.validUntil).getTime() < now()) { q.status = 'Expired'; changed = true; }
    });
    return changed;
  }

  function notify(db, to, title, link) { db.notifications.unshift({ id: uid('n'), to, title, link, at: iso(now()), read: false }); }
  function audit(db, actor, action, target, detail) { db.audit.unshift({ id: uid('l'), at: iso(now()), by: actor, action, target, detail: detail || '' }); }

  function session() { try { return JSON.parse(store.get(SESSION)) || null; } catch (e) { return null; } }
  function currentUser(db) {
    const s = session(); if (!s) return null;
    if (s.kind === 'staff') {
      const u = db.staff.find(x => x.id === s.id && x.active);
      return u ? { kind: 'staff', id: u.id, name: u.name, email: u.email, role: u.role, perms: PERMS[u.role] || [] } : null;
    }
    const r = db.retailers.find(x => x.id === s.id);
    return r ? { kind: 'retailer', id: r.id, name: r.contact, company: r.company, email: r.email, status: r.status, approved: r.status === 'approved' } : null;
  }
  const needRetailer = (db, approved = true) => {
    const u = currentUser(db);
    if (!u || u.kind !== 'retailer') throw new ApiError('Please sign in to continue.', { code: 'auth', status: 401 });
    if (approved && !u.approved) throw new ApiError('Your account must be approved first.', { code: 'not_approved', status: 403 });
    return u;
  };
  const needStaff = (db, perm) => {
    const u = currentUser(db);
    if (!u || u.kind !== 'staff') throw new ApiError('Please sign in as staff.', { code: 'auth', status: 401 });
    if (perm && !u.perms.includes(perm)) throw new ApiError('Your role does not have access to this.', { code: 'forbidden', status: 403 });
    return u;
  };

  /* Prices are removed for anyone who is not an approved retailer or staff, matching what the server must do. */
  function publicProduct(p, user) {
    const canPrice = user && (user.approved || user.kind === 'staff');
    const avail = {};
    Object.keys(p.stock).forEach(k => { avail[k] = Math.max(0, p.stock[k] - (p.held[k] || 0)); });
    const total = Object.values(avail).reduce((a, b) => a + b, 0);
    const out = clone(p);
    delete out.stock; delete out.held;
    out.available = avail; out.totalAvailable = total;
    if (!canPrice) delete out.price;
    return out;
  }

  function cartView(db, user) {
    const lines = (db.carts[user.id] || []).map(l => {
      const p = db.products.find(x => x.id === l.productId);
      if (!p) return null;
      const c = p.colours.find(x => x.name === l.colour);
      const k = l.colour + '|' + l.size;
      const available = Math.max(0, (p.stock[k] || 0) - (p.held[k] || 0));
      return { ...l, name: p.name, style: p.style, sku: skuOf(p, c, l.size), unitPrice: p.price, image: c.images[0], available, short: Math.max(0, l.qty - available), slug: p.slug };
    }).filter(Boolean);
    const groups = {};
    lines.forEach(l => { (groups[l.productId] = groups[l.productId] || { productId: l.productId, name: l.name, style: l.style, slug: l.slug, image: l.image, lines: [], pieces: 0, value: 0 }); const g = groups[l.productId]; g.lines.push(l); g.pieces += l.qty; g.value += l.qty * l.unitPrice; });
    const list = Object.values(groups);
    const pieces = lines.reduce((s, l) => s + l.qty, 0);
    const subtotal = lines.reduce((s, l) => s + l.qty * l.unitPrice, 0);
    const violations = moqViolations(db, list, lines, pieces);
    const shortages = lines.filter(l => l.short > 0);
    const S = db.settings;
    return { groups: list, lines, pieces, subtotal, violations, shortages, advancePct: S.advancePct, advanceDue: round2(subtotal * S.advancePct / 100), balanceDue: round2(subtotal - subtotal * S.advancePct / 100), moq: S.moq, moqMode: S.moqMode, moqEnabled: S.moqEnabled };
  }

  function moqViolations(db, groups, lines, pieces) {
    const S = db.settings;
    if (!S.moqEnabled || !lines.length) return [];
    if (S.moqMode === 'per_order') return pieces < S.moq ? [{ label: 'Whole order', need: S.moq - pieces, productId: null }] : [];
    if (S.moqMode === 'per_variant') return lines.filter(l => l.qty < S.moq).map(l => ({ label: l.name + ' / ' + l.colour + ' / ' + l.size, need: S.moq - l.qty, productId: l.productId }));
    return groups.filter(g => g.pieces < S.moq).map(g => ({ label: g.name, need: S.moq - g.pieces, productId: g.productId }));
  }

  function validateFields(values, rules) {
    const fields = {};
    Object.keys(rules).forEach(k => {
      const v = String(values[k] == null ? '' : values[k]).trim(), r = rules[k];
      if (r.required && !v) fields[k] = r.message || 'This field is required.';
      else if (v && r.pattern && !r.pattern.test(v)) fields[k] = r.message || 'Please check this value.';
      else if (v && r.min && v.length < r.min) fields[k] = 'Must be at least ' + r.min + ' characters.';
    });
    if (Object.keys(fields).length) throw new ApiError('Please correct the highlighted fields.', { code: 'validation', fields });
  }
  const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/, PHONE = /^[6-9]\d{9}$/, PIN = /^\d{6}$/, GST = /^\d{2}[A-Z]{5}\d{4}[A-Z][1-9A-Z]Z[0-9A-Z]$/i;

  function createOrder(db, user, opts) {
    const S = db.settings, r = db.retailers.find(x => x.id === user.id), t = now();
    const subtotal = opts.lines.reduce((s, l) => s + l.qty * l.unitPrice, 0);
    const o = {
      id: uid('o'), number: nextNumber(db, 'order'), type: 'standard', retailerId: user.id, company: r.company, phone: r.phone, lines: opts.lines, subtotal,
      advancePct: S.advancePct, advanceDue: round2(subtotal * S.advancePct / 100), balanceDue: round2(subtotal - subtotal * S.advancePct / 100),
      status: 'Awaiting advance', holdUntil: iso(t + S.holdHours * HOUR), address: opts.address, poRef: opts.poRef || '', notes: opts.notes || '', quoteId: opts.quoteId || null,
      payments: [], shipment: null, artwork: null, history: [{ status: 'Order placed', at: iso(t), by: r.contact, note: opts.quoteId ? 'From accepted quote' : '' }], createdAt: iso(t)
    };
    hold(db, o, 1);
    db.orders.unshift(o);
    notify(db, 'staff', 'New order ' + o.number + ' from ' + o.company, 'admin-order.html?id=' + o.id);
    notify(db, user.id, 'Order ' + o.number + ' placed. Advance due within ' + S.holdHours + ' hours.', 'account-order.html?id=' + o.id);
    return o;
  }

  const checkStock = (db, lines) => lines.filter(l => {
    const p = db.products.find(x => x.id === l.productId), k = l.colour + '|' + l.size;
    return !p || l.qty > Math.max(0, (p.stock[k] || 0) - (p.held[k] || 0));
  });

  const statement = (db, retailerId) => {
    const rows = [];
    db.orders.filter(o => o.retailerId === retailerId && o.status !== 'Cancelled' && o.status !== 'Expired').forEach(o => {
      rows.push({ at: o.createdAt, text: 'Order ' + o.number, ref: o.id, debit: o.subtotal, credit: 0 });
      o.payments.filter(p => p.status === 'verified').forEach(p => rows.push({ at: p.at, text: (p.kind === 'advance' ? 'Advance' : 'Balance') + ' received, ref ' + p.ref, ref: o.id, debit: 0, credit: p.amount }));
    });
    rows.sort((a, b) => new Date(a.at) - new Date(b.at));
    let bal = 0; rows.forEach(r => { bal = round2(bal + r.debit - r.credit); r.balance = bal; });
    return { rows, balance: bal, billed: rows.reduce((s, r) => s + r.debit, 0), paid: rows.reduce((s, r) => s + r.credit, 0) };
  };

  const paidOn = o => o.payments.filter(p => p.status === 'verified').reduce((s, p) => s + p.amount, 0);
  const outstanding = o => ['Cancelled', 'Expired'].includes(o.status) ? 0 : round2(o.subtotal - paidOn(o));

  /* Wraps a method: simulates network delay, and always works on a fresh copy of the data. */
  const call = fn => (...args) => new Promise((resolve, reject) => {
    setTimeout(() => {
      try { const db = load(); const res = fn(db, ...args); resolve(res === undefined ? undefined : clone(res)); }
      catch (e) { reject(e); }
    }, 90);
  });
  const orderFor = (db, id, user) => {
    const o = db.orders.find(x => x.id === id);
    if (!o || o.retailerId !== user.id) throw new ApiError('Order not found.', { code: 'not_found', status: 404 });
    return o;
  };
  const quoteFor = (db, id, user) => {
    const q = db.quotes.find(x => x.id === id);
    if (!q || q.retailerId !== user.id) throw new ApiError('Quote not found.', { code: 'not_found', status: 404 });
    return q;
  };

  const api = {
    demoReset() { store.del(KEY); store.del(SESSION); memory = null; return Promise.resolve(); },

    settings: call(db => {
      const S = db.settings;
      return { moqEnabled: S.moqEnabled, moq: S.moq, moqMode: S.moqMode, customMoq: S.customMoq, advancePct: S.advancePct, customAdvancePct: S.customAdvancePct, holdHours: S.holdHours, quoteValidityDays: S.quoteValidityDays, shortageNote: S.shortageNote };
    }),

    auth: {
      me: call(db => {
        const u = currentUser(db);
        if (!u) return null;
        const to = u.kind === 'staff' ? 'staff' : u.id;
        return { ...u, cartCount: u.kind === 'retailer' ? (db.carts[u.id] || []).reduce((s, l) => s + l.qty, 0) : 0, unread: db.notifications.filter(n => n.to === to && !n.read).length };
      }),
      login: call((db, { email, password }) => {
        validateFields({ email, password }, { email: { required: true, pattern: EMAIL, message: 'Enter a valid email address.' }, password: { required: true, message: 'Enter your password.' } });
        const r = db.retailers.find(x => x.email.toLowerCase() === email.trim().toLowerCase());
        if (!r || r.password !== password) throw new ApiError('The email or password is not correct.', { code: 'bad_login', status: 401 });
        if (r.status === 'suspended') throw new ApiError('This account is suspended. Please contact VK7SPORTS.', { code: 'suspended', status: 403 });
        store.set(SESSION, JSON.stringify({ kind: 'retailer', id: r.id }));
        return { status: r.status };
      }),
      staffLogin: call((db, { email, password }) => {
        validateFields({ email, password }, { email: { required: true, pattern: EMAIL, message: 'Enter a valid email address.' }, password: { required: true, message: 'Enter your password.' } });
        const u = db.staff.find(x => x.email.toLowerCase() === email.trim().toLowerCase());
        if (!u || u.password !== password || !u.active) throw new ApiError('The email or password is not correct.', { code: 'bad_login', status: 401 });
        store.set(SESSION, JSON.stringify({ kind: 'staff', id: u.id }));
        return { role: u.role };
      }),
      logout() { store.del(SESSION); return Promise.resolve(); },
      register: call((db, v) => {
        validateFields(v, {
          company: { required: true }, contact: { required: true }, shopType: { required: true }, city: { required: true }, state: { required: true },
          phone: { required: true, pattern: PHONE, message: 'Enter a 10-digit mobile number.' },
          email: { required: true, pattern: EMAIL, message: 'Enter a valid email address.' },
          password: { required: true, min: 8 },
          pin: { required: true, pattern: PIN, message: 'Enter a 6-digit PIN code.' },
          address: { required: true }
        });
        const fields = {};
        if (v.password !== v.confirm) fields.confirm = 'The passwords do not match.';
        if (v.gstin && !GST.test(v.gstin.trim())) fields.gstin = 'This GSTIN does not look right. It should have 15 characters.';
        if (!v.gstin && !(v.proof || '').trim()) fields.proof = 'Enter a GSTIN, or name another proof of business.';
        if (db.retailers.some(r => r.email.toLowerCase() === v.email.trim().toLowerCase())) fields.email = 'An account with this email already exists.';
        if (!v.agree) fields.agree = 'Please accept to continue.';
        if (Object.keys(fields).length) throw new ApiError('Please correct the highlighted fields.', { code: 'validation', fields });
        const r = {
          id: uid('r'), status: 'pending', company: v.company.trim(), contact: v.contact.trim(), email: v.email.trim(), password: v.password, phone: v.phone.trim(), shopType: v.shopType,
          gstin: (v.gstin || '').trim().toUpperCase(), proof: v.gstin ? 'GSTIN' : v.proof.trim(), city: v.city.trim(), state: v.state.trim(), appliedAt: iso(now()), approvedAt: null, rejectReason: null, priceList: 'Standard',
          addresses: [{ id: 'a1', label: 'Main shop', line1: v.address.trim(), city: v.city.trim(), state: v.state.trim(), pin: v.pin.trim(), phone: v.phone.trim(), isDefault: true }],
          users: [{ id: 'u1', name: v.contact.trim(), email: v.email.trim(), role: 'Owner' }]
        };
        db.retailers.push(r);
        notify(db, 'staff', 'New retailer application: ' + r.company, 'admin-retailer.html?id=' + r.id);
        save(db);
        store.set(SESSION, JSON.stringify({ kind: 'retailer', id: r.id }));
        return { id: r.id };
      }),
      forgot: call((db, { email }) => {
        validateFields({ email }, { email: { required: true, pattern: EMAIL, message: 'Enter a valid email address.' } });
        return { sent: true }; // same answer whether or not the account exists
      })
    },

    catalog: {
      categories: call(db => db.categories.map(c => ({ ...c, count: db.products.filter(p => p.category === c.id && p.status === 'active').length }))),
      list: call((db, f = {}) => {
        const user = currentUser(db), q = (f.q || '').trim().toLowerCase();
        let list = db.products.filter(p => p.status === 'active');
        if (q) list = list.filter(p => [p.name, p.style, p.summary, p.category, p.gender, ...p.colours.map(c => c.name)].join(' ').toLowerCase().includes(q));
        if (f.category && f.category.length) list = list.filter(p => f.category.includes(p.category));
        if (f.gender && f.gender.length) list = list.filter(p => f.gender.includes(p.gender));
        if (f.colour && f.colour.length) list = list.filter(p => p.colours.some(c => f.colour.includes(c.name)));
        if (f.size && f.size.length) list = list.filter(p => p.sizes.some(s => f.size.includes(s)));
        if (f.customisable) list = list.filter(p => p.customisable);
        let out = list.map(p => publicProduct(p, user));
        if (f.inStock) out = out.filter(p => p.totalAvailable > 0);
        if (f.sort === 'name') out.sort((a, b) => a.name.localeCompare(b.name));
        else if (f.sort === 'new') out.sort((a, b) => (b.isNew ? 1 : 0) - (a.isNew ? 1 : 0));
        else if (f.sort === 'stock') out.sort((a, b) => b.totalAvailable - a.totalAvailable);
        else if ((f.sort === 'price-asc' || f.sort === 'price-desc') && user && (user.approved || user.kind === 'staff')) out.sort((a, b) => f.sort === 'price-asc' ? a.price - b.price : b.price - a.price);
        return out;
      }),
      facets: call(db => {
        const a = db.products.filter(p => p.status === 'active');
        return { colours: [...new Map(a.flatMap(p => p.colours).map(c => [c.name, { name: c.name, hex: c.hex }])).values()], sizes: ['S', 'M', 'L', 'XL', 'XXL'].filter(s => a.some(p => p.sizes.includes(s))), genders: [...new Set(a.map(p => p.gender))] };
      }),
      get: call((db, slug) => {
        const p = db.products.find(x => (x.slug === slug || x.id === slug) && x.status === 'active');
        if (!p) throw new ApiError('This product could not be found.', { code: 'not_found', status: 404 });
        const user = currentUser(db);
        const out = publicProduct(p, user);
        out.related = db.products.filter(x => x.id !== p.id && x.status === 'active').slice(0, 4).map(x => publicProduct(x, user));
        return out;
      }),
      skus: call(db => {
        needRetailer(db);
        return db.products.filter(p => p.status === 'active').flatMap(p => p.colours.flatMap(c => p.sizes.map(s => ({ sku: skuOf(p, c, s), productId: p.id, name: p.name, colour: c.name, size: s }))));
      })
    },

    cart: {
      get: call(db => cartView(db, needRetailer(db))),
      setStyle: call((db, productId, lines) => {
        const u = needRetailer(db);
        const p = db.products.find(x => x.id === productId);
        if (!p) throw new ApiError('Product not found.');
        const clean = lines.filter(l => l.qty > 0).map(l => {
          if (!Number.isInteger(l.qty) || l.qty < 0 || l.qty > 9999) throw new ApiError('Quantities must be whole numbers.');
          if (!p.colours.some(c => c.name === l.colour) || !p.sizes.includes(l.size)) throw new ApiError('That size or colour is not available.');
          return { productId, colour: l.colour, size: l.size, qty: l.qty };
        });
        db.carts[u.id] = (db.carts[u.id] || []).filter(l => l.productId !== productId).concat(clean);
        save(db);
        return cartView(db, u);
      }),
      addMany: call((db, items) => {
        const u = needRetailer(db);
        const cart = db.carts[u.id] = db.carts[u.id] || [];
        items.forEach(i => {
          const x = cart.find(l => l.productId === i.productId && l.colour === i.colour && l.size === i.size);
          if (x) x.qty += i.qty; else cart.push({ productId: i.productId, colour: i.colour, size: i.size, qty: i.qty });
        });
        save(db);
        return cartView(db, u);
      }),
      setLine: call((db, productId, colour, size, qty) => {
        const u = needRetailer(db);
        if (!Number.isInteger(qty) || qty < 0 || qty > 9999) throw new ApiError('Quantities must be whole numbers.');
        const cart = db.carts[u.id] || [];
        const x = cart.find(l => l.productId === productId && l.colour === colour && l.size === size);
        if (x) x.qty = qty;
        db.carts[u.id] = cart.filter(l => l.qty > 0);
        save(db);
        return cartView(db, u);
      }),
      removeStyle: call((db, productId) => {
        const u = needRetailer(db);
        db.carts[u.id] = (db.carts[u.id] || []).filter(l => l.productId !== productId);
        save(db);
        return cartView(db, u);
      }),
      clear: call(db => { const u = needRetailer(db); db.carts[u.id] = []; save(db); })
    },

    quotes: {
      list: call(db => { const u = needRetailer(db); return db.quotes.filter(q => q.retailerId === u.id).sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)); }),
      get: call((db, id) => quoteFor(db, id, needRetailer(db))),
      request: call((db, { note, acknowledgeShortage }) => {
        const u = needRetailer(db), v = cartView(db, u);
        if (!v.lines.length) throw new ApiError('Your order list is empty.');
        if (db.settings.moqOnQuotes && v.violations.length) throw new ApiError('Minimum order not met: ' + v.violations.map(x => x.label + ' needs ' + x.need + ' more').join('; ') + '.', { code: 'moq' });
        if (v.shortages.length && !acknowledgeShortage) throw new ApiError('Please confirm you have read the stock shortage note.', { code: 'shortage' });
        const r = db.retailers.find(x => x.id === u.id);
        const q = mkQuote(db, u.id, 'Quote requested', v.lines.map(l => ({ productId: l.productId, name: l.name, style: l.style, sku: l.sku, colour: l.colour, size: l.size, qty: l.qty, unitPrice: l.unitPrice, image: l.image })), 0, { note: (note || '').trim() });
        q.shortageAcknowledged = !!acknowledgeShortage;
        db.quotes.unshift(q); db.carts[u.id] = [];
        notify(db, 'staff', 'Quote request ' + q.number + ' from ' + r.company, 'admin-quote.html?id=' + q.id);
        save(db);
        return { id: q.id, number: q.number };
      }),
      message: call((db, id, text) => {
        const u = needRetailer(db), q = quoteFor(db, id, u);
        if (!text || !text.trim()) throw new ApiError('Please type a message.');
        q.messages.push({ from: 'retailer', by: u.name, text: text.trim(), at: iso(now()) });
        if (q.status === 'Quote ready') q.status = 'Quote requested';
        notify(db, 'staff', 'New message on quote ' + q.number, 'admin-quote.html?id=' + q.id);
        save(db);
        return q;
      }),
      accept: call((db, id) => {
        const u = needRetailer(db), q = quoteFor(db, id, u);
        if (q.status !== 'Quote ready') throw new ApiError('This quote cannot be accepted now.');
        if (new Date(q.validUntil).getTime() < now()) { q.status = 'Expired'; save(db); throw new ApiError('This quote has expired.'); }
        q.status = 'Accepted'; q.acceptedAt = iso(now());
        audit(db, u.name, 'Accepted quote', q.number, 'Price locked');
        notify(db, 'staff', 'Quote ' + q.number + ' accepted by ' + q.company, 'admin-quote.html?id=' + q.id);
        save(db);
        return q;
      }),
      decline: call((db, id) => {
        const u = needRetailer(db), q = quoteFor(db, id, u);
        if (!['Quote ready', 'Quote requested'].includes(q.status)) throw new ApiError('This quote cannot be declined now.');
        q.status = 'Declined';
        save(db);
        return q;
      })
    },

    checkout: {
      prepare: call((db, quoteId) => {
        const u = needRetailer(db), r = db.retailers.find(x => x.id === u.id), S = db.settings;
        if (quoteId) {
          const q = quoteFor(db, quoteId, u);
          if (q.status !== 'Accepted') throw new ApiError('This quote has not been accepted, or has already been ordered.');
          const lines = q.lines.map(l => ({ ...l, unitPrice: l.offerPrice == null ? l.unitPrice : l.offerPrice }));
          const subtotal = lines.reduce((s, l) => s + l.qty * l.unitPrice, 0);
          return { quote: q, lines, pieces: lines.reduce((s, l) => s + l.qty, 0), subtotal, advancePct: S.advancePct, advanceDue: round2(subtotal * S.advancePct / 100), balanceDue: round2(subtotal - subtotal * S.advancePct / 100), holdHours: S.holdHours, addresses: r.addresses, violations: [], shortages: checkStock(db, lines) };
        }
        const v = cartView(db, u);
        return { quote: null, lines: v.lines, pieces: v.pieces, subtotal: v.subtotal, advancePct: v.advancePct, advanceDue: v.advanceDue, balanceDue: v.balanceDue, holdHours: S.holdHours, addresses: r.addresses, violations: v.violations, shortages: v.shortages };
      }),
      place: call((db, { addressId, poRef, notes, agree, quoteId }) => {
        const u = needRetailer(db), r = db.retailers.find(x => x.id === u.id);
        const address = r.addresses.find(a => a.id === addressId);
        const fields = {};
        if (!address) fields.addressId = 'Choose a delivery address.';
        if (!agree) fields.agree = 'Please accept the order terms.';
        if (Object.keys(fields).length) throw new ApiError('Please correct the highlighted fields.', { code: 'validation', fields });
        let lines, q = null;
        if (quoteId) {
          q = quoteFor(db, quoteId, u);
          if (q.status !== 'Accepted') throw new ApiError('This quote has already been used.');
          lines = q.lines.map(({ listPrice, offerPrice, ...l }) => ({ ...l, unitPrice: offerPrice == null ? l.unitPrice : offerPrice }));
        } else {
          const v = cartView(db, u);
          if (!v.lines.length) throw new ApiError('Your order list is empty.');
          if (v.violations.length) throw new ApiError('Minimum order not met: ' + v.violations.map(x => x.label + ' needs ' + x.need + ' more').join('; ') + '.', { code: 'moq' });
          lines = v.lines.map(l => ({ productId: l.productId, name: l.name, style: l.style, sku: l.sku, colour: l.colour, size: l.size, qty: l.qty, unitPrice: l.unitPrice, image: l.image }));
        }
        const short = checkStock(db, lines);
        if (short.length) throw new ApiError('Not enough stock for: ' + short.map(l => l.name + ' ' + l.colour + ' ' + l.size).join(', ') + '. Reduce the quantity or request a quote.', { code: 'stock' });
        const o = createOrder(db, u, { lines, address, poRef, notes, quoteId });
        if (q) { q.status = 'Ordered'; q.orderId = o.id; } else db.carts[u.id] = [];
        save(db);
        return { id: o.id, number: o.number };
      })
    },

    orders: {
      list: call(db => { const u = needRetailer(db, false); return db.orders.filter(o => o.retailerId === u.id).sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)).map(o => ({ ...o, paid: paidOn(o), outstanding: outstanding(o) })); }),
      get: call((db, id) => { const o = orderFor(db, id, needRetailer(db, false)); return { ...o, paid: paidOn(o), outstanding: outstanding(o) }; }),
      submitPayment: call((db, id, { kind, method, ref, amount }) => {
        const u = needRetailer(db), o = orderFor(db, id, u);
        validateFields({ ref, method }, { method: { required: true }, ref: { required: true, pattern: /^[A-Za-z0-9-]{6,30}$/, message: 'Enter the 6 to 30 character payment reference.' } });
        if (o.payments.some(p => p.ref.toLowerCase() === ref.trim().toLowerCase() && p.status !== 'rejected')) throw new ApiError('This reference has already been submitted.', { fields: { ref: 'This reference has already been submitted.' } });
        if (o.payments.some(p => p.kind === kind && p.status === 'submitted')) throw new ApiError('A payment is already waiting for verification.');
        const amt = Number(amount);
        if (!(amt > 0) || amt > outstanding(o)) throw new ApiError('Enter a valid amount.', { fields: { amount: 'Enter a valid amount.' } });
        o.payments.push({ id: 'pay-' + (++db.seq.payment), kind, amount: amt, method, ref: ref.trim(), status: 'submitted', at: iso(now()), by: null, reason: null });
        o.history.push({ status: 'Payment reference submitted', at: iso(now()), by: u.name, note: ref.trim() });
        notify(db, 'staff', 'Payment reference submitted on ' + o.number, 'admin-payments.html');
        save(db);
        return o;
      }),
      cancel: call((db, id, reason) => {
        const u = needRetailer(db), o = orderFor(db, id, u);
        if (o.status !== 'Awaiting advance' || o.payments.some(p => p.status === 'verified')) throw new ApiError('This order can no longer be cancelled online. Please contact sales.');
        if (!reason || !reason.trim()) throw new ApiError('Please give a reason.');
        hold(db, o, -1); o.status = 'Cancelled'; o.holdUntil = null;
        o.history.push({ status: 'Cancelled', at: iso(now()), by: u.name, note: reason.trim() });
        notify(db, 'staff', 'Order ' + o.number + ' cancelled by retailer', 'admin-order.html?id=' + o.id);
        save(db);
        return o;
      }),
      reorder: call((db, id) => {
        const u = needRetailer(db), o = orderFor(db, id, u);
        const cart = db.carts[u.id] = db.carts[u.id] || [];
        o.lines.forEach(l => {
          const p = db.products.find(x => x.id === l.productId);
          if (!p || p.status !== 'active') return;
          const x = cart.find(c => c.productId === l.productId && c.colour === l.colour && c.size === l.size);
          if (x) x.qty += l.qty; else cart.push({ productId: l.productId, colour: l.colour, size: l.size, qty: l.qty });
        });
        save(db);
      }),
      artwork: call((db, id, { approve, reply, name }) => {
        const u = needRetailer(db), o = orderFor(db, id, u);
        if (o.type !== 'custom' || !o.artwork || o.artwork.status !== 'awaiting') throw new ApiError('There is no artwork waiting for approval.');
        if (approve) {
          if (!name || !name.trim()) throw new ApiError('Type your name to approve.', { fields: { name: 'Type your name to approve.' } });
          o.artwork.status = 'approved'; o.artwork.reply = 'Approved by ' + name.trim(); o.artwork.approvedAt = iso(now());
          o.status = 'Artwork approved';
          o.history.push({ status: 'Artwork approved', at: iso(now()), by: name.trim(), note: 'Version ' + o.artwork.version });
          o.status = 'Awaiting advance';
          o.history.push({ status: 'Awaiting advance', at: iso(now()), by: 'System', note: '' });
          audit(db, name.trim(), 'Approved artwork', o.number, 'Version ' + o.artwork.version);
        } else {
          if (!reply || !reply.trim()) throw new ApiError('Tell us what to change.', { fields: { reply: 'Tell us what to change.' } });
          o.artwork.status = 'changes'; o.artwork.reply = reply.trim();
          o.history.push({ status: 'Artwork change requested', at: iso(now()), by: u.name, note: reply.trim() });
        }
        notify(db, 'staff', 'Artwork response on ' + o.number, 'admin-order.html?id=' + o.id);
        save(db);
        return o;
      }),
      track: call((db, { number, phone }) => {
        const n = (number || '').trim().toUpperCase(), ph = (phone || '').replace(/\D/g, '').slice(-10);
        validateFields({ number: n, phone: ph }, { number: { required: true, message: 'Enter your order number.' }, phone: { required: true, pattern: PHONE, message: 'Enter the 10-digit mobile number on the order.' } });
        const o = db.orders.find(x => x.number === n && x.phone === ph);
        if (!o) throw new ApiError('No order matches that number and mobile.', { code: 'not_found', status: 404 });
        return { number: o.number, type: o.type, status: o.status, createdAt: o.createdAt, history: o.history, shipment: o.shipment, pieces: o.lines.reduce((s, l) => s + l.qty, 0) };
      })
    },

    enquiries: {
      create: call((db, v) => {
        validateFields(v, {
          name: { required: true }, organisation: { required: true }, orgType: { required: true }, city: { required: true }, quantity: { required: true }, message: { required: true },
          phone: { required: true, pattern: PHONE, message: 'Enter a 10-digit mobile number.' },
          email: { pattern: EMAIL, message: 'Enter a valid email address.' }
        });
        if (v.type === 'custom' && !v.rightsOk) throw new ApiError('Please correct the highlighted fields.', { code: 'validation', fields: { rightsOk: 'Please confirm you may use this artwork.' } });
        const u = currentUser(db);
        const e = { id: uid('e'), number: nextNumber(db, 'enquiry'), type: v.type || 'bulk', name: v.name.trim(), organisation: v.organisation.trim(), orgType: v.orgType, phone: v.phone.trim(), email: (v.email || '').trim(), city: v.city.trim(), message: v.message.trim(), quantity: v.quantity, styleId: v.styleId || null, artworkName: v.artworkName || null, requiredBy: v.requiredBy || null, status: 'New', notes: [], followUp: null, retailerId: u && u.kind === 'retailer' ? u.id : null, createdAt: iso(now()) };
        db.enquiries.unshift(e);
        notify(db, 'staff', 'New ' + (e.type === 'custom' ? 'customised order' : 'bulk') + ' enquiry from ' + e.organisation, 'admin-enquiries.html');
        save(db);
        return { number: e.number };
      }),
      mine: call(db => { const u = needRetailer(db, false); return db.enquiries.filter(e => e.retailerId === u.id); }),
      contact: call((db, v) => {
        validateFields(v, { name: { required: true }, phone: { required: true, pattern: PHONE, message: 'Enter a 10-digit mobile number.' }, message: { required: true }, email: { pattern: EMAIL, message: 'Enter a valid email address.' } });
        const e = { id: uid('e'), number: nextNumber(db, 'enquiry'), type: 'contact', name: v.name.trim(), organisation: v.organisation || '-', orgType: 'Contact form', phone: v.phone.trim(), email: (v.email || '').trim(), city: '-', message: v.message.trim(), quantity: '-', status: 'New', notes: [], followUp: null, retailerId: null, createdAt: iso(now()) };
        db.enquiries.unshift(e);
        notify(db, 'staff', 'New contact message from ' + e.name, 'admin-enquiries.html');
        save(db);
        return { number: e.number };
      })
    },

    account: {
      get: call(db => {
        const u = needRetailer(db, false), r = db.retailers.find(x => x.id === u.id);
        const { password, ...safe } = r;
        return safe;
      }),
      overview: call(db => {
        const u = needRetailer(db, false);
        const orders = db.orders.filter(o => o.retailerId === u.id).sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
        const quotes = db.quotes.filter(q => q.retailerId === u.id);
        return {
          openOrders: orders.filter(o => !['Paid in full', 'Cancelled', 'Expired'].includes(o.status)).length,
          awaitingAdvance: orders.filter(o => o.status === 'Awaiting advance').length,
          quotesToReview: quotes.filter(q => q.status === 'Quote ready').length,
          balance: orders.reduce((s, o) => s + outstanding(o), 0),
          recent: orders.slice(0, 5).map(o => ({ ...o, outstanding: outstanding(o) })),
          artwork: orders.filter(o => o.artwork && o.artwork.status === 'awaiting').map(o => ({ id: o.id, number: o.number }))
        };
      }),
      update: call((db, v) => {
        const u = needRetailer(db, false), r = db.retailers.find(x => x.id === u.id);
        validateFields(v, { contact: { required: true }, phone: { required: true, pattern: PHONE, message: 'Enter a 10-digit mobile number.' } });
        r.contact = v.contact.trim(); r.phone = v.phone.trim();
        save(db);
      }),
      password: call((db, { current, next, confirm }) => {
        const u = needRetailer(db, false), r = db.retailers.find(x => x.id === u.id);
        const fields = {};
        if (r.password !== current) fields.current = 'Your current password is not correct.';
        if (!next || next.length < 8) fields.next = 'Must be at least 8 characters.';
        if (next !== confirm) fields.confirm = 'The passwords do not match.';
        if (Object.keys(fields).length) throw new ApiError('Please correct the highlighted fields.', { code: 'validation', fields });
        r.password = next; save(db);
      }),
      saveAddress: call((db, v) => {
        const u = needRetailer(db, false), r = db.retailers.find(x => x.id === u.id);
        validateFields(v, { label: { required: true }, line1: { required: true }, city: { required: true }, state: { required: true }, pin: { required: true, pattern: PIN, message: 'Enter a 6-digit PIN code.' }, phone: { required: true, pattern: PHONE, message: 'Enter a 10-digit mobile number.' } });
        const data = { label: v.label.trim(), line1: v.line1.trim(), city: v.city.trim(), state: v.state.trim(), pin: v.pin.trim(), phone: v.phone.trim() };
        const a = r.addresses.find(x => x.id === v.id);
        if (a) Object.assign(a, data); else r.addresses.push({ id: uid('a'), ...data, isDefault: !r.addresses.length });
        save(db);
      }),
      deleteAddress: call((db, id) => {
        const u = needRetailer(db, false), r = db.retailers.find(x => x.id === u.id);
        if (r.addresses.length === 1) throw new ApiError('Keep at least one address on your account.');
        const wasDefault = r.addresses.find(a => a.id === id)?.isDefault;
        r.addresses = r.addresses.filter(a => a.id !== id);
        if (wasDefault) r.addresses[0].isDefault = true;
        save(db);
      }),
      defaultAddress: call((db, id) => {
        const u = needRetailer(db, false), r = db.retailers.find(x => x.id === u.id);
        r.addresses.forEach(a => { a.isDefault = a.id === id; });
        save(db);
      }),
      addUser: call((db, v) => {
        const u = needRetailer(db), r = db.retailers.find(x => x.id === u.id);
        validateFields(v, { name: { required: true }, email: { required: true, pattern: EMAIL, message: 'Enter a valid email address.' }, role: { required: true } });
        if (r.users.some(x => x.email.toLowerCase() === v.email.trim().toLowerCase())) throw new ApiError('This person already has a login.', { fields: { email: 'This person already has a login.' } });
        r.users.push({ id: uid('u'), name: v.name.trim(), email: v.email.trim(), role: v.role });
        save(db);
      }),
      removeUser: call((db, id) => {
        const u = needRetailer(db), r = db.retailers.find(x => x.id === u.id);
        const target = r.users.find(x => x.id === id);
        if (target && target.role === 'Owner') throw new ApiError('The shop owner login cannot be removed.');
        r.users = r.users.filter(x => x.id !== id);
        save(db);
      }),
      statement: call(db => statement(db, needRetailer(db, false).id))
    },

    notifications: {
      list: call(db => { const u = currentUser(db); if (!u) throw new ApiError('Please sign in.', { code: 'auth', status: 401 }); const to = u.kind === 'staff' ? 'staff' : u.id; return db.notifications.filter(n => n.to === to); }),
      readAll: call(db => { const u = currentUser(db); if (!u) return; const to = u.kind === 'staff' ? 'staff' : u.id; db.notifications.filter(n => n.to === to).forEach(n => { n.read = true; }); save(db); })
    },

    admin: {
      dashboard: call(db => {
        const u = needStaff(db, 'dashboard');
        const today = new Date(); today.setHours(0, 0, 0, 0);
        const low = [];
        db.products.forEach(p => Object.keys(p.stock).forEach(k => {
          const a = Math.max(0, p.stock[k] - (p.held[k] || 0));
          if (a <= db.settings.lowStock) low.push({ product: p.name, productId: p.id, variant: k.replace('|', ' / '), available: a });
        }));
        const live = db.orders.filter(o => !['Cancelled', 'Expired'].includes(o.status));
        return {
          role: u.role,
          ordersToday: db.orders.filter(o => new Date(o.createdAt) >= today).length,
          openOrders: db.orders.filter(o => !['Paid in full', 'Cancelled', 'Expired', 'Delivered'].includes(o.status)).length,
          awaitingVerification: db.orders.flatMap(o => o.payments).filter(p => p.status === 'submitted').length,
          awaitingAdvance: db.orders.filter(o => o.status === 'Awaiting advance').length,
          moneyToCollect: live.reduce((s, o) => s + outstanding(o), 0),
          pendingRetailers: db.retailers.filter(r => r.status === 'pending').length,
          openQuotes: db.quotes.filter(q => q.status === 'Quote requested').length,
          newEnquiries: db.enquiries.filter(e => e.status === 'New').length,
          readyToDispatch: db.orders.filter(o => o.status === 'Packing' || o.status === 'Confirmed').length,
          lowStock: low.sort((a, b) => a.available - b.available).slice(0, 6), lowStockCount: low.length,
          recent: db.orders.slice().sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)).slice(0, 6)
        };
      }),
      counts: call(db => {
        needStaff(db);
        return { retailers: db.retailers.filter(r => r.status === 'pending').length, enquiries: db.enquiries.filter(e => e.status === 'New').length, quotes: db.quotes.filter(q => q.status === 'Quote requested').length, payments: db.orders.flatMap(o => o.payments).filter(p => p.status === 'submitted').length, dispatch: db.orders.filter(o => o.status === 'Packing').length };
      }),

      retailers: call(db => { needStaff(db, 'retailers'); return db.retailers.map(({ password, ...r }) => ({ ...r, orders: db.orders.filter(o => o.retailerId === r.id).length, outstanding: db.orders.filter(o => o.retailerId === r.id).reduce((s, o) => s + outstanding(o), 0) })); }),
      retailer: call((db, id) => {
        needStaff(db, 'retailers');
        const r = db.retailers.find(x => x.id === id);
        if (!r) throw new ApiError('Retailer not found.', { code: 'not_found', status: 404 });
        const { password, ...safe } = r;
        return { ...safe, orders: db.orders.filter(o => o.retailerId === id).map(o => ({ ...o, outstanding: outstanding(o) })), statement: statement(db, id) };
      }),
      decideRetailer: call((db, id, { decision, reason }) => {
        const u = needStaff(db, 'retailers');
        if (!['Owner', 'Sales', 'Administrator'].includes(u.role)) throw new ApiError('Your role cannot approve retailers.', { code: 'forbidden' });
        const r = db.retailers.find(x => x.id === id);
        if (!r) throw new ApiError('Retailer not found.');
        if (decision !== 'approved' && !(reason || '').trim()) throw new ApiError('A reason is required.', { fields: { reason: 'A reason is required.' } });
        r.status = decision; r.rejectReason = decision === 'approved' ? null : reason.trim();
        if (decision === 'approved') r.approvedAt = iso(now());
        audit(db, u.name, 'Retailer ' + decision, r.company, reason || '');
        notify(db, r.id, decision === 'approved' ? 'Your trade account is approved. You can now see prices and order.' : 'Update on your trade account application.', 'account.html');
        save(db);
      }),

      enquiries: call(db => { needStaff(db, 'enquiries'); return db.enquiries.slice().sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)); }),
      updateEnquiry: call((db, id, { status, note, followUp }) => {
        const u = needStaff(db, 'enquiries'), e = db.enquiries.find(x => x.id === id);
        if (!e) throw new ApiError('Enquiry not found.');
        if (status) e.status = status;
        if (followUp !== undefined) e.followUp = followUp || null;
        if (note && note.trim()) e.notes.push({ at: iso(now()), by: u.name, text: note.trim() });
        audit(db, u.name, 'Updated enquiry', e.number, status || '');
        save(db);
      }),

      quotes: call(db => { needStaff(db, 'quotes'); return db.quotes.slice().sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)); }),
      quote: call((db, id) => {
        needStaff(db, 'quotes');
        const q = db.quotes.find(x => x.id === id);
        if (!q) throw new ApiError('Quote not found.', { code: 'not_found', status: 404 });
        return q;
      }),
      sendOffer: call((db, id, { prices, message }) => {
        const u = needStaff(db, 'quotes'), q = db.quotes.find(x => x.id === id);
        if (!q) throw new ApiError('Quote not found.');
        if (!['Quote requested', 'Quote ready'].includes(q.status)) throw new ApiError('This quote can no longer be changed.');
        q.lines.forEach((l, i) => {
          const v = Number(prices[i]);
          if (!(v > 0)) throw new ApiError('Enter a price for every line.');
          l.offerPrice = v;
        });
        q.status = 'Quote ready';
        q.validUntil = iso(now() + db.settings.quoteValidityDays * DAY);
        q.messages.push({ from: 'staff', by: u.name, text: (message || '').trim() || 'Our offer is ready for you.', at: iso(now()) });
        audit(db, u.name, 'Sent quote offer', q.number, '');
        notify(db, q.retailerId, 'Your quote ' + q.number + ' is ready to review', 'account-quote.html?id=' + q.id);
        save(db);
      }),

      orders: call(db => { needStaff(db, 'orders'); return db.orders.slice().sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)).map(o => ({ ...o, paid: paidOn(o), outstanding: outstanding(o) })); }),
      order: call((db, id) => {
        needStaff(db, 'orders');
        const o = db.orders.find(x => x.id === id);
        if (!o) throw new ApiError('Order not found.', { code: 'not_found', status: 404 });
        return { ...o, paid: paidOn(o), outstanding: outstanding(o) };
      }),
      setOrderStatus: call((db, id, next) => {
        const u = needStaff(db, 'orders'), o = db.orders.find(x => x.id === id);
        if (!o) throw new ApiError('Order not found.');
        const moves = {
          Confirmed: { to: ['Packing'], roles: ['Owner', 'Warehouse'] }, Delivered: { to: [], roles: [] },
          Dispatched: { to: ['Delivered'], roles: ['Owner', 'Warehouse'] },
          'Production authorised': { to: ['In production'], roles: ['Owner', 'Sales'] },
          'In production': { to: ['Awaiting balance'], roles: ['Owner', 'Sales'] }
        }[o.status];
        if (!moves || !moves.to.includes(next)) throw new ApiError('That status change is not allowed from ' + o.status + '.');
        if (!moves.roles.includes(u.role)) throw new ApiError('Your role cannot make this change.', { code: 'forbidden' });
        o.status = next;
        o.history.push({ status: next, at: iso(now()), by: u.name, note: '' });
        if (next === 'Delivered' && o.type === 'standard' && outstanding(o) === 0) {
          o.status = 'Paid in full';
          o.history.push({ status: 'Paid in full', at: iso(now()), by: 'System', note: '' });
        }
        audit(db, u.name, 'Changed order status to ' + next, o.number, '');
        notify(db, o.retailerId, 'Order ' + o.number + ': ' + next, 'account-order.html?id=' + o.id);
        save(db);
      }),
      authoriseProduction: call((db, id) => {
        const u = needStaff(db, 'orders'), o = db.orders.find(x => x.id === id);
        if (!o || o.type !== 'custom') throw new ApiError('Order not found.');
        if (!['Owner', 'Sales'].includes(u.role)) throw new ApiError('Your role cannot authorise production.', { code: 'forbidden' });
        if (!o.artwork || o.artwork.status !== 'approved') throw new ApiError('Artwork must be approved first.');
        if (!o.payments.some(p => p.kind === 'advance' && p.status === 'verified')) throw new ApiError('The advance must be verified first.');
        if (o.status !== 'Awaiting advance') throw new ApiError('This order is not ready for production.');
        o.status = 'Production authorised';
        o.history.push({ status: 'Production authorised', at: iso(now()), by: u.name, note: 'Artwork approved and advance verified' });
        audit(db, u.name, 'Authorised production', o.number, '');
        save(db);
      }),
      sendArtwork: call((db, id, note) => {
        const u = needStaff(db, 'orders'), o = db.orders.find(x => x.id === id);
        if (!o || o.type !== 'custom') throw new ApiError('Order not found.');
        o.artwork = { status: 'awaiting', version: (o.artwork ? o.artwork.version : 0) + 1, image: o.artwork ? o.artwork.image : o.lines[0].image, note: (note || '').trim(), at: iso(now()), reply: null };
        o.status = 'Artwork awaiting approval';
        o.history.push({ status: 'Artwork sent (version ' + o.artwork.version + ')', at: iso(now()), by: u.name, note: '' });
        notify(db, o.retailerId, 'New artwork proof on ' + o.number, 'account-order.html?id=' + o.id);
        save(db);
      }),
      holdOrder: call((db, id, reason) => {
        const u = needStaff(db, 'orders'), o = db.orders.find(x => x.id === id);
        if (!o) throw new ApiError('Order not found.');
        if (!(reason || '').trim()) throw new ApiError('A reason is required.', { fields: { reason: 'A reason is required.' } });
        if (['Delivered', 'Paid in full', 'Cancelled', 'Expired', 'On hold'].includes(o.status)) throw new ApiError('This order cannot be put on hold.');
        o.prevStatus = o.status; o.status = 'On hold';
        o.history.push({ status: 'On hold', at: iso(now()), by: u.name, note: reason.trim() });
        audit(db, u.name, 'Put order on hold', o.number, reason.trim());
        save(db);
      }),
      resumeOrder: call((db, id) => {
        const u = needStaff(db, 'orders'), o = db.orders.find(x => x.id === id);
        if (!o || o.status !== 'On hold') throw new ApiError('This order is not on hold.');
        o.status = o.prevStatus; delete o.prevStatus;
        o.history.push({ status: 'Resumed: ' + o.status, at: iso(now()), by: u.name, note: '' });
        audit(db, u.name, 'Resumed order', o.number, '');
        save(db);
      }),
      cancelOrder: call((db, id, reason) => {
        const u = needStaff(db, 'orders'), o = db.orders.find(x => x.id === id);
        if (!o) throw new ApiError('Order not found.');
        if (!['Owner', 'Sales'].includes(u.role)) throw new ApiError('Your role cannot cancel orders.', { code: 'forbidden' });
        if (!(reason || '').trim()) throw new ApiError('A reason is required.', { fields: { reason: 'A reason is required.' } });
        if (['Dispatched', 'Delivered', 'Paid in full', 'Cancelled', 'Expired'].includes(o.status)) throw new ApiError('This order can no longer be cancelled.');
        hold(db, o, -1);
        o.status = 'Cancelled'; o.holdUntil = null;
        o.history.push({ status: 'Cancelled', at: iso(now()), by: u.name, note: reason.trim() });
        audit(db, u.name, 'Cancelled order', o.number, reason.trim());
        notify(db, o.retailerId, 'Order ' + o.number + ' was cancelled', 'account-order.html?id=' + o.id);
        save(db);
      }),

      payments: call(db => {
        needStaff(db, 'payments');
        return db.orders.flatMap(o => o.payments.map(p => ({ ...p, orderId: o.id, orderNumber: o.number, company: o.company, orderValue: o.subtotal }))).sort((a, b) => new Date(b.at) - new Date(a.at));
      }),
      verifyPayment: call((db, orderId, payId, { ok, reason }) => {
        const u = needStaff(db, 'payments'), o = db.orders.find(x => x.id === orderId);
        if (!['Owner', 'Finance'].includes(u.role)) throw new ApiError('Only finance can verify payments.', { code: 'forbidden' });
        const p = o && o.payments.find(x => x.id === payId);
        if (!p || p.status !== 'submitted') throw new ApiError('This payment is not waiting for verification.');
        if (!ok && !(reason || '').trim()) throw new ApiError('A reason is required.', { fields: { reason: 'A reason is required.' } });
        p.status = ok ? 'verified' : 'rejected'; p.by = u.name; p.reason = ok ? null : reason.trim();
        if (ok && p.kind === 'advance' && o.status === 'Awaiting advance') {
          o.holdUntil = null;
          if (o.type === 'custom') {
            // Stays here until staff authorise production: artwork and advance are separate recorded events.
            o.history.push({ status: 'Advance verified', at: iso(now()), by: u.name, note: 'Ready for production authorisation' });
          } else {
            o.status = 'Confirmed';
            o.history.push({ status: 'Confirmed', at: iso(now()), by: u.name, note: 'Advance verified against bank statement' });
          }
        } else if (ok && p.kind === 'balance') {
          balanceSettled(o, u.name);
        } else if (!ok) {
          o.history.push({ status: 'Payment reference rejected', at: iso(now()), by: u.name, note: reason.trim() });
        }
        audit(db, u.name, ok ? 'Verified payment' : 'Rejected payment', o.number, p.ref);
        notify(db, o.retailerId, ok ? 'Payment verified on ' + o.number : 'Payment reference rejected on ' + o.number, 'account-order.html?id=' + o.id);
        save(db);
      }),
      recordBalance: call((db, id, { amount, method, ref }) => {
        const u = needStaff(db, 'payments'), o = db.orders.find(x => x.id === id);
        if (!['Owner', 'Finance'].includes(u.role)) throw new ApiError('Only finance can record payments.', { code: 'forbidden' });
        if (!o) throw new ApiError('Order not found.');
        validateFields({ ref, method }, { ref: { required: true }, method: { required: true } });
        const amt = Number(amount);
        if (!(amt > 0) || amt > outstanding(o)) throw new ApiError('Amount must not exceed the balance due.', { fields: { amount: 'Amount must not exceed the balance due.' } });
        o.payments.push({ id: 'pay-' + (++db.seq.payment), kind: 'balance', amount: amt, method, ref: ref.trim(), status: 'verified', at: iso(now()), by: u.name, reason: null });
        balanceSettled(o, u.name);
        audit(db, u.name, 'Recorded balance payment', o.number, ref.trim());
        save(db);
      }),

      dispatch: call(db => { needStaff(db, 'dispatch'); return db.orders.filter(o => ['Confirmed', 'Packing', 'Awaiting balance', 'Dispatched'].includes(o.status)); }),
      shipOrder: call((db, id, v) => {
        const u = needStaff(db, 'dispatch'), o = db.orders.find(x => x.id === id);
        if (!o) throw new ApiError('Order not found.');
        validateFields(v, { courier: { required: true }, lr: { required: true } });
        const ready = o.type === 'custom' ? (o.status === 'Awaiting balance' && outstanding(o) === 0) : o.status === 'Packing';
        if (!ready) throw new ApiError(o.type === 'custom' ? 'The balance must be verified before dispatch.' : 'Only orders in Packing can be dispatched.');
        o.lines.forEach(l => {
          const p = db.products.find(x => x.id === l.productId), k = l.colour + '|' + l.size;
          if (p) { p.stock[k] = Math.max(0, (p.stock[k] || 0) - l.qty); p.held[k] = Math.max(0, (p.held[k] || 0) - l.qty); }
        });
        o.shipment = { courier: v.courier.trim(), lr: v.lr.trim(), url: (v.url || '').trim(), date: iso(now()) };
        o.status = 'Dispatched';
        o.history.push({ status: 'Dispatched', at: iso(now()), by: u.name, note: v.courier.trim() + ', ' + v.lr.trim() });
        audit(db, u.name, 'Dispatched order', o.number, v.lr.trim());
        notify(db, o.retailerId, 'Order ' + o.number + ' dispatched: ' + v.lr.trim(), 'account-order.html?id=' + o.id);
        save(db);
      }),

      products: call(db => { needStaff(db, 'products'); return db.products.map(p => { const v = publicProduct(p, { kind: 'staff' }); return { ...v, status: p.status }; }); }),
      product: call((db, id) => {
        needStaff(db, 'products');
        const p = db.products.find(x => x.id === id);
        if (!p) throw new ApiError('Product not found.', { code: 'not_found', status: 404 });
        return p;
      }),
      saveProduct: call((db, v) => {
        const u = needStaff(db, 'products');
        validateFields(v, { name: { required: true }, style: { required: true }, category: { required: true }, price: { required: true, pattern: /^\d+(\.\d{1,2})?$/, message: 'Enter a price in rupees.' } });
        let p = db.products.find(x => x.id === v.id);
        const data = { name: v.name.trim(), style: v.style.trim(), category: v.category, gender: v.gender, price: Number(v.price), summary: (v.summary || '').trim(), description: (v.description || '').trim(), status: v.status, customisable: !!v.customisable, isNew: !!v.isNew };
        if (p) Object.assign(p, data);
        else {
          const colourName = (v.colour || 'Black').trim();
          const sizes = String(v.sizes || 'S,M,L,XL').split(',').map(s => s.trim().toUpperCase()).filter(Boolean);
          const stockMap = {}; sizes.forEach(s => { stockMap[colourName + '|' + s] = 0; });
          p = { id: uid('p'), slug: data.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') + '-' + Math.random().toString(36).slice(2, 5), features: [], colours: [{ name: colourName, hex: '#888888', code: colourName.slice(0, 3).toUpperCase(), images: ['assets/img/brand/mark-navy.png'] }], sizes, stock: stockMap, held: {}, ...data };
          db.products.push(p);
        }
        audit(db, u.name, 'Saved product', p.name, '');
        save(db);
        return { id: p.id };
      }),

      inventory: call(db => {
        needStaff(db, 'inventory');
        return db.products.map(p => ({ id: p.id, name: p.name, style: p.style, image: p.colours[0].images[0], rows: Object.keys(p.stock).map(k => { const [colour, size] = k.split('|'); return { colour, size, onHand: p.stock[k], held: p.held[k] || 0, available: Math.max(0, p.stock[k] - (p.held[k] || 0)) }; }) }));
      }),
      adjustStock: call((db, { productId, colour, size, change, reason, note }) => {
        const u = needStaff(db, 'inventory'), p = db.products.find(x => x.id === productId);
        if (!p) throw new ApiError('Product not found.');
        const k = colour + '|' + size, c = Number(change);
        const fields = {};
        if (!Number.isInteger(c) || c === 0) fields.change = 'Enter a whole number, plus or minus.';
        if (!reason) fields.reason = 'A reason is required.';
        if (Object.keys(fields).length) throw new ApiError('Please correct the highlighted fields.', { code: 'validation', fields });
        const after = (p.stock[k] || 0) + c;
        if (after < (p.held[k] || 0)) throw new ApiError('Stock cannot go below the quantity held for orders (' + (p.held[k] || 0) + ').', { fields: { change: 'Too low: ' + (p.held[k] || 0) + ' are held for orders.' } });
        p.stock[k] = after;
        db.stockLog.unshift({ id: uid('sl'), at: iso(now()), by: u.name, product: p.name, variant: colour + ' / ' + size, change: c, after, reason, note: (note || '').trim() });
        audit(db, u.name, 'Stock correction', p.name + ' ' + colour + ' ' + size, (c > 0 ? '+' : '') + c + ', ' + reason);
        save(db);
      }),
      stockLog: call(db => { needStaff(db, 'inventory'); return db.stockLog; }),

      staff: call(db => { needStaff(db, 'staff'); return db.staff.map(({ password, ...s }) => s); }),
      saveStaff: call((db, v) => {
        const u = needStaff(db, 'staff');
        validateFields(v, { name: { required: true }, email: { required: true, pattern: EMAIL, message: 'Enter a valid email address.' }, role: { required: true } });
        const s = db.staff.find(x => x.id === v.id);
        if (s) { s.name = v.name.trim(); s.role = v.role; }
        else {
          if (db.staff.some(x => x.email.toLowerCase() === v.email.trim().toLowerCase())) throw new ApiError('This email already has a staff login.', { fields: { email: 'This email already has a staff login.' } });
          db.staff.push({ id: uid('s'), name: v.name.trim(), email: v.email.trim(), password: 'Demo@123', role: v.role, active: true });
        }
        audit(db, u.name, 'Saved staff user', v.email, v.role);
        save(db);
      }),
      toggleStaff: call((db, id) => {
        const u = needStaff(db, 'staff'), s = db.staff.find(x => x.id === id);
        if (!s) throw new ApiError('User not found.');
        if (s.id === u.id) throw new ApiError('You cannot deactivate your own login.');
        s.active = !s.active;
        audit(db, u.name, s.active ? 'Reactivated staff user' : 'Deactivated staff user', s.email, '');
        save(db);
      }),

      allSettings: call(db => { needStaff(db, 'settings'); return db.settings; }),
      saveSettings: call((db, v) => {
        const u = needStaff(db, 'settings');
        const nums = ['moq', 'customMoq', 'advancePct', 'customAdvancePct', 'holdHours', 'quoteValidityDays', 'lowStock'];
        const fields = {};
        nums.forEach(k => { if (!(Number(v[k]) >= 0) || v[k] === '') fields[k] = 'Enter a number.'; });
        ['advancePct', 'customAdvancePct'].forEach(k => { if (Number(v[k]) > 100) fields[k] = 'Must be 100 or less.'; });
        if (Object.keys(fields).length) throw new ApiError('Please correct the highlighted fields.', { code: 'validation', fields });
        nums.forEach(k => { db.settings[k] = Number(v[k]); });
        db.settings.moqEnabled = !!v.moqEnabled; db.settings.moqOnQuotes = !!v.moqOnQuotes;
        db.settings.moqMode = v.moqMode; db.settings.shortageNote = v.shortageNote;
        audit(db, u.name, 'Changed settings', 'Business settings', '');
        save(db);
      }),

      audit: call(db => { needStaff(db, 'audit'); return db.audit; }),

      reports: call(db => {
        needStaff(db, 'reports');
        const live = db.orders.filter(o => !['Cancelled', 'Expired'].includes(o.status));
        const month = {}, byProduct = {}, byRetailer = {};
        live.forEach(o => {
          const d = new Date(o.createdAt), k = d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0');
          month[k] = (month[k] || 0) + o.subtotal;
          byRetailer[o.company] = byRetailer[o.company] || { company: o.company, billed: 0, paid: 0, outstanding: 0, orders: 0 };
          const r = byRetailer[o.company]; r.billed += o.subtotal; r.paid += paidOn(o); r.outstanding += outstanding(o); r.orders += 1;
          o.lines.forEach(l => { byProduct[l.name] = (byProduct[l.name] || 0) + l.qty; });
        });
        return {
          sales: live.reduce((s, o) => s + o.subtotal, 0), collected: live.reduce((s, o) => s + paidOn(o), 0), outstanding: live.reduce((s, o) => s + outstanding(o), 0), orders: live.length,
          months: Object.keys(month).sort().map(k => ({ month: k, value: month[k] })),
          products: Object.keys(byProduct).map(k => ({ name: k, pieces: byProduct[k] })).sort((a, b) => b.pieces - a.pieces),
          retailers: Object.values(byRetailer).sort((a, b) => b.outstanding - a.outstanding)
        };
      })
    }
  };

  function balanceSettled(o, by) {
    const paid = paidOn(o);
    if (paid + 0.005 < o.subtotal) { o.history.push({ status: 'Part payment recorded', at: iso(now()), by, note: '' }); return; }
    if (o.type === 'standard' && o.status === 'Delivered') {
      o.status = 'Paid in full';
      o.history.push({ status: 'Paid in full', at: iso(now()), by, note: '' });
    } else {
      o.history.push({ status: 'Balance received', at: iso(now()), by, note: '' });
    }
  }

  VK7.api = api;
})();
