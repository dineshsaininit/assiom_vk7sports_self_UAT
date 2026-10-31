/* Retailer pages: order list, checkout, quotes, orders, account. */
(function () {
  const { invoiceDoc, api, html, raw, money, date, dateTime, param, hoursLeft, icon, badge, tbc, notice, empty, pageHead, tracker, timeline, field, checkbox, onSubmit, toast, modal, confirmBox, reasonBox, on, act, page, trackingPanel, mountMap, payOnline } = VK7;
  const PAY = window.VK7_CONFIG.payment;
  const title = (t, sub, action) => html`<div class="ptitle"><div><h1>${t}</h1>${sub ? html`<p>${sub}</p>` : ''}</div>${action || ''}</div>`;
  const pcs = lines => lines.reduce((s, l) => s + l.qty, 0);
  const lineTable = (lines, priceKey = 'unitPrice') => html`<div class="tw"><table class="t"><thead><tr><th>Item</th><th>Colour</th><th>Size</th><th class="num">Pieces</th><th class="num">Price</th><th class="num">Total</th></tr></thead><tbody>
    ${lines.map(l => html`<tr><td><strong>${l.name}</strong><div class="small muted mono">${l.sku}</div></td><td>${l.colour}</td><td>${l.size}</td><td class="num">${l.qty}</td><td class="num">${money(l[priceKey])}</td><td class="num">${money(l.qty * l[priceKey])}</td></tr>`)}
  </tbody></table></div>`;

  /* ---------- Order list (cart) ---------- */
  page('cart', { layout: 'public', access: 'approved' }, async main => {
    const S = await api.settings();
    const render = async () => {
      const c = await api.cart.get();
      if (!c.lines.length) {
        main.innerHTML = html`${pageHead('Order list', null, [['Home', 'index.html'], ['Order list']])}<div class="wrap">${empty('Your order list is empty', 'Add styles from the catalogue, or use quick order if you know your codes.', html`<div class="row" style="justify-content:center"><a class="btn btn-red" href="catalogue.html">Browse catalogue</a><a class="btn btn-line" href="quick-order.html">Quick order</a></div>`, 'cart')}</div>`;
        return;
      }
      const blocked = c.violations.length > 0;
      main.innerHTML = html`${pageHead('Order list', c.pieces + ' pieces across ' + c.groups.length + (c.groups.length === 1 ? ' style' : ' styles'), [['Home', 'index.html'], ['Order list']])}
      <div class="wrap" style="padding-top:24px"><div class="split">
        <div class="stack">
          ${blocked ? notice('bad', 'Minimum order not met', html`<ul style="margin:4px 0 0;padding-left:18px">${c.violations.map(v => html`<li>${v.label}: add ${v.need} more ${v.need === 1 ? 'piece' : 'pieces'}</li>`)}</ul>`) : ''}
          ${c.shortages.length ? notice('warn', 'Some sizes are short of stock', html`<ul style="margin:4px 0 6px;padding-left:18px">${c.shortages.map(l => html`<li>${l.name}, ${l.colour} ${l.size}: ${l.available} available, you asked for ${l.qty}</li>`)}</ul>${S.shortageNote} Reduce the quantity to order now, or request a quote and our team will advise.`) : ''}
          ${c.groups.map(g => {
            const need = S.moqEnabled && S.moqMode === 'per_style' ? Math.max(0, S.moq - g.pieces) : 0;
            return html`<div class="card"><div class="card-head"><div class="row" style="flex-wrap:nowrap;min-width:0"><img src="${g.image}" alt="" width="44" height="56" style="object-fit:cover;border-radius:4px"><div style="min-width:0"><h3><a href="product.html?p=${g.slug}" style="text-decoration:none">${g.name}</a></h3><span class="small muted">${g.pieces} pieces · ${money(g.value)}</span></div></div>
              <div class="row">${need ? html`<span class="badge b-bad">${need} more needed</span>` : html`<span class="badge b-ok">Minimum met</span>`}<a class="btn btn-line btn-sm" href="product.html?p=${g.slug}">Edit grid</a><button class="btn btn-ghost btn-sm" data-remove="${g.productId}">Remove</button></div></div>
              <div class="tw"><table class="t"><thead><tr><th>Colour</th><th>Size</th><th class="num">Available</th><th class="num">Pieces</th><th class="num">Total</th></tr></thead><tbody>
                ${g.lines.map(l => html`<tr><td>${l.colour}</td><td>${l.size}</td><td class="num">${l.short ? html`<span class="badge b-warn">${l.available}</span>` : l.available}</td>
                  <td class="num"><label class="sr" for="q-${l.sku}">Pieces for ${l.colour} ${l.size}</label><input id="q-${l.sku}" class="input" style="width:76px;min-height:36px;padding:4px 6px;text-align:right" type="number" min="0" max="9999" value="${l.qty}" data-line="${l.productId}" data-colour="${l.colour}" data-size="${l.size}"></td>
                  <td class="num">${money(l.qty * l.unitPrice)}</td></tr>`)}
              </tbody></table></div></div>`;
          })}
          <div class="row"><a class="btn btn-line" href="catalogue.html">Add more styles</a><button class="btn btn-ghost" data-clear>Clear order list</button></div>
        </div>
        <aside class="card card-pad sticky"><h3 class="mb">Summary</h3>
          <div class="sum"><div><span>Pieces</span><span>${c.pieces}</span></div><div><span>Subtotal, before GST</span><span>${money(c.subtotal)}</span></div>
            ${c.advancePct != null ? html`<div><span>Advance due (${c.advancePct}%)</span><span>${money(c.advanceDue)}</span></div><div><span>Balance on delivery</span><span>${money(c.balanceDue)}</span></div>` : ''}
            <div class="tot"><span>Order value</span><span>${money(c.subtotal)}</span></div></div>
          <p class="small muted mt">GST and delivery charges to be confirmed.</p>
          <div class="stack" style="gap:8px">
            ${blocked || c.shortages.length ? html`<button class="btn btn-red btn-block" disabled>Continue to checkout</button>` : html`<a class="btn btn-red btn-block" href="checkout.html">Continue to checkout</a>`}
            <button class="btn btn-line btn-block" data-quote>Request a quote</button></div>
          <p class="small muted mt mb-0">Quotes are for a better rate on larger orders. We reply within one working day.</p>
        </aside>
      </div></div>`;
    };
    on(main, '[data-remove]', el => act(() => api.cart.removeStyle(el.dataset.remove), 'Style removed').then(render));
    on(main, '[data-clear]', () => confirmBox('Clear order list', 'This removes all styles from your order list.', 'Clear list', async () => { await api.cart.clear(); await render(); }, true));
    on(main, '[data-line]', el => act(() => api.cart.setLine(el.dataset.line, el.dataset.colour, el.dataset.size, Math.max(0, Math.floor(Number(el.value) || 0)))).then(render), 'change');
    on(main, '[data-quote]', async () => {
      const c = await api.cart.get();
      modal('Request a quote', html`<form class="form" novalidate><p class="mb-0">We will review your ${c.pieces} pieces and send an offer, usually within one working day. Your order list will be moved to this quote.</p>
        ${field('note', 'Message to sales (optional)', { type: 'textarea', rows: 3, placeholder: 'For example: target price or delivery date' })}
        ${c.shortages.length ? checkbox('acknowledgeShortage', 'I understand some sizes are short of stock and may take longer.') : ''}
        <button class="btn btn-red" type="submit">Send quote request</button></form>`, async v => {
          const r = await api.quotes.request(v);
          location.href = 'account-quote.html?id=' + r.id + '&new=1';
        });
    });
    await render();
  });

  /* ---------- Quick order ---------- */
  page('quick-order', { layout: 'public', access: 'approved' }, async main => {
    const skus = await api.catalog.skus();
    const bySku = new Map(skus.map(s => [s.sku.toUpperCase(), s]));
    main.innerHTML = html`${pageHead('Quick order', 'Know your codes? Paste them here and add everything at once.', [['Home', 'index.html'], ['Quick order']])}
    <div class="wrap" style="padding-top:24px"><div class="split">
      <div class="form-card"><form class="form" novalidate>
        <div class="field" data-field="list"><label for="f-list">Codes and quantities</label><textarea class="input mono" id="f-list" name="list" rows="9" placeholder="VK7-TEE-01-SKY-M, 12&#10;VK7-TEE-01-SKY-L, 12"></textarea><span class="hint">One line each: code, then pieces.</span><span class="err" hidden></span></div>
        <div id="check"></div>
        <button class="btn btn-red" type="submit">Add to order list</button></form></div>
      <div class="card"><div class="card-head"><h3>Example codes</h3></div><div class="tw" style="max-height:320px;overflow:auto"><table class="t"><tbody>${skus.slice(0, 40).map(s => html`<tr><td class="mono small">${s.sku}</td><td class="small muted">${s.colour} ${s.size}</td></tr>`)}</tbody></table></div></div>
    </div></div>`;
    onSubmit(main.querySelector('form'), async v => {
      const rows = v.list.split('\n').map(x => x.trim()).filter(Boolean), items = [], bad = [];
      rows.forEach(r => {
        const [code, qty] = r.split(/[,\t ]+/);
        const s = bySku.get((code || '').toUpperCase()), q = Number(qty);
        if (!s || !Number.isInteger(q) || q < 1) bad.push(r); else items.push({ productId: s.productId, colour: s.colour, size: s.size, qty: q });
      });
      if (!rows.length) throw new VK7.ApiError('Add at least one line.', { fields: { list: 'Add at least one line.' } });
      if (bad.length) throw new VK7.ApiError('Please check these lines: ' + bad.join(' | '), { fields: { list: 'Some lines are not valid.' } });
      await api.cart.addMany(items);
      location.href = 'cart.html';
    });
  });

  /* ---------- Checkout ---------- */
  page('checkout', { layout: 'public', access: 'approved' }, async main => {
    const quoteId = param('quote');
    const c = await api.checkout.prepare(quoteId);
    if (!c.lines.length) return VK7.redirect('cart.html');
    if (c.violations.length || (!quoteId && c.shortages.length)) return VK7.redirect('cart.html');
    const def = c.addresses.find(a => a.isDefault) || c.addresses[0];
    main.innerHTML = html`${pageHead('Checkout', quoteId ? 'Order from accepted quote ' + c.quote.number + '. Your price is locked.' : 'Check your details and place your order.', [['Home', 'index.html'], ['Order list', 'cart.html'], ['Checkout']])}
    <div class="wrap" style="padding-top:24px"><form class="split" novalidate>
      <div class="stack">
        ${c.shortages.length ? notice('bad', 'Not enough stock now', 'Stock has changed since your quote. Please contact sales before ordering.') : ''}
        <div class="card card-pad"><div class="row between mb"><h3>Delivery address</h3><a class="link small" href="account-addresses.html">Manage addresses</a></div>
          <div class="field" data-field="addressId"><div class="stack" style="gap:8px">${c.addresses.map(a => html`<label class="card card-pad check" style="align-items:flex-start;padding:12px"><input type="radio" name="addressId" value="${a.id}" ${a.id === def.id ? raw('checked') : ''}><span><strong>${a.label}</strong><br><span class="muted small">${a.line1}, ${a.city}, ${a.state} ${a.pin} · ${a.phone}</span></span></label>`)}</div><span class="err" hidden></span></div></div>
        <div class="card card-pad"><h3 class="mb">Order details</h3><div class="form">${field('poRef', 'Your reference (optional)', { hint: 'For example your purchase order number.' })}${field('notes', 'Delivery notes (optional)', { type: 'textarea', rows: 3 })}</div></div>
        <div class="card card-pad"><h3 class="mb">How you pay</h3>
          ${c.advancePct != null ? html`<p>After placing the order you pay a <strong>${c.advancePct}% advance, about ${money(c.advanceDue)}</strong>, online or by UPI or bank transfer. Stock is held for ${c.holdHours} hours.</p>
          <p class="mb-0 muted">The rest is due after delivery. The exact amounts, including delivery charges, appear on your order page.</p>` : html`<p class="mb-0">No payment is taken on this website. VK7SPORTS will contact you to confirm payment terms for this order.</p>`}</div>
        <div class="card"><div class="card-head"><h3>Items (${c.pieces} pieces)</h3></div>${lineTable(c.lines)}</div>
      </div>
      <aside class="card card-pad sticky"><h3 class="mb">Summary</h3>
        <div class="sum"><div><span>Pieces</span><span>${c.pieces}</span></div><div><span>Order value, before GST</span><span>${money(c.subtotal)}</span></div>${c.advancePct != null ? html`<div><span>Balance on delivery</span><span>${money(c.balanceDue)}</span></div>
          <div class="tot"><span>Advance due now</span><span>${money(c.advanceDue)}</span></div>` : html`<div class="tot"><span>Order value</span><span>${money(c.subtotal)}</span></div>`}</div>
        <div class="mt">${checkbox('agree', html`I accept the <a class="link" href="policy.html?doc=terms" target="_blank">terms of sale</a>.`)}</div>
        <button class="btn btn-red btn-block mt" type="submit" ${c.shortages.length ? raw('disabled') : ''}>Place order</button>
        <a class="btn btn-ghost btn-block mt" href="${quoteId ? 'account-quote.html?id=' + quoteId : 'cart.html'}">Go back</a>
      </aside></form></div>`;
    onSubmit(main.querySelector('form'), async v => {
      const r = await api.checkout.place({ ...v, quoteId });
      location.href = 'order-confirmation.html?id=' + r.id;
    });
  });

  page('order-confirmation', { layout: 'public', access: 'approved' }, async main => {
    const o = await api.orders.get(param('id'));
    main.innerHTML = html`<div class="wrap" style="max-width:640px;padding-top:48px"><div class="form-card center">
      <div class="state-ico" style="background:var(--ok-bg);color:var(--ok)">${icon('check', 24)}</div>
      <h1>Order received</h1><p class="muted">Thank you. Your order number is</p>
      <p class="mono" style="font-size:22px;font-weight:700;color:var(--navy)">${o.number}</p>
      ${o.advancePct != null ? html`<div class="sum" style="text-align:left;margin:16px 0"><div><span>Advance due</span><strong>${money(o.advanceDue)}</strong></div><div><span>Pay by</span><strong>${dateTime(o.holdUntil)}</strong></div></div>
      <ol style="text-align:left;color:var(--ink-2)"><li>Pay the advance online, or by UPI or bank transfer.</li><li>We confirm your order and pack it.</li><li>Follow your delivery, and pay the balance after it arrives.</li></ol>` : html`<p>VK7SPORTS will contact you to confirm payment terms and delivery.</p>`}
      <div class="row" style="justify-content:center"><a class="btn btn-red" href="account-order.html?id=${o.id}">${o.advancePct != null ? 'Pay and view order' : 'View order'}</a><a class="btn btn-line" href="catalogue.html">Keep shopping</a></div>
    </div></div>`;
  });

  /* ---------- Account overview ---------- */
  page('account', { layout: 'account', access: 'retailer' }, async (main, { me }) => {
    if (!me.approved) {
      const r = await api.account.get();
      const rejected = r.status === 'rejected';
      main.innerHTML = html`${title('Hello, ' + me.name)}
      ${param('welcome') ? html`<div class="mb">${notice('ok', 'Application received', 'Thank you for applying. We will email you once your shop has been reviewed.')}</div>` : ''}
      <div class="card card-pad"><div class="row between mb"><h3>Trade account status</h3>${badge(r.status)}</div>
        ${rejected ? html`<p>We could not approve this application.</p><p class="muted">Reason: ${r.rejectReason}</p><a class="btn btn-line" href="contact.html">Contact us</a>`
          : html`<p>Our team is reviewing <strong>${r.company}</strong>. This usually takes one working day.</p><ul class="ticks"><li>Application received on ${date(r.appliedAt)}</li><li>You can browse the catalogue now</li><li>Prices and ordering open after approval</li></ul><a class="btn btn-navy" href="catalogue.html">Browse catalogue</a>`}
      </div>`;
      return;
    }
    const o = await api.account.overview();
    const orderRows = o.recent.map(x => html`<tr class="click" data-href="account-order.html?id=${x.id}"><td class="mono">${x.number}</td><td>${date(x.createdAt)}</td><td>${badge(x.status)}</td><td class="num">${money(x.subtotal)}</td></tr>`);
    main.innerHTML = html`${title('Hello, ' + me.name, me.company, html`<a class="btn btn-red" href="catalogue.html">Start an order</a>`)}
      <div class="stack">
        ${o.artwork.map(a => notice('warn', 'Artwork waiting for you', html`Please review the proof for <a class="link" href="account-order.html?id=${a.id}">${a.number}</a>.`))}
        ${o.quotesToReview ? notice('info', 'Quote ready', html`You have ${o.quotesToReview} ${o.quotesToReview === 1 ? 'quote' : 'quotes'} to review. <a class="link" href="account-quotes.html">View quotes</a>`) : ''}
        <div class="tiles">
          <a class="stat" href="account-orders.html"><span>Open orders</span><strong>${o.openOrders}</strong></a>
          <a class="stat" href="account-orders.html"><span>Awaiting your advance</span><strong>${o.awaitingAdvance}</strong></a>
          <a class="stat" href="account-quotes.html"><span>Quotes to review</span><strong>${o.quotesToReview}</strong></a>
          <a class="stat" href="account-statement.html"><span>Balance outstanding</span><strong>${money(o.balance)}</strong></a>
        </div>
        <div class="card"><div class="card-head"><h3>Recent orders</h3><a class="link small" href="account-orders.html">View all</a></div>
          ${o.recent.length ? html`<div class="tw"><table class="t"><thead><tr><th>Order</th><th>Date</th><th>Status</th><th class="num">Value</th></tr></thead><tbody>${orderRows}</tbody></table></div>` : empty('No orders yet', 'Your orders will appear here.', html`<a class="btn btn-navy" href="catalogue.html">Browse catalogue</a>`)}</div>
      </div>`;
    on(main, '[data-href]', el => { location.href = el.dataset.href; });
  });

  /* ---------- Orders ---------- */
  const TABS = [['All', () => true], ['Action needed', o => ['Awaiting advance', 'Awaiting balance', 'Artwork awaiting approval'].includes(o.status)], ['In progress', o => ['Order placed', 'Confirmed', 'Packing', 'Dispatched', 'Production authorised', 'In production'].includes(o.status)], ['Completed', o => ['Delivered', 'Paid in full'].includes(o.status)], ['Cancelled', o => ['Cancelled', 'Expired'].includes(o.status)]];
  page('account-orders', { layout: 'account', access: 'retailer' }, async main => {
    const orders = await api.orders.list();
    let tab = 0;
    const render = () => {
      const list = orders.filter(TABS[tab][1]);
      main.innerHTML = html`${title('My orders', null, html`<a class="btn btn-red" href="catalogue.html">New order</a>`)}
      <div class="card"><div class="tabs" role="tablist">${TABS.map((t, i) => html`<button role="tab" aria-selected="${String(i === tab)}" data-tab="${i}">${t[0]}</button>`)}</div>
      ${list.length ? html`<div class="tw"><table class="t"><thead><tr><th>Order</th><th>Date</th><th>Type</th><th class="num">Pieces</th><th>Status</th><th class="num">Value</th></tr></thead><tbody>
        ${list.map(o => html`<tr class="click" data-href="account-order.html?id=${o.id}"><td class="mono"><a href="account-order.html?id=${o.id}">${o.number}</a></td><td>${date(o.createdAt)}</td><td>${o.type === 'custom' ? 'Customised' : 'Regular'}</td><td class="num">${pcs(o.lines)}</td><td>${badge(o.status)}</td><td class="num">${money(o.subtotal)}</td></tr>`)}
      </tbody></table></div>` : empty('No orders here', 'Orders matching this filter will show here.')}</div>`;
    };
    on(main, '[data-tab]', el => { tab = Number(el.dataset.tab); render(); });
    on(main, '[data-href]', (el, e) => { if (!e.target.closest('a')) location.href = el.dataset.href; });
    render();
  });

  const payBox = o => {
    const details = html`<dl class="kv"><dt>UPI ID</dt><dd>${PAY.upiId || tbc()}</dd><dt>Bank</dt><dd>${PAY.bankName || tbc()}</dd><dt>Account name</dt><dd>${PAY.accountName || tbc()}</dd><dt>Account number</dt><dd>${PAY.accountNumber || tbc()}</dd><dt>IFSC</dt><dd>${PAY.ifsc || tbc()}</dd></dl>`;
    const pending = o.payments.find(p => p.status === 'submitted');
    const advanceDone = o.payments.some(p => p.kind === 'advance' && p.status === 'verified');
    const canPayAdvance = o.payable !== undefined ? o.payable === 'advance' : o.status === 'Awaiting advance' && !advanceDone && (o.type === 'standard' || (o.artwork && o.artwork.status === 'approved'));
    const canPayBalance = o.payable !== undefined ? o.payable === 'balance' : ['Awaiting balance', 'Delivered'].includes(o.status) && o.outstanding > 0;
    let form = '';
    if (pending) form = notice('info', 'Payment being verified', html`We have your reference <span class="mono">${pending.ref}</span> for ${money(pending.amount)}. Our finance team will confirm it soon.`);
    else if (canPayAdvance || canPayBalance) {
      const kind = canPayAdvance ? 'advance' : 'balance', amount = canPayAdvance ? o.advanceDue : o.outstanding;
      form = html`<div class="row mt"><button class="btn btn-red" type="button" data-pay="${kind}">Pay ${money(amount)} online</button></div><h4 class="mb" style="margin-top:20px">Paid by UPI or bank transfer? Enter your reference</h4>
      <form class="form" id="payform" novalidate data-kind="${kind}"><div class="form-2">${field('method', 'Paid by', { type: 'select', required: true, options: ['UPI', 'Bank transfer'] })}${field('amount', 'Amount (₹)', { type: 'number', required: true, value: amount })}</div>${field('ref', 'Payment reference (UTR)', { required: true, placeholder: 'For example 412345678901', maxlength: 30 })}<button class="btn btn-red" type="submit">Submit reference</button></form>`;
    }
    if (!pending && !canPayAdvance && !canPayBalance) return '';
    return html`<div class="card card-pad">
      <div class="row between mb"><h3>${canPayBalance ? 'Balance payment' : 'Payment'}</h3>${o.holdUntil && canPayAdvance ? html`<span class="badge b-warn">${VK7.hoursLeft(o.holdUntil)} hours left</span>` : ''}</div>
      ${canPayAdvance || canPayBalance ? html`<p>Please pay <strong>${money(canPayAdvance ? o.advanceDue : o.outstanding)}</strong> using these details.</p>${details}` : ''}
      ${form}
      <p class="small muted mt mb-0">Never share your UPI PIN or OTP with anyone.</p></div>`;
  };

  page('account-order', { layout: 'account', access: 'retailer' }, async main => {
    const id = param('id');
    const render = async () => {
      const o = await api.orders.get(id);
      const rejected = o.payments.filter(p => p.status === 'rejected').pop();
      main.innerHTML = html`
      ${title(o.number, (o.type === 'custom' ? 'Customised order' : 'Regular order') + ' placed on ' + date(o.createdAt), html`<div class="row">${badge(o.status)}</div>`)}
      <div class="stack">
        <div class="card card-pad">${tracker(o)}</div>
        ${rejected && o.status === 'Awaiting advance' ? notice('bad', 'Payment reference not accepted', html`${rejected.reason} Please check and submit it again.`) : ''}
        ${o.artwork && o.artwork.status === 'awaiting' ? html`<div class="card card-pad"><h3 class="mb">Artwork proof, version ${o.artwork.version}</h3>
          <div class="two"><img src="${o.artwork.image}" alt="Artwork proof" style="border-radius:8px;max-height:340px;object-fit:contain;background:var(--bg);width:100%"><div><p>${o.artwork.note}</p>${notice('warn', 'Please check carefully', 'Check every spelling, number and colour. After you approve, production can begin and changes may cost extra.')}<div class="row mt"><button class="btn btn-red" data-art="approve">Approve artwork</button><button class="btn btn-line" data-art="change">Request a change</button></div></div></div></div>`
          : o.artwork ? html`<div class="card card-pad"><h3>Artwork, version ${o.artwork.version}</h3><p class="mb-0 muted">${o.artwork.status === 'approved' ? o.artwork.reply + ' on ' + date(o.artwork.approvedAt) : 'Change requested: ' + o.artwork.reply}</p></div>` : ''}
        ${payBox(o)}
        ${o.tracking ? trackingPanel(o.tracking) : o.shipment ? html`<div class="card card-pad"><h3 class="mb">Delivery</h3><dl class="kv"><dt>Courier or transporter</dt><dd>${o.shipment.courier}</dd><dt>LR number</dt><dd class="mono">${o.shipment.lr}</dd><dt>Dispatched on</dt><dd>${date(o.shipment.date)}</dd></dl></div>` : ''}
        <div class="card"><div class="card-head"><h3>Items (${pcs(o.lines)} pieces)</h3></div>${lineTable(o.lines)}</div>
        <div class="two">
          <div class="card card-pad"><h3 class="mb">Money</h3><div class="sum"><div><span>Order value, before GST</span><span>${money(o.subtotal)}</span></div>${o.advancePct != null ? html`<div><span>Advance (${o.advancePct}%)</span><span>${money(o.advanceDue)}</span></div><div><span>Paid and verified</span><span>${money(o.paid)}</span></div><div class="tot"><span>Balance outstanding</span><span>${money(o.outstanding)}</span></div>` : html`<div class="tot"><span>Payment</span><span>To be confirmed</span></div>`}</div>
            ${o.payments.length ? html`<div class="mt small">${o.payments.map(p => html`<div class="row between" style="padding:4px 0"><span class="mono">${p.ref}</span><span>${money(p.amount)}</span>${badge(p.status)}</div>`)}</div>` : ''}</div>
          <div class="card card-pad"><h3 class="mb">Delivery address</h3><p class="mb-0">${o.address.label}<br><span class="muted">${o.address.line1}, ${o.address.city}, ${o.address.state} ${o.address.pin}<br>${o.address.phone}</span></p>${o.poRef ? html`<p class="mt mb-0 small">Your reference: ${o.poRef}</p>` : ''}</div>
        </div>
        <div class="card card-pad"><h3 class="mb">History</h3>${timeline(o.history)}</div>
        <div class="row"><a class="btn btn-line" href="invoice.html?id=${o.id}">View invoice</a>${o.type === 'standard' ? html`<button class="btn btn-line" data-reorder>Order again</button>` : ''}${o.status === 'Awaiting advance' && !o.paid && o.type === 'standard' ? html`<button class="btn btn-danger" data-cancel>Cancel order</button>` : ''}<a class="btn btn-ghost" href="contact.html">Need help?</a></div>
      </div>`;
      const pf = main.querySelector('#payform');
      if (pf) onSubmit(pf, async v => { await api.orders.submitPayment(id, { ...v, kind: pf.dataset.kind }); toast('Reference submitted'); await render(); });
      if (o.tracking) mountMap(main, o.tracking);
    };
    on(main, '[data-pay]', el => act(() => payOnline(id, el.dataset.pay, render)));
    on(main, '[data-reorder]', () => act(() => api.orders.reorder(id)).then(() => { location.href = 'cart.html'; }));
    on(main, '[data-cancel]', () => reasonBox('Cancel order', 'Held stock will be released.', 'Cancel order', async r => { await api.orders.cancel(id, r); toast('Order cancelled'); await render(); }));
    on(main, '[data-art]', el => {
      if (el.dataset.art === 'approve') modal('Approve artwork', html`<form class="form" novalidate><p class="mb-0">I confirm this design, spelling and numbers are correct.</p>${field('name', 'Type your full name', { required: true })}<button class="btn btn-red" type="submit">Approve artwork</button></form>`, async v => { await api.orders.artwork(id, { approve: true, name: v.name }); toast('Artwork approved'); await render(); });
      else modal('Request a change', html`<form class="form" novalidate>${field('reply', 'What should we change?', { type: 'textarea', required: true })}<button class="btn btn-red" type="submit">Send request</button></form>`, async v => { await api.orders.artwork(id, { approve: false, reply: v.reply }); toast('Change requested'); await render(); });
    });
    await render();
  });

  page('invoice', { layout: 'public', access: 'retailer' }, async main => {
    const id = param('id'), i = await api.orders.invoice(id);
    main.innerHTML = html`<div class="wrap"><div class="row no-print" style="padding-top:16px"><button class="btn btn-navy" data-print>Print or save as PDF</button><a class="btn btn-line" href="account-order.html?id=${id}">Back to order</a></div>${invoiceDoc(i)}</div>`;
    on(main, '[data-print]', () => window.print());
  });

  /* ---------- Quotes ---------- */
  page('account-quotes', { layout: 'account', access: 'approved' }, async main => {
    const list = await api.quotes.list();
    main.innerHTML = html`${title('My quotes', 'Ask for a better rate from your order list.', html`<a class="btn btn-red" href="cart.html">Open order list</a>`)}
    <div class="card">${list.length ? html`<div class="tw"><table class="t"><thead><tr><th>Quote</th><th>Date</th><th class="num">Pieces</th><th>Valid until</th><th>Status</th></tr></thead><tbody>
      ${list.map(q => html`<tr class="click" data-href="account-quote.html?id=${q.id}"><td class="mono"><a href="account-quote.html?id=${q.id}">${q.number}</a></td><td>${date(q.createdAt)}</td><td class="num">${pcs(q.lines)}</td><td>${q.validUntil ? date(q.validUntil) : '-'}</td><td>${badge(q.status)}</td></tr>`)}
    </tbody></table></div>` : empty('No quotes yet', 'Add styles to your order list and choose Request a quote.', html`<a class="btn btn-navy" href="catalogue.html">Browse catalogue</a>`, 'file')}</div>`;
    on(main, '[data-href]', (el, e) => { if (!e.target.closest('a')) location.href = el.dataset.href; });
  });

  page('account-quote', { layout: 'account', access: 'approved' }, async main => {
    const id = param('id');
    const render = async () => {
      const q = await api.quotes.get(id);
      const offered = q.lines.some(l => l.offerPrice != null);
      const listTotal = q.lines.reduce((s, l) => s + l.qty * l.unitPrice, 0);
      const offerTotal = q.lines.reduce((s, l) => s + l.qty * (l.offerPrice ?? l.unitPrice), 0);
      main.innerHTML = html`${title(q.number, 'Requested on ' + date(q.createdAt), badge(q.status))}
      <div class="stack">
        ${param('new') ? notice('ok', 'Quote request sent', 'We will reply within one working day. You will see our offer here.') : ''}
        ${q.status === 'Quote ready' ? html`<div class="card card-pad"><div class="row between"><div><h3>Your offer is ready</h3><p class="muted mb-0">Valid until ${date(q.validUntil)}. Accepting locks these prices.</p></div><div class="right"><div class="muted small" style="text-decoration:line-through">${money(listTotal)}</div><div class="price" style="font-size:22px">${money(offerTotal)}</div></div></div>
          <div class="row mt"><button class="btn btn-red" data-accept>Accept offer</button><button class="btn btn-line" data-counter>Ask for changes</button><button class="btn btn-ghost" data-decline>Decline</button></div></div>` : ''}
        ${q.status === 'Accepted' ? html`<div class="card card-pad row between"><div><h3>Offer accepted</h3><p class="muted mb-0">Your price is locked. Place the order to reserve stock.</p></div><a class="btn btn-red" href="checkout.html?quote=${q.id}">Place order</a></div>` : ''}
        ${q.status === 'Ordered' ? notice('ok', 'Ordered', html`This quote became <a class="link" href="account-order.html?id=${q.orderId}">your order</a>.`) : ''}
        ${q.status === 'Expired' ? notice('bad', 'Quote expired', 'Please add the items to your order list and request a new quote.') : ''}
        <div class="card"><div class="card-head"><h3>Items (${pcs(q.lines)} pieces)</h3></div><div class="tw"><table class="t"><thead><tr><th>Item</th><th>Colour</th><th>Size</th><th class="num">Pieces</th><th class="num">Your price</th>${offered ? html`<th class="num">Our offer</th>` : ''}</tr></thead><tbody>
          ${q.lines.map(l => html`<tr><td>${l.name}</td><td>${l.colour}</td><td>${l.size}</td><td class="num">${l.qty}</td><td class="num">${money(l.unitPrice)}</td>${offered ? html`<td class="num"><strong>${l.offerPrice == null ? '-' : money(l.offerPrice)}</strong></td>` : ''}</tr>`)}
        </tbody></table></div></div>
        <div class="card"><div class="card-head"><h3>Messages</h3></div><div class="card-pad stack">
          ${q.messages.length ? q.messages.map(m => html`<div class="notice ${m.from === 'staff' ? 'n-info' : ''}" style="${m.from === 'staff' ? '' : 'background:var(--bg);border-color:var(--line)'}"><div><strong>${m.by}</strong><span class="small muted">${dateTime(m.at)}</span><div>${m.text}</div></div></div>`) : html`<p class="muted mb-0">No messages yet.</p>`}
          ${['Quote requested', 'Quote ready'].includes(q.status) ? html`<form class="form" id="msg" novalidate>${field('text', 'Send a message', { type: 'textarea', rows: 2 })}<div><button class="btn btn-line" type="submit">Send</button></div></form>` : ''}
        </div></div>
      </div>`;
      const f = main.querySelector('#msg');
      if (f) onSubmit(f, async v => { await api.quotes.message(id, v.text); await render(); });
    };
    on(main, '[data-accept]', () => confirmBox('Accept offer', 'This locks the offered prices. You can then place the order.', 'Accept offer', async () => { await api.quotes.accept(id); await render(); }));
    on(main, '[data-decline]', () => confirmBox('Decline offer', 'This closes the quote.', 'Decline', async () => { await api.quotes.decline(id); await render(); }, true));
    on(main, '[data-counter]', () => modal('Ask for changes', html`<form class="form" novalidate>${field('text', 'What would you like changed?', { type: 'textarea', required: true })}<button class="btn btn-red" type="submit">Send</button></form>`, async v => { await api.quotes.message(id, v.text); await render(); }));
    await render();
  });

  page('account-enquiries', { layout: 'account', access: 'retailer' }, async main => {
    const list = await api.enquiries.mine();
    main.innerHTML = html`${title('Enquiries', 'Bulk and customised enquiries you have sent.', html`<a class="btn btn-red" href="custom-orders.html">New customised enquiry</a>`)}
    <div class="card">${list.length ? html`<div class="tw"><table class="t"><thead><tr><th>Reference</th><th>Date</th><th>Type</th><th>Details</th><th>Status</th></tr></thead><tbody>${list.map(e => html`<tr><td class="mono">${e.number}</td><td>${date(e.createdAt)}</td><td>${e.type === 'custom' ? 'Customised' : 'Bulk'}</td><td>${e.message}</td><td>${badge(e.status)}</td></tr>`)}</tbody></table></div>` : empty('No enquiries yet', 'Enquiries you send while signed in will appear here.', null, 'mail')}</div>`;
  });

  page('account-statement', { layout: 'account', access: 'approved' }, async main => {
    const s = await api.account.statement();
    main.innerHTML = html`${title('Account statement', 'Every order and verified payment on your account.')}
    <div class="stack"><div class="tiles"><div class="stat"><span>Total ordered</span><strong>${money(s.billed)}</strong></div><div class="stat"><span>Total paid</span><strong>${money(s.paid)}</strong></div><div class="stat"><span>Balance outstanding</span><strong>${money(s.balance)}</strong></div></div>
    <div class="card">${s.rows.length ? html`<div class="tw"><table class="t"><thead><tr><th>Date</th><th>Details</th><th class="num">Debit</th><th class="num">Credit</th><th class="num">Balance</th></tr></thead><tbody>${s.rows.map(r => html`<tr><td>${date(r.at)}</td><td><a href="account-order.html?id=${r.ref}">${r.text}</a></td><td class="num">${r.debit ? money(r.debit) : ''}</td><td class="num">${r.credit ? money(r.credit) : ''}</td><td class="num">${money(r.balance)}</td></tr>`)}</tbody></table></div>` : empty('Nothing here yet', 'Your orders and payments will show here.', null, 'rupee')}</div></div>`;
  });

  page('account-notifications', { layout: 'account', access: 'retailer' }, async main => {
    const list = await api.notifications.list();
    main.innerHTML = html`${title('Notifications')}<div class="card">${list.length ? list.map(n => html`<a href="${n.link}" style="display:block;padding:12px 20px;border-bottom:1px solid var(--line);text-decoration:none"><strong style="font-weight:${n.read ? 400 : 600}">${n.title}</strong><div class="small muted">${dateTime(n.at)}</div></a>`) : empty('You are all caught up', 'Updates on your orders and quotes will appear here.', null, 'bell')}</div>`;
    api.notifications.readAll();
  });

  page('account-profile', { layout: 'account', access: 'retailer' }, async main => {
    const r = await api.account.get();
    main.innerHTML = html`${title('Shop profile')}<div class="stack">
      <div class="card card-pad"><h3 class="mb">Business details</h3><dl class="kv"><dt>Shop name</dt><dd>${r.company}</dd><dt>Type</dt><dd>${r.shopType}</dd><dt>GSTIN</dt><dd>${r.gstin || '-'}</dd><dt>Proof of business</dt><dd>${r.proof}</dd><dt>Status</dt><dd>${badge(r.status)}</dd></dl><p class="small muted mt mb-0">To change these details, please <a class="link" href="contact.html">contact us</a>.</p></div>
      <div class="form-card"><h3 class="mb">Your contact details</h3><form class="form" id="pf" novalidate><div class="form-2">${field('contact', 'Your name', { required: true, value: r.contact })}${field('phone', 'Mobile number', { required: true, type: 'tel', value: r.phone, maxlength: 10 })}</div>${field('email', 'Email', { value: r.email, hint: 'Email is your sign-in and cannot be changed here.' })}<div><button class="btn btn-navy" type="submit">Save changes</button></div></form></div>
      <div class="form-card"><h3 class="mb">Change password</h3><form class="form" id="pw" novalidate>${field('current', 'Current password', { type: 'password', required: true, autocomplete: 'current-password' })}<div class="form-2">${field('next', 'New password', { type: 'password', required: true, autocomplete: 'new-password' })}${field('confirm', 'Confirm new password', { type: 'password', required: true, autocomplete: 'new-password' })}</div><div><button class="btn btn-navy" type="submit">Update password</button></div></form></div></div>`;
    main.querySelector('#f-email').readOnly = true;
    onSubmit(main.querySelector('#pf'), async v => { await api.account.update(v); toast('Details saved'); });
    const pw = main.querySelector('#pw');
    onSubmit(pw, async v => { await api.account.password(v); pw.reset(); toast('Password updated'); });
  });

  page('account-addresses', { layout: 'account', access: 'retailer' }, async main => {
    const form = a => html`<form class="form" novalidate><input type="hidden" name="id" value="${a.id || ''}">${field('label', 'Label', { required: true, value: a.label || '', placeholder: 'Main shop' })}${field('line1', 'Address', { required: true, value: a.line1 || '' })}<div class="form-2">${field('city', 'City', { required: true, value: a.city || '' })}${field('state', 'State', { required: true, value: a.state || '' })}</div><div class="form-2">${field('pin', 'PIN code', { required: true, value: a.pin || '', maxlength: 6 })}${field('phone', 'Mobile number', { required: true, value: a.phone || '', maxlength: 10 })}</div><button class="btn btn-red" type="submit">Save address</button></form>`;
    const render = async () => {
      const r = await api.account.get();
      main.innerHTML = html`${title('Addresses', null, html`<button class="btn btn-red" data-add>Add address</button>`)}
      <div class="two">${r.addresses.map(a => html`<div class="card card-pad"><div class="row between"><h3>${a.label}</h3>${a.isDefault ? html`<span class="badge b-navy">Default</span>` : ''}</div><p class="muted">${a.line1}<br>${a.city}, ${a.state} ${a.pin}<br>${a.phone}</p><div class="row"><button class="btn btn-line btn-sm" data-edit="${a.id}">Edit</button>${a.isDefault ? '' : html`<button class="btn btn-ghost btn-sm" data-default="${a.id}">Make default</button><button class="btn btn-ghost btn-sm" data-del="${a.id}">Delete</button>`}</div></div>`)}</div>`;
      main._addresses = r.addresses;
    };
    const save = async v => { await api.account.saveAddress(v); toast('Address saved'); await render(); };
    on(main, '[data-add]', () => modal('Add address', form({}), save));
    on(main, '[data-edit]', el => modal('Edit address', form(main._addresses.find(a => String(a.id) === el.dataset.edit)), save));
    on(main, '[data-default]', el => act(() => api.account.defaultAddress(el.dataset.default), 'Default address updated').then(render));
    on(main, '[data-del]', el => confirmBox('Delete address', 'This address will be removed.', 'Delete', async () => { await api.account.deleteAddress(el.dataset.del); await render(); }, true));
    await render();
  });

  page('account-users', { layout: 'account', access: 'approved' }, async main => {
    const render = async () => {
      const r = await api.account.get();
      main.innerHTML = html`${title('Shop logins', 'Give your staff their own sign-in.', html`<button class="btn btn-red" data-add>Add a login</button>`)}
      <div class="card"><div class="tw"><table class="t"><thead><tr><th>Name</th><th>Email</th><th>Role</th><th></th></tr></thead><tbody>${r.users.map(u => html`<tr><td>${u.name}</td><td>${u.email}</td><td>${u.role}</td><td class="right">${u.role === 'Owner' ? '' : html`<button class="btn btn-ghost btn-sm" data-del="${u.id}">Remove</button>`}</td></tr>`)}</tbody></table></div></div>`;
    };
    on(main, '[data-add]', () => modal('Add a login', html`<form class="form" novalidate>${field('name', 'Name', { required: true })}${field('email', 'Email', { type: 'email', required: true })}${field('role', 'Role', { type: 'select', required: true, options: [['Buyer', 'Buyer: can order and request quotes'], ['Viewer', 'Viewer: can only see orders']] })}<button class="btn btn-red" type="submit">Add login</button></form>`, async v => { await api.account.addUser(v); toast('Login added'); await render(); }));
    on(main, '[data-del]', el => confirmBox('Remove login', 'This person will no longer be able to sign in.', 'Remove', async () => { await api.account.removeUser(el.dataset.del); await render(); }, true));
    await render();
  });
})();
