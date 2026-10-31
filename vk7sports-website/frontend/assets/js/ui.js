/* Shared UI: safe HTML templating, page shells, forms, status badges, the size x colour grid. */
(function () {
  const VK7 = window.VK7 = window.VK7 || {};
  const CFG = window.VK7_CONFIG;
  const api = VK7.api;

  /* --- Safe templating: every interpolated value is escaped unless it came from html`` or raw() --- */
  class Safe { constructor(s) { this.s = s; } toString() { return this.s; } }
  const escapeHtml = v => String(v).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const toHtml = v => {
    if (v == null || v === false || v === true) return '';
    if (v instanceof Safe) return v.s;
    if (Array.isArray(v)) return v.map(toHtml).join('');
    return escapeHtml(v);
  };
  const html = (strings, ...vals) => new Safe(strings.reduce((out, s, i) => out + s + (i < vals.length ? toHtml(vals[i]) : ''), ''));
  const raw = s => new Safe(String(s));

  /* --- Formatting --- */
  const money = n => '₹' + Number(n || 0).toLocaleString('en-IN', { maximumFractionDigits: 2, minimumFractionDigits: Number.isInteger(Number(n || 0)) ? 0 : 2 });
  const date = d => d ? new Date(d).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' }) : '-';
  const dateTime = d => d ? new Date(d).toLocaleString('en-IN', { day: 'numeric', month: 'short', hour: 'numeric', minute: '2-digit' }) : '-';
  const param = k => new URLSearchParams(location.search).get(k);
  const hoursLeft = d => Math.max(0, Math.round((new Date(d).getTime() - Date.now()) / 3600000));

  /* --- Icons --- */
  const ICONS = {
    search: '<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>',
    cart: '<path d="M3 4h2l2.4 11h10.2L20 7H6"/><circle cx="9" cy="20" r="1.4"/><circle cx="17" cy="20" r="1.4"/>',
    user: '<circle cx="12" cy="8" r="4"/><path d="M4 21c1-4 4-6 8-6s7 2 8 6"/>',
    menu: '<path d="M3 6h18M3 12h18M3 18h18"/>',
    bell: '<path d="M6 16V11a6 6 0 0 1 12 0v5l2 2H4z"/><path d="M10 21h4"/>',
    lock: '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>',
    check: '<path d="m5 12 5 5 9-10"/>',
    box: '<path d="M3 8l9-5 9 5v8l-9 5-9-5z"/><path d="M3 8l9 5 9-5M12 13v8"/>',
    truck: '<path d="M2 6h12v10H2zM14 10h4l4 4v2h-8z"/><circle cx="7" cy="18" r="2"/><circle cx="17" cy="18" r="2"/>',
    layers: '<path d="m12 3 9 5-9 5-9-5z"/><path d="m3 13 9 5 9-5"/>',
    home: '<path d="M3 11 12 3l9 8"/><path d="M5 10v10h14V10"/>',
    file: '<path d="M6 3h8l5 5v13H6z"/><path d="M14 3v5h5"/>',
    list: '<path d="M8 6h13M8 12h13M8 18h13"/><circle cx="4" cy="6" r="1"/><circle cx="4" cy="12" r="1"/><circle cx="4" cy="18" r="1"/>',
    users: '<circle cx="9" cy="8" r="3.5"/><path d="M2 20c.7-3.5 3.3-5.5 7-5.5s6.300 2 7 5.500"/><path d="M16 5a3.500 3.500 0 0 1 0 6.500M18.500 14.800c1.800.8 3 2.500 3.500 5.200"/>',
    rupee: '<path d="M6 4h12M6 9h12M6 4c7 0 8 10 0 10l8 7"/>',
    chart: '<path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>',
    gear: '<circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3M5 5l2 2M17 17l2 2M19 5l-2 2M7 17l-2 2"/>',
    shield: '<path d="M12 3 4 6v6c0 5 3.500 8 8 9 4.500-1 8-4 8-9V6z"/>',
    mail: '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/>',
    alert: '<path d="M12 3 2 20h20z"/><path d="M12 10v4M12 17v.5"/>',
    star: '<path d="m12 3 2.700 5.700 6.300.800-4.600 4.300 1.200 6.200L12 17l-5.600 3 1.200-6.200L3 9.500l6.300-.800z"/>'
  };
  const icon = (name, size = 18) => raw(`<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${ICONS[name] || ''}</svg>`);

  /* --- Small components --- */
  const STATUS_TONE = {
    'Paid in full': 'ok', Delivered: 'ok', Confirmed: 'ok', Approved: 'ok', approved: 'ok', verified: 'ok', Accepted: 'ok', Ordered: 'ok', Won: 'ok', 'Production authorised': 'ok', 'Artwork approved': 'ok', Active: 'ok',
    'Awaiting advance': 'warn', 'Awaiting balance': 'warn', 'Quote ready': 'warn', 'Artwork awaiting approval': 'warn', pending: 'warn', Pending: 'warn', submitted: 'warn', 'On hold': 'warn', 'In follow-up': 'warn', Quoted: 'warn',
    Cancelled: 'bad', Expired: 'bad', rejected: 'bad', Rejected: 'bad', Declined: 'bad', suspended: 'bad', Suspended: 'bad', Lost: 'bad', Inactive: 'bad',
    New: 'info', 'Quote requested': 'info', Packing: 'info', Dispatched: 'info', 'In production': 'info', 'Partly dispatched': 'info'
  };
  const LABEL = { approved: 'Approved', pending: 'Awaiting approval', rejected: 'Rejected', suspended: 'Suspended', verified: 'Verified', submitted: 'To verify' };
  const badge = s => html`<span class="badge b-${STATUS_TONE[s] || 'mute'}">${LABEL[s] || s}</span>`;
  const tbc = (label = 'To be confirmed') => html`<span class="tbc" title="VK7SPORTS to confirm">${label}</span>`;
  const notice = (tone, title, body) => html`<div class="notice n-${tone}" role="${tone === 'bad' ? 'alert' : 'status'}"><div>${title ? html`<strong>${title}</strong>` : ''}${body || ''}</div></div>`;
  const empty = (title, text, action, ico = 'box') => html`<div class="state"><div class="state-ico">${icon(ico, 24)}</div><h3>${title}</h3><p>${text}</p>${action || ''}</div>`;
  const skeleton = (n = 3) => html`<div class="stack" aria-label="Loading">${Array.from({ length: n }).map(() => html`<div class="skel" style="height:84px"></div>`)}</div>`;
  const cardSkeleton = n => html`<div class="pgrid">${Array.from({ length: n }).map(() => html`<div class="skel" style="aspect-ratio:4/6"></div>`)}</div>`;
  const stockWord = n => n <= 0 ? 'Out' : n;
  const crumbs = items => html`<nav class="crumbs" aria-label="Breadcrumb">${items.map((c, i) => html`${i ? html`<span aria-hidden="true">/</span>` : ''}${c[1] ? html`<a href="${c[1]}">${c[0]}</a>` : html`<span aria-current="page">${c[0]}</span>`}`)}</nav>`;
  const pageHead = (title, sub, trail) => html`<div class="page-head"><div class="wrap">${trail ? crumbs(trail) : ''}<h1>${title}</h1>${sub ? html`<p>${sub}</p>` : ''}</div></div>`;
  const productCard = (p, me) => {
    const c = p.colours[0], low = p.totalAvailable <= 0;
    return html`<a class="pcard" href="product.html?p=${p.slug}">
      <div class="pcard-img"><img src="${c.images[0]}" alt="${p.name} in ${c.name}" loading="lazy">
        ${low ? html`<span class="badge b-bad pcard-tag">Out of stock</span>` : p.isNew ? html`<span class="badge b-navy pcard-tag">New</span>` : ''}</div>
      <div class="pcard-body">
        <span class="small muted mono">${p.style}</span>
        <h3>${p.name}</h3>
        <div class="swatches" aria-label="${p.colours.length} colours">${p.colours.slice(0, 7).map(x => html`<span class="swatch" style="background:${x.hex}" title="${x.name}"></span>`)}</div>
        <div style="margin-top:auto;padding-top:6px">${priceBlock(p, me)}</div>
      </div></a>`;
  };
  const priceBlock = (p, me) => p.price != null
    ? html`<div class="price">${money(p.price)} <small>per piece, excl. GST</small></div>`
    : me && me.kind === 'retailer'
      ? html`<div class="price-lock">${icon('lock', 14)} Price after approval</div>`
      : html`<div class="price-lock">${icon('lock', 14)} Sign in for trade price</div>`;

  /* Tracker for an order's status against its flow */
  const tracker = o => {
    const flow = VK7.FLOWS[o.type];
    let idx = flow.indexOf(o.status);
    if (idx < 0) return notice(o.status === 'On hold' ? 'warn' : 'bad', 'Order status: ' + o.status, o.history.length ? o.history[o.history.length - 1].note : '');
    if (o.status === 'Paid in full') idx = flow.length;
    return html`<ol class="track">${flow.filter(s => s !== 'Artwork approved').map(s => {
      const i = flow.indexOf(s);
      return html`<li class="${i < idx ? 'done' : i === idx ? 'now' : ''}" ${i === idx ? raw('aria-current="step"') : ''}>${s}</li>`;
    })}</ol>`;
  };
  const timeline = items => html`<ol class="timeline">${items.slice().reverse().map(h => html`<li><strong>${h.status}</strong><div class="small muted">${dateTime(h.at)}${h.by ? ' · ' + h.by : ''}</div>${h.note ? html`<div class="small">${h.note}</div>` : ''}</li>`)}</ol>`;

  /* --- Size x colour grid. Returns markup; wire with bindGrid() --- */
  const gridMarkup = (p, existing = {}, disabled = false) => html`
    <div class="mx" style="--sizes:${p.sizes.length}" data-grid>
      <div class="mx-head" aria-hidden="true"><span>Colour</span>${p.sizes.map(s => html`<span>${s}</span>`)}<span style="text-align:right">Total</span></div>
      ${p.colours.map(c => html`<div class="mx-row" data-colour="${c.name}">
        <div class="mx-colour"><span class="swatch" style="background:${c.hex}"></span>${c.name}</div>
        ${p.sizes.map(s => {
          const k = c.name + '|' + s, a = p.available[k] ?? 0, id = `q-${c.code}-${s}`;
          return html`<div class="mx-cell"><label for="${id}">${s}</label>
            <input id="${id}" type="number" inputmode="numeric" min="0" max="9999" step="1" placeholder="0" aria-label="${c.name}, size ${s}, ${a} available" data-colour="${c.name}" data-size="${s}" data-avail="${a}" value="${existing[k] || ''}" ${disabled ? raw('disabled') : ''}>
            <small class="${a === 0 ? 'none' : ''}">${a === 0 ? 'Out' : a + ' left'}</small></div>`;
        })}
        <div class="mx-total" data-rowtotal>0</div>
      </div>`)}
    </div>`;

  const bindGrid = (root, onChange) => {
    const inputs = [...root.querySelectorAll('[data-grid] input')];
    const refresh = () => {
      const lines = [];
      root.querySelectorAll('.mx-row').forEach(row => {
        let t = 0;
        row.querySelectorAll('input').forEach(i => {
          const q = Math.max(0, Math.floor(Number(i.value) || 0));
          if (q) lines.push({ colour: i.dataset.colour, size: i.dataset.size, qty: q, available: Number(i.dataset.avail) });
          t += q;
          i.classList.toggle('over', q > Number(i.dataset.avail));
        });
        row.querySelector('[data-rowtotal]').textContent = t;
      });
      onChange(lines);
    };
    inputs.forEach(i => i.addEventListener('input', refresh));
    refresh();
    return { clear() { inputs.forEach(i => { i.value = ''; }); refresh(); } };
  };

  /* --- Forms --- */
  const field = (name, label, opts = {}) => {
    const { type = 'text', required, hint, value = '', options, placeholder, rows, autocomplete, inputmode, full, maxlength, min, max } = opts;
    const id = 'f-' + name, attrs = raw(`${autocomplete ? `autocomplete="${autocomplete}"` : ''} ${inputmode ? `inputmode="${inputmode}"` : ''} ${maxlength ? `maxlength="${maxlength}"` : ''} ${min != null ? `min="${min}"` : ''} ${max != null ? `max="${max}"` : ''}`);
    let control;
    if (type === 'select') control = html`<select class="input" id="${id}" name="${name}" ${required ? raw('required') : ''}>${options.map(o => { const [v, l] = Array.isArray(o) ? o : [o, o]; return html`<option value="${v}" ${String(v) === String(value) ? raw('selected') : ''}>${l}</option>`; })}</select>`;
    else if (type === 'textarea') control = html`<textarea class="input" id="${id}" name="${name}" rows="${rows || 4}" placeholder="${placeholder || ''}" ${required ? raw('required') : ''}>${value}</textarea>`;
    else control = html`<input class="input" id="${id}" name="${name}" type="${type}" value="${value}" placeholder="${placeholder || ''}" ${required ? raw('required') : ''} ${attrs}>`;
    return html`<div class="field" data-field="${name}" ${full ? raw('style="grid-column:1/-1"') : ''}><label for="${id}">${label}${required ? html` <span class="req" aria-hidden="true">*</span>` : ''}</label>${control}${hint ? html`<span class="hint">${hint}</span>` : ''}<span class="err" hidden></span></div>`;
  };
  const checkbox = (name, label, opts = {}) => html`<div class="field" data-field="${name}"><label class="check" style="font-weight:400"><input type="checkbox" name="${name}" ${opts.checked ? raw('checked') : ''}><span>${label}</span></label><span class="err" hidden></span></div>`;

  const values = form => {
    const out = {};
    new FormData(form).forEach((v, k) => { out[k] = v; });
    form.querySelectorAll('input[type=checkbox]').forEach(c => { if (c.name) out[c.name] = c.checked; });
    return out;
  };
  const clearErrors = form => {
    form.querySelectorAll('.field.has-err').forEach(f => { f.classList.remove('has-err'); const e = f.querySelector('.err'); e.hidden = true; e.textContent = ''; });
    const s = form.querySelector('[data-form-error]'); if (s) s.remove();
  };
  const showFormError = (form, err) => {
    clearErrors(form);
    if (err.fields) Object.keys(err.fields).forEach(k => {
      const f = form.querySelector(`[data-field="${k}"]`); if (!f) return;
      f.classList.add('has-err'); const e = f.querySelector('.err'); e.hidden = false; e.textContent = err.fields[k];
    });
    const box = document.createElement('div');
    box.setAttribute('data-form-error', '');
    box.innerHTML = notice('bad', null, err.message || 'Something went wrong. Please try again.');
    form.prepend(box);
    (form.querySelector('.has-err input,.has-err select,.has-err textarea') || box).scrollIntoView({ block: 'center', behavior: 'auto' });
  };
  /* Sends the form once, shows a busy state and field errors; a double click cannot submit twice. */
  const onSubmit = (form, handler) => {
    let busy = false;
    form.addEventListener('submit', async e => {
      e.preventDefault();
      if (busy) return;
      busy = true;
      const btn = form.querySelector('button[type=submit]');
      const label = btn && btn.textContent;
      if (btn) { btn.disabled = true; btn.textContent = 'Please wait...'; }
      clearErrors(form);
      try { await handler(values(form)); }
      catch (err) { showFormError(form, err); }
      finally { busy = false; if (btn) { btn.disabled = false; btn.textContent = label; } }
    });
  };

  const toast = (msg, bad) => {
    let host = document.querySelector('.toasts');
    if (!host) { host = document.createElement('div'); host.className = 'toasts'; host.setAttribute('aria-live', 'polite'); document.body.appendChild(host); }
    const t = document.createElement('div'); t.className = 'toast' + (bad ? ' bad' : ''); t.textContent = msg;
    host.appendChild(t); setTimeout(() => t.remove(), 4000);
  };

  /* Modal. body may include a form; onSubmit receives values and closes on success. */
  const modal = (title, body, submitHandler) => {
    const prev = document.activeElement;
    const bg = document.createElement('div');
    bg.className = 'modal-bg';
    bg.innerHTML = html`<div class="modal" role="dialog" aria-modal="true" aria-label="${title}"><div class="modal-h"><h3>${title}</h3><button class="x" aria-label="Close" data-close>&times;</button></div><div class="modal-b">${body}</div></div>`;
    document.body.appendChild(bg);
    const close = () => { bg.remove(); document.removeEventListener('keydown', esc); if (prev && prev.focus) prev.focus(); };
    const esc = e => { if (e.key === 'Escape') close(); };
    document.addEventListener('keydown', esc);
    bg.addEventListener('click', e => { if (e.target === bg || e.target.closest('[data-close]')) close(); });
    const form = bg.querySelector('form');
    if (form && submitHandler) onSubmit(form, async v => { await submitHandler(v); close(); });
    const first = bg.querySelector('input,select,textarea,button:not([data-close])');
    if (first) first.focus();
    return { close, el: bg };
  };
  const confirmBox = (title, text, label, handler, danger) => modal(title, html`<form class="form"><p class="mb-0">${text}</p><div class="row between"><button type="button" class="btn btn-line" data-close>Go back</button><button type="submit" class="btn ${danger ? 'btn-danger' : 'btn-red'}">${label}</button></div></form>`, handler);
  const reasonBox = (title, text, label, handler) => modal(title, html`<form class="form"><p class="mb-0">${text}</p>${field('reason', 'Reason', { type: 'textarea', required: true, rows: 3 })}<div class="row between"><button type="button" class="btn btn-line" data-close>Go back</button><button type="submit" class="btn btn-danger">${label}</button></div></form>`, v => handler(v.reason));

  const on = (root, sel, fn, ev = 'click') => root.addEventListener(ev, e => {
    const t = e.target.closest(sel);
    if (t && root.contains(t)) fn(t, e);
  });
  /* Action buttons: guards against double click and reports failures. */
  const act = async (fn, okMsg) => {
    try { const r = await fn(); if (okMsg) toast(okMsg); return r; }
    catch (e) { toast(e.message || 'Something went wrong.', true); throw e; }
  };

  /* --- Public chrome --- */
  const PUBLIC_NAV = [['Catalogue', 'catalogue.html'], ['How it works', 'how-it-works.html'], ['Customised orders', 'custom-orders.html'], ['Bulk enquiry', 'enquiry.html'], ['About', 'about.html'], ['Contact', 'contact.html']];
  const here = () => (location.pathname.split('/').pop() || 'index.html');
  const current = href => here() === href ? raw('aria-current="page"') : '';

  const demoStrip = () => CFG.demoMode ? html`<div class="demo-strip no-print">Demo version: prices, stock and orders are sample data, and no real payment is taken. <button type="button" data-reset>Reset demo</button></div>` : '';

  const header = me => {
    const account = !me ? ['Sign in', 'login.html'] : me.kind === 'staff' ? ['Staff area', 'admin.html'] : ['My account', 'account.html'];
    return html`
    ${demoStrip()}
    <header class="hdr no-print"><div class="wrap hdr-in">
      <button class="tool burger" type="button" aria-label="Open menu" data-open-menu>${icon('menu', 22)}</button>
      <a class="logo" href="index.html" aria-label="VK7SPORTS home"><img src="assets/img/brand/logo-white.png" alt="VK7SPORTS, sportswear for champions" width="179" height="34"></a>
      <nav class="nav" aria-label="Main">${PUBLIC_NAV.map(n => html`<a href="${n[1]}" ${current(n[1])}>${n[0]}</a>`)}</nav>
      <form class="hdr-search" role="search" action="catalogue.html"><label class="sr" for="site-q">Search products</label>${icon('search')}<input id="site-q" name="q" type="search" placeholder="Search products" value="${param('q') || ''}"></form>
      <div class="hdr-tools">
        <a class="tool" href="${account[1]}">${icon('user', 20)}<span class="lbl">${account[0]}</span></a>
        ${me && me.kind === 'retailer' && me.approved ? html`<a class="tool" href="cart.html" aria-label="Order list, ${me.cartCount} pieces">${icon('cart', 20)}${me.cartCount ? html`<span class="count">${me.cartCount}</span>` : ''}</a>` : ''}
      </div>
    </div></header>
    <div class="drawer" aria-label="Menu"><div class="drawer-head"><img src="assets/img/brand/logo-white.png" alt="VK7SPORTS"><button class="x" style="color:#fff" aria-label="Close menu" data-close-menu>&times;</button></div>
      <a href="index.html">Home</a>${PUBLIC_NAV.map(n => html`<a href="${n[1]}">${n[0]}</a>`)}<a href="track.html">Track an order</a><a href="faq.html">FAQs</a><a href="${account[1]}">${account[0]}</a>
    </div><div class="drawer-bg" data-close-menu></div>`;
  };

  const footer = () => {
    const C = CFG.contact;
    return html`<footer class="ftr no-print"><div class="wrap">
      <div class="ftr-grid">
        <div><img class="ftr-logo" src="assets/img/brand/logo-white.png" alt="VK7SPORTS"><p>Wholesale sportswear for approved retailers and shopkeepers.</p></div>
        <div><h4>Shop</h4><ul><li><a href="catalogue.html">Catalogue</a></li><li><a href="register.html">Apply for a trade account</a></li><li><a href="quick-order.html">Quick order</a></li><li><a href="track.html">Track an order</a></li></ul></div>
        <div><h4>Company</h4><ul><li><a href="about.html">About VK7SPORTS</a></li><li><a href="how-it-works.html">How it works</a></li><li><a href="custom-orders.html">Customised orders</a></li><li><a href="enquiry.html">Bulk enquiry</a></li><li><a href="faq.html">FAQs</a></li><li><a href="contact.html">Contact</a></li></ul></div>
        <div><h4>Policies</h4><ul><li><a href="policy.html?doc=terms">Terms of sale</a></li><li><a href="policy.html?doc=shipping">Shipping</a></li><li><a href="policy.html?doc=returns">Returns and replacements</a></li><li><a href="policy.html?doc=privacy">Privacy</a></li></ul></div>
      </div>
      <div class="ftr-base"><span>© ${new Date().getFullYear()} ${C.legalName || 'VK7SPORTS'}. All rights reserved.</span><span>${C.gstin ? 'GSTIN ' + C.gstin : ''}</span><a href="admin-login.html">Staff sign-in</a></div>
    </div></footer>`;
  };

  const wireChrome = () => {
    document.body.addEventListener('click', e => {
      if (e.target.closest('[data-open-menu]')) document.body.classList.add('drawer-open');
      if (e.target.closest('[data-close-menu]')) document.body.classList.remove('drawer-open');
      if (e.target.closest('[data-open-a]')) document.body.classList.toggle('a-open');
      if (e.target.closest('[data-reset]')) {
        confirmBox('Reset demo', 'This clears everything entered in this browser and restores the sample data.', 'Reset demo', async () => { await api.demoReset(); location.href = 'index.html'; }, true);
      }
    });
  };

  const SIDE = [
    ['Overview', 'account.html', 'home'], ['My orders', 'account-orders.html', 'box'], ['My quotes', 'account-quotes.html', 'file'], ['Enquiries', 'account-enquiries.html', 'mail'],
    ['Account statement', 'account-statement.html', 'rupee'], ['Notifications', 'account-notifications.html', 'bell'], ['Shop profile', 'account-profile.html', 'user'], ['Addresses', 'account-addresses.html', 'truck'], ['Shop logins', 'account-users.html', 'users']
  ];
  const ADMIN_SIDE = [
    ['Work', [['Dashboard', 'admin.html', 'home', 'dashboard'], ['Retailers', 'admin-retailers.html', 'users', 'retailers', 'retailers'], ['Enquiries', 'admin-enquiries.html', 'mail', 'enquiries', 'enquiries'], ['Quotes', 'admin-quotes.html', 'file', 'quotes', 'quotes'], ['Orders', 'admin-orders.html', 'box', 'orders']]],
    ['Money and dispatch', [['Payments', 'admin-payments.html', 'rupee', 'payments', 'payments'], ['Dispatch', 'admin-dispatch.html', 'truck', 'dispatch', 'dispatch']]],
    ['Catalogue', [['Products', 'admin-products.html', 'layers', 'products'], ['Inventory', 'admin-inventory.html', 'list', 'inventory']]],
    ['Business', [['Reports', 'admin-reports.html', 'chart', 'reports'], ['Notifications', 'admin-notifications.html', 'bell', 'notifications'], ['Staff and roles', 'admin-staff.html', 'shield', 'staff'], ['Settings', 'admin-settings.html', 'gear', 'settings'], ['Activity log', 'admin-audit.html', 'list', 'audit']]]
  ];

  /* --- Page runner --- */
  const pages = {};
  /* opts.layout: public | account | auth | admin | bare. opts.access: approved | retailer | staff:<perm> */
  const page = (name, opts, fn) => { pages[name] = { ...opts, fn }; };

  const redirect = href => { location.replace(href); return new Promise(() => {}); };
  const showError = (main, err, retry) => {
    if (err && err.status === 404) { main.innerHTML = html`<div class="wrap">${empty('We could not find that', err.message, html`<a class="btn btn-navy" href="index.html">Go to the home page</a>`, 'alert')}</div>`; return; }
    main.innerHTML = html`<div class="wrap">${empty('Something went wrong', err.message || 'Please try again.', html`<button class="btn btn-navy" data-retry>Try again</button>`, 'alert')}</div>`;
    const b = main.querySelector('[data-retry]'); if (b) b.onclick = retry;
  };

  const boot = async () => {
    const name = document.body.dataset.page, def = pages[name];
    const app = document.getElementById('app');
    wireChrome();
    if (!def) { app.innerHTML = '<p>Page not found.</p>'; return; }
    const me = await api.auth.me();
    const ctx = { me, param };

    // Access rules
    if (def.access === 'retailer' || def.access === 'approved') {
      if (!me || me.kind !== 'retailer') return redirect('login.html?next=' + encodeURIComponent(here() + location.search));
    }
    if (def.access === 'approved' && !me.approved) return redirect('account.html');
    if (def.access && def.access.startsWith('staff')) {
      if (!me || me.kind !== 'staff') return redirect('admin-login.html');
    }

    const skip = raw('<a class="skip" href="#main">Skip to content</a>');
    if (def.layout === 'admin') {
      const perm = def.access.split(':')[1];
      app.innerHTML = html`${skip}${demoStrip()}<div class="a-shell">
        <aside class="a-side no-print"><a class="logo" href="admin.html"><img src="assets/img/brand/logo-white.png" alt="VK7SPORTS"></a><nav aria-label="Staff" data-anav>${ADMIN_SIDE.map(g => {
          const items = g[1].filter(i => me.perms.includes(i[3]));
          return items.length ? html`<div class="grp">${g[0]}</div>${items.map(i => html`<a href="${i[1]}" ${current(i[1])}>${icon(i[2])}<span>${i[0]}</span>${i[4] ? html`<span class="count-pill" data-count="${i[4]}" hidden></span>` : ''}</a>`)}` : '';
        })}</nav></aside>
        <div style="min-width:0"><div class="a-top no-print"><button class="a-burger" aria-label="Open menu" data-open-a>${icon('menu', 22)}</button><span class="small muted">${me.role}</span><div class="row"><a class="tool" style="color:var(--navy)" href="admin-notifications.html" aria-label="Notifications">${icon('bell', 20)}${me.unread ? html`<span class="count">${me.unread}</span>` : ''}</a><span class="small who">${me.name}</span><button class="btn btn-line btn-sm" data-logout>Sign out</button></div></div>
        <main id="main" class="a-main"></main></div></div>`;
      api.admin.counts().then(c => document.querySelectorAll('[data-count]').forEach(el => { const n = c[el.dataset.count]; if (n) { el.textContent = n; el.hidden = false; } })).catch(() => {});
      document.querySelector('[data-logout]').onclick = async () => { await api.auth.logout(); location.href = 'admin-login.html'; };
      if (perm && !me.perms.includes(perm)) {
        document.getElementById('main').innerHTML = empty('No access', 'Your role (' + me.role + ') does not include this area.', html`<a class="btn btn-navy" href="admin.html">Back to dashboard</a>`, 'lock');
        return;
      }
    } else if (def.layout === 'account') {
      app.innerHTML = html`${skip}${header(me)}<div class="wrap"><div class="portal">
        <aside class="side no-print"><div class="side-who"><strong>${me.company}</strong><span class="small muted">${me.name}</span></div><nav aria-label="Account" style="display:contents">${SIDE.map(s => html`<a href="${s[1]}" ${current(s[1])}>${icon(s[2])}${s[0]}</a>`)}</nav><button class="logout" data-logout>Sign out</button></aside>
        <main id="main" style="min-width:0"></main></div></div>${footer()}`;
      document.querySelector('[data-logout]').onclick = async () => { await api.auth.logout(); location.href = 'index.html'; };
    } else if (def.layout === 'bare') {
      app.innerHTML = html`${skip}<main id="main"></main>`;
    } else {
      app.innerHTML = html`${skip}${header(me)}<main id="main"></main>${footer()}`;
    }

    const main = document.getElementById('main');
    const run = async () => {
      main.innerHTML = html`<div class="${def.layout === 'public' ? 'wrap' : ''}" style="padding:24px 0">${skeleton()}</div>`;
      try { await def.fn(main, ctx); main.dataset.ready = '1'; }
      catch (err) {
        if (err && err.status === 401) return redirect(def.layout === 'admin' ? 'admin-login.html' : 'login.html');
        console.warn(err);
        showError(main, err, run);
      }
    };
    await run();
  };

  document.addEventListener('DOMContentLoaded', boot);

  Object.assign(VK7, { html, raw, money, date, dateTime, param, hoursLeft, icon, badge, tbc, notice, empty, skeleton, cardSkeleton, crumbs, pageHead, productCard, priceBlock, tracker, timeline, gridMarkup, bindGrid, field, checkbox, values, onSubmit, showFormError, toast, modal, confirmBox, reasonBox, on, act, page, redirect });
})();
