/* VK7.api is the only way pages talk to data. Every method calls /api/v1 and returns the shapes
   the pages expect. The server enforces every rule; nothing here decides a price, stock or minimum. */
(function () {
  const VK7 = window.VK7 = window.VK7 || {}, CFG = window.VK7_CONFIG;

  class ApiError extends Error {
    constructor(message, opts = {}) { super(message); this.name = 'ApiError'; this.code = opts.code || 'error'; this.fields = opts.fields || null; this.status = opts.status || 400; }
  }
  VK7.ApiError = ApiError;
  VK7.FLOWS = { standard: ['Awaiting advance', 'Confirmed', 'Packing', 'Dispatched', 'Delivered', 'Paid in full'] };
  VK7.api = { auth: {}, catalog: {}, cart: {}, quotes: {}, checkout: {}, orders: {}, enquiries: {}, account: {}, notifications: {} };

  const PAGE = document.body.dataset.page || '';

  const { api } = VK7;
  const STAFF_PAGE = PAGE.startsWith('admin');
  const TOKEN = STAFF_PAGE ? 'vk7.live.staff' : 'vk7.live.token';
  const PLACEHOLDER = 'assets/img/brand/mark-navy.png';
  const NOT_YET = 'This is not available online yet. Please contact sales.';

  const token = {
    get() { try { return localStorage.getItem(TOKEN); } catch (e) { return null; } },
    set(v) { try { localStorage.setItem(TOKEN, v); } catch (e) { /* the session ends with the page */ } },
    del() { try { localStorage.removeItem(TOKEN); } catch (e) { /* nothing stored */ } }
  };

  /* Sends one request and turns any failure into the ApiError the pages already handle. */
  async function http(method, path, body, fieldNames = {}) {
    if (/\/(null|undefined)(\/|$)/.test(path)) throw new ApiError('We could not find that.', { code: 'not_found', status: 404 });
    const form = body instanceof FormData, headers = { Accept: 'application/json' };
    if (body && !form) headers['Content-Type'] = 'application/json';
    if (token.get()) headers.Authorization = 'Bearer ' + token.get();
    let res;
    try {
      res = await fetch(CFG.apiBase + path, { method, headers, body: form ? body : body ? JSON.stringify(body) : undefined });
    } catch (e) {
      throw new ApiError('We could not reach the server. Please check your connection and try again.', { code: 'network', status: 0 });
    }
    const data = await res.json().catch(() => ({}));
    if (res.ok) return data;
    if (res.status === 401 && !path.startsWith('/auth/login')) token.del();
    const fields = {};
    Object.entries(data.errors || {}).forEach(([k, v]) => { fields[fieldNames[k] || k] = v[0]; });
    const message = res.status === 422 && data.errors ? 'Please correct the highlighted fields.' : data.message || 'Something went wrong. Please try again.';
    throw new ApiError(message, { code: data.code || 'error', status: res.status, fields: data.errors ? fields : null });
  }

  const splitName = full => {
    const parts = String(full || '').trim().split(/\s+/);
    return { first_name: parts[0] || '', last_name: parts.slice(1).join(' ') || parts[0] || '' };
  };
  const firstNumber = v => { const m = String(v || '').match(/\d+/); return m ? Number(m[0]) : null; };
  const priceOf = prices => prices ? Number(prices.final.price) : undefined;
  const option = (item, code) => (item.options && item.options[code] && item.options[code].option_label) || '';

  /* --- Catalogue --- */
  function product(p) {
    const attrs = (p.grid && p.grid.attributes) || [];
    const colourAttr = attrs.find(a => a.code === 'color'), sizeAttr = attrs.find(a => a.code === 'size');
    const colourOptions = colourAttr ? colourAttr.options : [], sizeOptions = sizeAttr ? sizeAttr.options : [];
    const images = p.images && p.images.length ? p.images : [p.base_image || PLACEHOLDER];
    const available = {}, variantIds = {}, colourImages = {};
    ((p.grid && p.grid.variants) || []).forEach(v => {
      const c = colourOptions.find(o => o.id === v.options.color), s = sizeOptions.find(o => o.id === v.options.size);
      if (!c || !s) return;
      const key = c.label + '|' + s.label;
      available[key] = v.stock == null ? (v.in_stock ? 1 : 0) : v.stock;
      variantIds[key] = v.id;
      if (v.images && v.images.length) colourImages[c.label] = v.images;
    });
    const out = {
      id: String(p.id), slug: p.url_key, style: p.sku, name: p.name, summary: p.short_description || '', description: p.description || p.short_description || '',
      category: (p.categories || [])[0] || '', gender: '', kind: '', features: [], isNew: false, customisable: true, status: 'active',
      sizes: sizeOptions.map(o => o.label),
      colours: colourOptions.map(o => ({ name: o.label, hex: o.swatch || '#CBD5E1', code: String(o.id), images: colourImages[o.label] || images })),
      available, variantIds, totalAvailable: Object.values(available).reduce((a, b) => a + b, 0)
    };
    if (p.prices) out.price = priceOf(p.prices);
    return out;
  }

  const listCache = new Map();
  const allProducts = async q => {
    const key = q || '';
    if (!listCache.has(key)) listCache.set(key, http('GET', '/products?include_grid=1&limit=100' + (q ? '&q=' + encodeURIComponent(q) : '')));
    return (await listCache.get(key)).data.map(product);
  };
  const findProduct = async id => product((await http('GET', '/products/' + encodeURIComponent(id))).data);
  const skuRows = list => list.flatMap(p => p.colours.flatMap(c => p.sizes.filter(s => p.variantIds[c.name + '|' + s]).map(s => ({ sku: p.style + '-' + c.code + '-' + s, productId: p.id, name: p.name, colour: c.name, size: s }))));

  /* --- Cart --- */
  function cartView(cart, moqFallback) {
    const items = cart ? cart.items : [];
    const lines = items.map(i => ({
      id: i.id, productId: String(i.product_id), variantId: i.variant_id, name: i.name, style: i.sku, sku: i.sku, slug: i.url_key, colour: option(i, 'color'), size: option(i, 'size'),
      qty: i.qty, unitPrice: i.price, image: i.image || PLACEHOLDER, available: i.available, short: Math.max(0, i.qty - i.available), locked: i.locked_by_quote
    }));
    const groups = {};
    lines.forEach(l => {
      const g = groups[l.productId] = groups[l.productId] || { productId: l.productId, name: l.name, style: l.style, slug: l.slug, image: l.image, lines: [], pieces: 0, value: 0 };
      g.lines.push(l); g.pieces += l.qty; g.value += l.qty * l.unitPrice;
    });
    const moq = (cart && cart.moq) || moqFallback || {};
    const list = Object.values(groups);
    const violations = (moq.shortfalls || []).map(s => ({ label: s.label, need: s.needed, productId: (list.find(g => g.name === s.label) || {}).productId || null }));
    return {
      groups: list, lines, pieces: lines.reduce((s, l) => s + l.qty, 0), subtotal: lines.reduce((s, l) => s + l.qty * l.unitPrice, 0), violations, shortages: lines.filter(l => l.short > 0),
      advancePct: null, advanceDue: null, balanceDue: null, moq: moq.min_qty, moqMode: moq.mode, moqEnabled: moq.enabled
    };
  }
  const getCart = async () => cartView((await http('GET', '/cart')).data);

  const variantLine = (p, colour, size, qty) => {
    const id = p.variantIds[colour + '|' + size];
    if (!id) throw new ApiError('That size or colour is not available.');
    return { product_id: Number(p.id), variant_id: id, qty };
  };

  /* --- Addresses and account --- */
  const address = a => ({ id: a.id, label: a.label, line1: a.line1, city: a.city, state: a.state, pin: a.pin, phone: a.phone, isDefault: a.is_default });
  const addressBody = v => ({ label: v.label, line1: v.line1, city: v.city, state: v.state, pin: v.pin, phone: v.phone });
  const accountView = a => ({
    id: a.id, status: 'approved', company: a.business_name || '', contact: (a.first_name + ' ' + a.last_name).trim(), email: a.email, phone: a.phone, appliedAt: a.created_at,
    gstin: (a.addresses.find(x => x.gstin) || {}).gstin || '', proof: '', shopType: '', rejectReason: null, priceList: 'Standard',
    addresses: a.addresses.map(address), users: [{ id: a.id, name: (a.first_name + ' ' + a.last_name).trim(), email: a.email, role: 'Owner' }]
  });

  /* --- Quotes --- */
  function quoteStatus(q) {
    if (q.status === 'open' || q.status === 'draft') return 'Quote requested';
    if (q.status === 'negotiation') return q.can_accept ? 'Quote ready' : 'Quote requested';
    return { accepted: 'Accepted', ordered: 'Ordered', completed: 'Ordered', rejected: 'Declined', expired: 'Expired' }[q.status] || q.status;
  }
  const quoteView = q => ({
    id: q.id, number: q.quotation_number, status: quoteStatus(q), company: '', note: q.description || '', validUntil: q.expiration_date, createdAt: q.created_at, orderId: q.order_id, shortageAcknowledged: false,
    lines: (q.items || []).map(i => ({
      productId: String(i.product_id), name: i.name, style: i.sku, sku: i.sku, colour: option(i, 'color'), size: option(i, 'size'), qty: i.negotiated_qty || i.qty, unitPrice: i.price, listPrice: i.price,
      offerPrice: i.negotiated_price !== i.price ? i.negotiated_price : null, image: PLACEHOLDER
    })),
    messages: (q.messages || []).map(m => ({ from: m.from === 'customer' ? 'retailer' : 'staff', by: m.from === 'customer' ? 'You' : 'VK7SPORTS', text: m.message, at: m.created_at }))
  });
  const allQuotes = async () => (await http('GET', '/quotes?limit=100')).data.map(quoteView);

  /* --- Orders --- */
  const paymentView = p => ({ id: p.id, kind: p.kind, amount: p.amount, method: p.method, ref: p.reference || '', status: p.status, at: p.created_at, by: p.reviewed_by, reason: p.reject_reason });
  function orderView(o) {
    const shipment = (o.shipments || [])[0], f = o.finance || {};
    const status = f.stage || o.stage;
    const history = [{ status: 'Order placed', at: o.created_at, by: 'You', note: '' }];
    (f.payments || []).filter(p => p.status === 'verified').forEach(p => history.push({ status: (p.kind === 'advance' ? 'Advance' : 'Balance') + ' received', at: p.created_at, by: '', note: '' }));
    ((o.tracking && o.tracking.events) || []).forEach(e => history.push({ status: e.status, at: e.occurred_at, by: e.location, note: '' }));
    (o.comments || []).forEach(c => history.push({ status: 'Note', at: c.created_at, by: '', note: c.comment }));
    const reference = (o.comments || []).find(c => c.comment.startsWith('Retailer reference: '));
    return {
      id: o.id, number: o.order_number, type: 'standard', status, createdAt: o.created_at, subtotal: f.total, holdUntil: f.hold_until, advancePct: f.advance_percent, advanceDue: f.advance_due, balanceDue: f.balance_due,
      paid: f.paid, outstanding: f.outstanding, payable: f.payable || null, gateway: f.gateway, payments: (f.payments || []).map(paymentView), tracking: o.tracking || null, artwork: null, quoteId: null, history, poRef: reference ? reference.comment.slice(20) : '', notes: '', company: '',
      address: o.address || { label: '', line1: '', city: '', state: '', pin: '', phone: '' },
      shipment: shipment ? { courier: shipment.carrier || '', lr: shipment.track_number || '', date: shipment.created_at, url: '' } : null,
      lines: (o.items || []).map(i => ({ productId: String(i.product_id), variantId: i.variant_id, name: i.name, style: i.sku, sku: i.sku, colour: option(i, 'color'), size: option(i, 'size'), qty: i.qty_ordered, unitPrice: i.price, image: PLACEHOLDER }))
    };
  }
  const orderDetail = async id => orderView((await http('GET', '/orders/' + id)).data);
  const allOrders = async () => {
    const list = (await http('GET', '/orders?limit=100')).data;
    return Promise.all(list.map(o => orderDetail(o.id)));
  };

  /* --- Public methods, same names and shapes as the demo in api.js --- */
  let metaCache = null;
  const meta = () => (metaCache = metaCache || http('GET', '/meta').then(r => r.data));

  api.settings = async () => {
    const { moq, payments } = (await meta());
    return { moqEnabled: moq.enabled, moq: moq.min_qty, moqMode: moq.mode, customMoq: 100, advancePct: payments.advance_percent, customAdvancePct: 80, holdHours: payments.hold_hours, quoteValidityDays: 7, shortageNote: 'Additional stock may need a replenishment period. Please ask sales.' };
  };

  const applyCompany = async () => {
    const m = await meta();
    const fill = (target, source) => Object.keys(source || {}).forEach(k => { target[k] = source[k] || null; });
    fill(CFG.contact, m.company);
    fill(CFG.payment, m.bank);
  };

  api.auth.me = async () => {
    await applyCompany();
    if (!token.get()) return null;
    if (STAFF_PAGE) {
      try {
        const u = (await http('GET', '/admin/me')).data;
        return { kind: 'staff', id: u.id, name: u.name, email: u.email, role: u.role, areas: u.areas, perms: [...u.areas, 'notifications'], unread: 0 };
      } catch (e) {
        if (e.status === 401) return null;
        throw e;
      }
    }
    try {
      const u = (await http('GET', '/auth/me')).data;
      return { kind: 'retailer', id: u.id, name: (u.first_name + ' ' + u.last_name).trim(), company: u.company ? u.company.business_name : '', email: u.email, status: 'approved', approved: true, cartCount: u.cart_count, unread: 0 };
    } catch (e) {
      if (e.status === 401) return null;
      throw e;
    }
  };
  api.auth.login = async ({ email, password }) => {
    const res = await http('POST', '/auth/login', { email, password });
    token.set(res.token);
    return { status: 'approved' };
  };
  api.auth.staffLogin = async ({ email, password }) => {
    const res = await http('POST', '/admin/login', { email, password });
    token.set(res.token);
    return { role: res.data.role };
  };
  api.auth.logout = async () => { try { await http('POST', STAFF_PAGE ? '/admin/logout' : '/auth/logout'); } finally { token.del(); } };
  api.auth.register = async v => {
    if (v.password !== v.confirm) throw new ApiError('Please correct the highlighted fields.', { code: 'validation', fields: { confirm: 'The passwords do not match.' } });
    if (!v.agree) throw new ApiError('Please correct the highlighted fields.', { code: 'validation', fields: { agree: 'Please accept to continue.' } });
    if (!v.gstin && !(v.proof || '').trim()) throw new ApiError('Please correct the highlighted fields.', { code: 'validation', fields: { proof: 'Enter a GSTIN, or name another proof of business.' } });
    const res = await http('POST', '/auth/register', {
      ...splitName(v.contact), business_name: v.company, email: v.email, phone: v.phone, password: v.password, password_confirmation: v.confirm,
      shop_type: v.shopType, gstin: v.gstin, proof: v.proof, label: 'Main shop', line1: v.address, city: v.city, state: v.state, pin: v.pin
    }, { business_name: 'company', first_name: 'contact', last_name: 'contact', password_confirmation: 'confirm', line1: 'address' });
    return { pending: res.data.approval === 'pending' };
  };
  api.auth.forgot = async ({ email }) => (await http('POST', '/auth/forgot', { email })).data;

  api.catalog.categories = async () => {
    const [cats, products] = await Promise.all([http('GET', '/categories'), allProducts()]);
    return cats.data.map(c => {
      const inside = products.filter(p => p.category === c.slug);
      return { id: c.slug, name: c.name, image: inside.length ? inside[0].colours[0]?.images[0] || PLACEHOLDER : PLACEHOLDER, count: inside.length };
    }).filter(c => c.count > 0);
  };
  api.catalog.list = async (f = {}) => {
    let list = await allProducts((f.q || '').trim());
    if (f.category && f.category.length) list = list.filter(p => f.category.includes(p.category));
    if (f.colour && f.colour.length) list = list.filter(p => p.colours.some(c => f.colour.includes(c.name)));
    if (f.size && f.size.length) list = list.filter(p => p.sizes.some(s => f.size.includes(s)));
    if (f.customisable) list = list.filter(p => p.customisable);
    if (f.inStock) list = list.filter(p => p.totalAvailable > 0);
    if (f.sort === 'name') list.sort((a, b) => a.name.localeCompare(b.name));
    else if (f.sort === 'stock') list.sort((a, b) => b.totalAvailable - a.totalAvailable);
    else if (f.sort === 'price-asc') list.sort((a, b) => (a.price || 0) - (b.price || 0));
    else if (f.sort === 'price-desc') list.sort((a, b) => (b.price || 0) - (a.price || 0));
    return list;
  };
  api.catalog.facets = async () => {
    const list = await allProducts();
    const colours = new Map();
    list.forEach(p => p.colours.forEach(c => colours.set(c.name, { name: c.name, hex: c.hex })));
    return { colours: [...colours.values()], sizes: [...new Set(list.flatMap(p => p.sizes))], genders: [] };
  };
  api.catalog.get = async slug => {
    const [p, list] = await Promise.all([findProduct(slug), allProducts()]);
    p.related = list.filter(x => x.id !== p.id).slice(0, 4);
    return p;
  };
  api.catalog.skus = async () => skuRows(await allProducts());

  api.cart.get = getCart;
  api.cart.setStyle = async (productId, lines) => {
    const p = await findProduct(productId);
    const body = lines.filter(l => l.qty > 0).map(l => ({ variant_id: p.variantIds[l.colour + '|' + l.size], qty: l.qty }));
    return cartView((await http('PUT', '/cart/styles/' + productId, { lines: body })).data);
  };
  api.cart.addMany = async items => {
    const ids = [...new Set(items.map(i => i.productId))];
    const products = await Promise.all(ids.map(findProduct));
    const lines = items.map(i => variantLine(products[ids.indexOf(i.productId)], i.colour, i.size, i.qty));
    return cartView((await http('POST', '/cart/items', { lines })).data);
  };
  api.cart.setLine = async (productId, colour, size, qty) => {
    const line = (await getCart()).lines.find(l => l.productId === String(productId) && l.colour === colour && l.size === size);
    if (!line) return getCart();
    const res = qty > 0 ? await http('PUT', '/cart/items/' + line.id, { qty }) : await http('DELETE', '/cart/items/' + line.id);
    return cartView(res.data);
  };
  api.cart.removeStyle = async productId => {
    const lines = (await getCart()).lines.filter(l => l.productId === String(productId));
    for (const l of lines) await http('DELETE', '/cart/items/' + l.id);
    return getCart();
  };
  api.cart.clear = async () => {
    for (const l of (await getCart()).lines) await http('DELETE', '/cart/items/' + l.id);
  };

  api.quotes.list = allQuotes;
  api.quotes.get = async id => quoteView((await http('GET', '/quotes/' + id)).data);
  api.quotes.request = async ({ note, acknowledgeShortage }) => {
    const c = await getCart();
    if (c.shortages.length && !acknowledgeShortage) throw new ApiError('Please confirm you have read the stock shortage note.', { code: 'shortage' });
    const q = (await http('POST', '/quotes', { name: 'Order list, ' + c.pieces + ' pieces', description: (note || '').trim() || null })).data;
    return { id: q.id, number: q.quotation_number };
  };
  api.quotes.message = async (id, text) => quoteView((await http('POST', '/quotes/' + id + '/messages', { message: text })).data);
  api.quotes.accept = async id => quoteView((await http('POST', '/quotes/' + id + '/accept')).data);
  api.quotes.decline = async id => quoteView((await http('POST', '/quotes/' + id + '/reject', { message: 'Declined by retailer.' })).data);

  api.checkout.prepare = async quoteId => {
    const addresses = accountView((await http('GET', '/account')).data).addresses;
    let c = await getCart();
    let quote = null;
    if (quoteId) {
      quote = await api.quotes.get(quoteId);
      if (quote.status !== 'Accepted') throw new ApiError('This quote has not been accepted, or has already been ordered.');
      if (!c.lines.some(l => l.locked)) { await api.quotes.accept(quoteId); c = await getCart(); }
      if (c.lines.some(l => !l.locked)) throw new ApiError('Your order list has other items. Remove them before ordering from this quote.');
    }
    const s = await api.settings(), advanceDue = Math.round(c.subtotal * s.advancePct) / 100;
    return { quote, lines: c.lines, pieces: c.pieces, subtotal: c.subtotal, advancePct: s.advancePct, advanceDue, balanceDue: c.subtotal - advanceDue, holdHours: s.holdHours, addresses, violations: c.violations, shortages: c.shortages };
  };
  api.checkout.place = async ({ addressId, poRef, notes, agree }) => {
    const fields = {};
    if (!addressId) fields.addressId = 'Choose a delivery address.';
    if (!agree) fields.agree = 'Please accept the order terms.';
    if (Object.keys(fields).length) throw new ApiError('Please correct the highlighted fields.', { code: 'validation', fields });
    const account = (await http('GET', '/account')).data;
    const a = account.addresses.find(x => String(x.id) === String(addressId));
    const shipping = await http('POST', '/checkout/address', { billing: { first_name: account.first_name, last_name: account.last_name, company_name: a.label, email: account.email, address: [a.line1], city: a.city, country: 'IN', state: a.state, postcode: a.pin, phone: a.phone, use_for_shipping: true } });
    const carriers = Object.values(shipping.data.shipping_methods || {});
    const rate = carriers.flatMap(c => c.rates).sort((x, y) => x.base_price - y.base_price)[0];
    if (!rate) throw new ApiError('No delivery method is available for this address. Please contact sales.');
    await http('POST', '/checkout/shipping', { shipping_method: rate.method });
    await http('POST', '/checkout/payment', { method: 'moneytransfer' });
    const o = (await http('POST', '/checkout/order', { po_ref: poRef || null, notes: notes || null })).data;
    return { id: o.id, number: o.order_number };
  };

  api.orders.list = allOrders;
  api.orders.get = orderDetail;
  api.orders.startPayment = async (id, kind) => (await http('POST', '/orders/' + id + '/payments', { kind })).data;
  api.orders.confirmPayment = async (id, paymentId, result) => (await http('POST', '/orders/' + id + '/payments/' + paymentId + '/confirm', result)).data;
  api.orders.submitPayment = async (id, { kind, method, ref }) => (await http('POST', '/orders/' + id + '/payments/reference', { kind, method, reference: ref }, { reference: 'ref' })).data;
  const invoiceView = i => ({ ...i, lines: i.lines.map(l => ({ ...l, colour: option(l, 'color'), size: option(l, 'size') })) });
  api.orders.invoice = async id => invoiceView((await http('GET', '/orders/' + id + '/invoice')).data);
  api.orders.cancel = async (id, reason) => orderView((await http('POST', '/orders/' + id + '/cancel', { reason })).data);
  api.orders.reorder = async id => {
    const o = await orderDetail(id);
    await http('POST', '/cart/items', { lines: o.lines.map(l => ({ product_id: Number(l.productId), variant_id: l.variantId, qty: l.qty })) });
  };
  api.orders.track = async ({ number, phone }) => {
    const o = (await http('POST', '/orders/track', { number, phone })).data;
    const view = orderView(o);
    return { number: view.number, type: 'standard', status: view.status, createdAt: view.createdAt, history: view.history, shipment: view.shipment, tracking: view.tracking, pieces: o.total_qty };
  };

  const enquiryBody = (v, type) => ({
    type, name: v.name, business_name: v.organisation || null, email: v.email || null, phone: v.phone, city: v.city || null, quantity: firstNumber(v.quantity),
    product_id: /^\d+$/.test(v.styleId || '') ? Number(v.styleId) : null,
    message: [v.orgType && 'Type: ' + v.orgType, v.quantity && 'Quantity: ' + v.quantity, v.requiredBy && 'Required by: ' + v.requiredBy, v.artworkName && 'Artwork file named: ' + v.artworkName + ' (not uploaded)', v.message].filter(Boolean).join('\n')
  });
  api.enquiries.create = async v => ({ number: (await http('POST', '/enquiries', enquiryBody(v, v.type === 'custom' ? 'custom' : 'bulk'))).data.number });
  api.enquiries.contact = async v => ({ number: (await http('POST', '/enquiries', enquiryBody(v, 'contact'))).data.number });
  api.enquiries.mine = async () => (await http('GET', '/enquiries/mine')).data.filter(e => e.type !== 'retailer_application').map(e => ({ id: e.id, number: e.number, type: e.type, message: e.message, status: e.status === 'new' ? 'New' : e.status, createdAt: e.created_at }));

  api.account.get = async () => accountView((await http('GET', '/account')).data);
  api.account.overview = async () => {
    const [orders, quotes] = await Promise.all([allOrders(), allQuotes()]);
    return { openOrders: orders.filter(o => !['Paid in full', 'Cancelled', 'Expired'].includes(o.status)).length, awaitingAdvance: orders.filter(o => o.status === 'Awaiting advance').length, quotesToReview: quotes.filter(q => q.status === 'Quote ready').length, balance: orders.reduce((s, o) => s + o.outstanding, 0), recent: orders.slice(0, 5), artwork: [] };
  };
  api.account.update = async v => { await http('PUT', '/account', { ...splitName(v.contact), phone: v.phone }, { first_name: 'contact', last_name: 'contact' }); };
  api.account.password = async ({ current, next, confirm }) => { await http('PUT', '/account/password', { current_password: current, password: next, password_confirmation: confirm }, { current_password: 'current', password: 'next', password_confirmation: 'confirm' }); };
  api.account.saveAddress = async v => { await http(v.id ? 'PUT' : 'POST', '/account/addresses' + (v.id ? '/' + v.id : ''), addressBody(v)); };
  api.account.deleteAddress = async id => { await http('DELETE', '/account/addresses/' + id); };
  api.account.defaultAddress = async id => { await http('POST', '/account/addresses/' + id + '/default'); };
  api.account.addUser = () => Promise.reject(new ApiError(NOT_YET));
  api.account.removeUser = () => Promise.reject(new ApiError(NOT_YET));
  api.account.statement = async () => {
    const s = (await http('GET', '/account/statement')).data;
    return { ...s, rows: s.rows.map(r => ({ at: r.at, text: r.text, ref: r.order_id, debit: r.debit, credit: r.credit, balance: r.balance })) };
  };

  api.notifications.list = async () => [];
  api.notifications.readAll = async () => {};

  /* --- Staff business desk --- */
  const rowView = r => ({ id: r.id, number: r.number, company: r.company, status: r.stage, stage: r.stage, createdAt: r.created_at, type: 'standard', subtotal: r.total, paid: r.paid, outstanding: r.outstanding, lines: [{ qty: r.pieces }], customerId: r.customer_id, address: { city: '' }, tracking: r.tracking || null, shipment: r.tracking ? { lr: r.tracking.waybill } : null });
  const staffOrder = o => ({
    ...rowView({ ...o, stage: o.stage }), holdUntil: o.hold_until, advancePct: o.advance_percent, advanceDue: o.advance_due, balanceDue: o.balance_due, payments: (o.payments || []).map(paymentView),
    address: o.address || { label: '', line1: '', city: '', state: '', pin: '', phone: '' }, artwork: null, designBrief: null, tracking: o.tracking,
    shipment: o.tracking ? { courier: o.tracking.courier, lr: o.tracking.waybill } : null,
    history: [{ status: 'Order placed', at: o.created_at, by: o.company, note: '' }, ...(o.payments || []).filter(p => p.status === 'verified').map(p => ({ status: (p.kind === 'advance' ? 'Advance' : 'Balance') + ' verified', at: p.created_at, by: p.reviewed_by, note: p.reference || '' })), ...((o.tracking && o.tracking.events) || []).map(e => ({ status: e.status, at: e.occurred_at, by: e.location, note: '' }))],
    lines: (o.items || []).map(i => ({ name: i.name, sku: i.sku, colour: option(i, 'color'), size: option(i, 'size'), qty: i.qty_ordered, unitPrice: i.price }))
  });
  const clientRow = c => ({ id: c.id, status: c.status, company: c.company, contact: c.contact, email: c.email, phone: c.phone, city: '', appliedAt: c.applied_at, orders: c.orders, outstanding: c.outstanding || 0 });

  const QUOTE = { open: 'Quote requested', draft: 'Quote requested', negotiation: 'Quote ready', accepted: 'Accepted', ordered: 'Ordered', completed: 'Ordered', rejected: 'Declined', expired: 'Expired' };
  const deskQuote = q => ({
    id: q.id, number: q.number, status: QUOTE[q.status] || q.status, company: q.company, note: q.description || '', createdAt: q.created_at, validUntil: q.expiration_date,
    lines: q.items.map(i => ({ id: i.id, name: i.name, sku: i.sku, colour: option(i, 'color'), size: option(i, 'size'), qty: i.qty, unitPrice: i.price, offerPrice: i.negotiated_price !== i.price ? i.negotiated_price : null })),
    messages: (q.messages || []).map(m => ({ by: m.from === 'staff' ? 'VK7SPORTS' : q.company, text: m.message, at: m.created_at }))
  });
  const ENQUIRY = { new: 'New', contacted: 'In follow-up', converted: 'Won', closed: 'Closed' };
  const deskEnquiry = e => ({ id: e.id, number: e.number, type: e.type, name: e.name, organisation: e.business_name || '-', orgType: e.type, phone: e.phone, email: e.email, city: e.city || '-', message: e.message, quantity: e.quantity || '-', status: ENQUIRY[e.status] || e.status, notes: e.notes, followUp: e.follow_up_on, createdAt: e.created_at });

  api.admin = {
    dashboard: async () => {
      const d = (await http('GET', '/admin/dashboard')).data;
      return { ...d, lowStockCount: d.lowStock.count, lowStock: d.lowStock.rows, recent: d.recent.map(rowView) };
    },
    counts: async () => {
      const d = (await http('GET', '/admin/dashboard')).data;
      return { retailers: d.pendingRetailers, payments: d.awaitingVerification, dispatch: d.readyToDispatch, quotes: d.openQuotes, enquiries: d.newEnquiries };
    },
    reports: async () => (await http('GET', '/admin/reports')).data,
    retailers: async () => (await http('GET', '/admin/clients')).data.map(clientRow),
    retailer: async id => {
      const c = (await http('GET', '/admin/clients/' + id)).data, a = c.addresses[0] || {};
      return { ...clientRow(c), city: a.city || '-', state: a.state || '-', shopType: '-', gstin: a.gstin || '', proof: '-', priceList: 'Standard', rejectReason: null, addresses: [{ line1: a.line1 || '-', city: a.city || '', pin: a.pin || '' }], orders: c.orders.map(rowView), statement: c.statement };
    },
    decideRetailer: async (id, { decision, reason }) => { await http('POST', '/admin/clients/' + id + '/decision', { decision, reason: reason || null }); },
    orders: async () => (await http('GET', '/admin/orders')).data.map(rowView),
    order: async id => staffOrder((await http('GET', '/admin/orders/' + id)).data),
    setOrderStatus: async (id, stage) => { await http('POST', '/admin/orders/' + id + '/stage', { stage }); },
    holdOrder: async (id, reason) => { await http('POST', '/admin/orders/' + id + '/hold', { reason }); },
    resumeOrder: async id => { await http('POST', '/admin/orders/' + id + '/resume'); },
    cancelOrder: async (id, reason) => { await http('POST', '/admin/orders/' + id + '/cancel', { reason }); },
    recordBalance: async (id, { amount, method, ref }) => { await http('POST', '/admin/orders/' + id + '/collection', { amount, method, reference: ref }, { reference: 'ref' }); },
    bookCourier: async id => { await http('POST', '/admin/orders/' + id + '/dispatch'); },
    refreshShipment: async id => { await http('POST', '/admin/shipments/' + id + '/refresh'); },
    payments: async () => (await http('GET', '/admin/payments')).data.map(p => ({ ...paymentView(p), orderId: p.order_id, orderNumber: p.order_number, company: p.company })),
    verifyPayment: async (orderId, payId, { ok, reason }) => { await http('POST', '/admin/payments/' + payId + '/review', { accepted: ok, reason: reason || null }); },
    dispatch: async () => (await http('GET', '/admin/dispatch')).data.map(rowView),
    audit: async () => (await http('GET', '/admin/activity')).data.map(l => ({ at: l.created_at, by: l.actor, action: l.action, target: l.target, detail: l.detail || '' })),
    invoice: async id => invoiceView((await http('GET', '/admin/orders/' + id + '/invoice')).data),

    categories: async () => (await http('GET', '/admin/categories')).data,
    products: async () => (await http('GET', '/admin/products')).data.map(p => ({ ...p, totalAvailable: p.available, colours: p.colours.map(c => ({ ...c, images: c.images.map(i => i.url) })) })),
    product: async id => (await http('GET', '/admin/products/' + id)).data,
    saveProduct: async v => {
      let categoryId = v.category_id;
      if (v.newCategory) categoryId = (await http('POST', '/admin/categories', { name: v.newCategory })).data.id;
      const body = { name: v.name, style: v.style, category_id: categoryId ? Number(categoryId) : null, price: v.price, summary: v.summary, description: v.description, status: v.status, stock: v.stock === '' ? 0 : Number(v.stock || 0), colours: v.colours, sizes: v.sizes };
      const res = await http(v.id ? 'PUT' : 'POST', '/admin/products' + (v.id ? '/' + v.id : ''), body);
      return { id: res.data.id };
    },
    uploadPhotos: async (id, colour, files) => {
      const form = new FormData();
      form.append('colour', colour);
      [...files].forEach(f => form.append('photos[]', f));
      await http('POST', '/admin/products/' + id + '/photos', form);
    },
    removePhoto: async (id, imageId) => { await http('DELETE', '/admin/products/' + id + '/photos/' + imageId); },

    inventory: async () => (await http('GET', '/admin/inventory')).data.map(p => ({ ...p, rows: p.rows.map(r => ({ variantId: r.variant_id, colour: r.colour, size: r.size, onHand: r.on_hand, held: r.held, available: r.available })) })),
    adjustStock: async ({ variantId, change, reason, note }) => { await http('POST', '/admin/inventory/adjust', { variant_id: variantId, change: Number(change), reason, note: note || null }); },
    stockLog: async () => (await http('GET', '/admin/stock-log')).data.map(l => ({ at: l.created_at, by: l.actor, product: l.product, variant: l.variant, change: l.change, after: l.on_hand, reason: l.reason, note: l.note })),

    quotes: async () => (await http('GET', '/admin/quotes')).data.map(deskQuote),
    quote: async id => deskQuote((await http('GET', '/admin/quotes/' + id)).data),
    sendOffer: async (id, { prices, message }) => { await http('POST', '/admin/quotes/' + id + '/offer', { prices, message: message || null }); },
    rejectQuote: async (id, reason) => { await http('POST', '/admin/quotes/' + id + '/reject', { reason }); },

    enquiries: async () => (await http('GET', '/admin/enquiries')).data.map(deskEnquiry),
    updateEnquiry: async (id, { status, note, followUp }) => { await http('PUT', '/admin/enquiries/' + id, { status: Object.keys(ENQUIRY).find(k => ENQUIRY[k] === status), note: note || null, follow_up_on: followUp ? followUp.slice(0, 10) : null }); },

    staff: async () => (await http('GET', '/admin/staff')).data,
    saveStaff: async v => { await http(v.id ? 'PUT' : 'POST', '/admin/staff' + (v.id ? '/' + v.id : ''), { name: v.name, email: v.email, password: v.password, role_id: Number(v.role_id) }); },
    toggleStaff: async id => { await http('POST', '/admin/staff/' + id + '/toggle'); },

    allSettings: async () => {
      const s = (await http('GET', '/admin/settings')).data;
      return { ...s, moqEnabled: s.moqEnabled === '1', taxInvoiceApproved: s.taxInvoiceApproved === '1' };
    },
    saveSettings: async v => {
      const clean = { ...v };
      ['moqEnabled', 'taxInvoiceApproved'].forEach(k => { clean[k] = !!v[k]; });
      await http('PUT', '/admin/settings', clean);
    }
  };
})();
