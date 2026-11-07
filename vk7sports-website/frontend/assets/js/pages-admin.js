/* Staff back office. Labels use plain business words; each screen is limited by role. */
(function () {
  const { amountTrail, invoiceDoc, api, html, raw, money, date, dateTime, param, icon, badge, tbc, notice, empty, tracker, timeline, field, checkbox, onSubmit, toast, modal, confirmBox, reasonBox, on, act, page, trackingPanel, mountMap } = VK7;
  const title = (t, sub, action) => html`<div class="ptitle"><div><h1>${t}</h1>${sub ? html`<p>${sub}</p>` : ''}</div>${action || ''}</div>`;
  const pcs = lines => lines.reduce((s, l) => s + l.qty, 0);
  /* Whether the staff member holds a desk area the server granted. */
  const AREA_FOR_ROLE = { Owner: 'reports', Administrator: 'reports', Sales: 'retailers', Warehouse: 'dispatch', Finance: 'payments' };
  const allowed = (me, ...roles) => roles.some(r => me.areas.includes(AREA_FOR_ROLE[r]));
  const rowLinks = main => on(main, '[data-href]', (el, e) => { if (!e.target.closest('a,button')) location.href = el.dataset.href; });
  const tableSearch = (main, render) => {
    on(main, '[data-q]', () => render(), 'input');
    on(main, '[data-s]', () => render(), 'change');
  };
  const filterBar = (placeholder, statuses) => html`<div class="filterbar"><label class="sr" for="tq">Search</label><input id="tq" class="input" data-q type="search" placeholder="${placeholder}"><label class="sr" for="ts">Status</label><select id="ts" class="input" data-s><option value="">All statuses</option>${statuses.map(s => html`<option>${s}</option>`)}</select></div>`;
  const listing = (main, head, bar, rows, emptyEl) => {
    main.innerHTML = html`${head}<div class="card">${bar}<div data-rows></div></div>`;
    const box = main.querySelector('[data-rows]');
    const render = () => {
      const q = (main.querySelector('[data-q]')?.value || '').toLowerCase();
      const s = main.querySelector('[data-s]')?.value || '';
      box.innerHTML = rows(q, s) || emptyEl;
    };
    tableSearch(main, render); rowLinks(main); render();
    return render;
  };

  /* ---------- Dashboard ---------- */
  page('admin', { layout: 'admin', access: 'staff:dashboard' }, async (main, { me }) => {
    const d = await api.admin.dashboard();
    const can = p => me.perms.includes(p);
    const tile = (label, value, href, note, perm) => value != null && (!perm || can(perm)) ? html`<a class="stat" href="${href}"><span>${label}</span><strong>${value}</strong>${note ? html`<em>${note}</em>` : ''}</a>` : '';
    main.innerHTML = html`${title('Dashboard', 'What needs attention today.')}
      <div class="stack">
        <div class="tiles">
          ${tile('Orders today', d.ordersToday, 'admin-orders.html', d.openOrders + ' open in total', 'orders')}
          ${tile('Payments to verify', d.awaitingVerification, 'admin-payments.html', d.awaitingAdvance + ' awaiting advance', 'payments')}
          ${tile('Money to collect', money(d.moneyToCollect), 'admin-reports.html', null, 'reports')}
          ${tile('Clients to approve', d.pendingRetailers, 'admin-retailers.html', null, 'retailers')}
          ${tile('Quotes to answer', d.openQuotes, 'admin-quotes.html', null, 'quotes')}
          ${tile('New enquiries', d.newEnquiries, 'admin-enquiries.html', null, 'enquiries')}
          ${tile('Support tickets open', d.openSupport, 'admin-support.html', null, 'support')}
          ${tile('Refunds to pay', d.refundsPending, 'admin-orders.html', null, 'payments')}
          ${tile('High-risk retailers', d.highRiskClients, 'admin-retailers.html', 'Payment score below 40', 'retailers')}
          ${tile('Ready to dispatch', d.readyToDispatch, 'admin-dispatch.html', null, 'dispatch')}
          ${tile('Low stock sizes', d.lowStockCount, 'admin-inventory.html', null, 'inventory')}
        </div>
        <div class="two">
          ${can('orders') ? html`<div class="card"><div class="card-head"><h3>Latest orders</h3><a class="link small" href="admin-orders.html">View all</a></div><div class="tw"><table class="t"><tbody>${d.recent.map(o => html`<tr class="click" data-href="admin-order.html?id=${o.id}"><td><a class="mono small" href="admin-order.html?id=${o.id}">${o.number}</a><div class="small muted">${o.company}</div></td><td>${badge(o.status)}</td><td class="num">${money(o.subtotal)}</td></tr>`)}</tbody></table></div></div>` : ''}
          ${can('inventory') && d.lowStock ? html`<div class="card"><div class="card-head"><h3>Low stock</h3><a class="link small" href="admin-inventory.html">Open inventory</a></div>${d.lowStock.length ? html`<div class="tw"><table class="t"><tbody>${d.lowStock.map(l => html`<tr><td>${l.product}<div class="small muted">${l.variant}</div></td><td class="num"><span class="badge ${l.available ? 'b-warn' : 'b-bad'}">${l.available ? l.available + ' left' : 'Out of stock'}</span></td></tr>`)}</tbody></table></div>` : empty('Stock looks healthy', 'Nothing is below the low-stock level.', null, 'check')}</div>` : ''}
        </div>
      </div>`;
    rowLinks(main);
  });

  /* ---------- Retailers ---------- */
  page('admin-retailers', { layout: 'admin', access: 'staff:retailers' }, async main => {
    const list = (await api.admin.retailers()).sort((a, b) => (a.status === 'pending' ? 0 : 1) - (b.status === 'pending' ? 0 : 1));
    listing(main, title('Clients', 'Every retailer, what they have ordered and what they owe.'), filterBar('Search shop, contact or email', ['pending', 'approved', 'rejected', 'suspended']), (q, s) => {
      const r = list.filter(x => (!s || x.status === s) && [x.company, x.city, x.email, x.contact].join(' ').toLowerCase().includes(q));
      return r.length ? html`<div class="tw"><table class="t"><thead><tr><th>Shop</th><th>City</th><th>Applied</th><th class="num">Orders</th><th class="num">Outstanding</th><th>Payment score</th><th>Status</th></tr></thead><tbody>${r.map(x => html`<tr class="click" data-href="admin-retailer.html?id=${x.id}"><td><a href="admin-retailer.html?id=${x.id}"><strong>${x.company}</strong></a><div class="small muted">${x.contact}</div></td><td>${x.city}</td><td>${date(x.appliedAt)}</td><td class="num">${x.orders}</td><td class="num">${money(x.outstanding)}</td><td>${scoreBadge(x.score, x.tier)}</td><td>${badge(x.status)}</td></tr>`)}</tbody></table></div>` : '';
    }, empty('No retailers found', 'Try a different search.', null, 'users'));
  });

  const TIER_TONE = { Excellent: 'ok', Good: 'ok', Watch: 'warn', 'High risk': 'bad' };
  const scoreBadge = (score, tier) => score == null ? '-' : html`<span class="badge b-${TIER_TONE[tier] || 'mute'}">${score} · ${tier}</span>`;
  const standingPanel = (st, can) => html`<div class="card card-pad"><div class="row between mb"><h3>Payment standing</h3>${can ? html`<button class="btn btn-line btn-sm" data-standing>Change</button>` : ''}</div>
    <div class="standing-in"><div class="score-ring" style="--p:${st.score}"><strong>${st.score}</strong><span>${st.tier}</span></div>
    <dl class="kv"><dt>Orders paid in full</dt><dd>${st.completed_orders}</dd><dt>Advance asked</dt><dd>From ${st.advance_percent}%</dd><dt>Cash on delivery</dt><dd>${st.cod.eligible ? html`<span class="badge b-ok">Allowed</span>` : html`<span class="badge b-mute">Not allowed</span>`} <span class="small muted">${st.cod_override === 'auto' ? st.cod.reason : 'Set by staff: ' + (st.cod_override === 'allow' ? 'always allow' : 'never allow')}</span></dd></dl></div>
    ${st.events.length ? html`<div class="tw mt"><table class="t"><thead><tr><th>When</th><th>What happened</th><th>Order</th><th>By</th><th class="num">Points</th></tr></thead><tbody>${st.events.map(e => html`<tr><td class="nowrap">${date(e.created_at)}</td><td>${e.label}${e.note ? html`<div class="small muted">${e.note}</div>` : ''}</td><td class="mono small">${e.order_number || '-'}</td><td class="small">${e.actor || ''}</td><td class="num ${e.points < 0 ? 'neg' : 'pos'}">${e.points > 0 ? '+' : ''}${e.points}</td></tr>`)}</tbody></table></div>` : html`<p class="small muted mt mb-0">No score changes yet. Every retailer starts at 60.</p>`}</div>`;

  page('admin-retailer', { layout: 'admin', access: 'staff:retailers' }, async (main, { me }) => {
    const id = param('id');
    const can = allowed(me, 'Owner', 'Sales', 'Administrator');
    const render = async () => {
      const [r, st] = await Promise.all([api.admin.retailer(id), api.admin.standing(id)]);
      main.innerHTML = html`<a class="link small" href="admin-retailers.html">Back to clients</a>
      ${title(r.company, r.city + ', ' + r.state, badge(r.status))}
      <div class="stack">
        ${r.status === 'pending' && can ? html`<div class="card card-pad"><h3 class="mb">Review this application</h3><ul class="ticks"><li>Check the shop name and address</li><li>Check the GSTIN or other proof</li><li>Call the mobile number to confirm</li></ul><div class="row"><button class="btn btn-red" data-decide="approved">Approve retailer</button><button class="btn btn-danger" data-decide="rejected">Reject</button></div></div>` : ''}
        ${r.status === 'approved' && can ? html`<div class="row"><button class="btn btn-danger btn-sm" data-decide="suspended">Suspend account</button></div>` : ''}
        ${r.status === 'suspended' && can ? html`<div class="row"><button class="btn btn-red btn-sm" data-decide="approved">Reactivate account</button></div>` : ''}
        ${r.rejectReason ? notice('warn', 'Reason recorded', r.rejectReason) : ''}
        <div class="two"><div class="card card-pad"><h3 class="mb">Business</h3><dl class="kv"><dt>Type</dt><dd>${r.shopType}</dd><dt>GSTIN</dt><dd>${r.gstin || '-'}</dd><dt>Proof</dt><dd>${r.proof}</dd><dt>Price list</dt><dd>${r.priceList}</dd><dt>Applied</dt><dd>${date(r.appliedAt)}</dd></dl></div>
        <div class="card card-pad"><h3 class="mb">Contact</h3><dl class="kv"><dt>Person</dt><dd>${r.contact}</dd><dt>Mobile</dt><dd>${r.phone}</dd><dt>Email</dt><dd>${r.email}</dd><dt>Address</dt><dd>${r.addresses[0].line1}, ${r.addresses[0].city} ${r.addresses[0].pin}</dd></dl></div></div>
        ${standingPanel(st, can)}
        <div class="card"><div class="card-head"><h3>Orders</h3><span class="small muted">Balance ${money(r.statement.balance)}</span></div>${r.orders.length ? html`<div class="tw"><table class="t"><tbody>${r.orders.map(o => html`<tr class="click" data-href="admin-order.html?id=${o.id}"><td class="mono">${o.number}</td><td>${date(o.createdAt)}</td><td>${badge(o.status)}</td><td class="num">${money(o.subtotal)}</td></tr>`)}</tbody></table></div>` : empty('No orders yet', 'Orders from this retailer will show here.')}</div>
      </div>`;
    };
    on(main, '[data-standing]', async () => {
      const st = await api.admin.standing(id);
      modal('Change payment standing', html`<form class="form" novalidate>
        ${field('codOverride', 'Cash on delivery', { type: 'select', value: st.cod_override, options: [['auto', 'Automatic, from the score and history'], ['allow', 'Always allow for this retailer'], ['block', 'Never allow for this retailer']] })}
        ${field('points', 'Adjust the score (points, optional)', { type: 'number', min: -50, max: 50, hint: 'For example -10 for a bounced cheque, or 10 for a long and reliable history.' })}
        ${field('note', 'Reason', { type: 'textarea', required: true, rows: 2, hint: 'Saved with the change and in the activity log.' })}
        <button class="btn btn-red" type="submit">Save</button></form>`, async v => { await api.admin.updateStanding(id, v); toast('Standing updated'); await render(); });
    });
    on(main, '[data-decide]', el => {
      const d = el.dataset.decide;
      if (d === 'approved') confirmBox('Approve this retailer?', 'They will be able to see trade prices and place orders.', 'Approve', async () => { await api.admin.decideRetailer(id, { decision: d }); toast('Retailer approved'); await render(); });
      else reasonBox(d === 'rejected' ? 'Reject application' : 'Suspend account', 'This reason is saved in the activity log.', d === 'rejected' ? 'Reject' : 'Suspend', async reason => { await api.admin.decideRetailer(id, { decision: d, reason }); toast('Saved'); await render(); });
    });
    rowLinks(main);
    await render();
  });

  /* ---------- Enquiries ---------- */
  const ENQ = ['New', 'In follow-up', 'Won', 'Closed'];
  page('admin-enquiries', { layout: 'admin', access: 'staff:enquiries' }, async main => {
    let list = await api.admin.enquiries();
    const render = listing(main, title('Enquiries', 'Bulk, customised and contact-form messages from the website.'), filterBar('Search name, organisation or city', ENQ), (q, s) => {
      const r = list.filter(x => (!s || x.status === s) && [x.name, x.organisation, x.city, x.number].join(' ').toLowerCase().includes(q));
      return r.length ? html`<div class="tw"><table class="t"><thead><tr><th>Reference</th><th>From</th><th>Type</th><th>Quantity</th><th>Follow up</th><th>Status</th><th></th></tr></thead><tbody>${r.map(x => html`<tr><td class="mono small">${x.number}<div class="muted">${date(x.createdAt)}</div></td><td><strong>${x.organisation}</strong><div class="small muted">${x.name}, ${x.city}</div></td><td>${x.type === 'custom' ? 'Customised' : x.type === 'bulk' ? 'Bulk' : 'Contact'}</td><td>${x.quantity}</td><td>${x.followUp ? date(x.followUp) : '-'}</td><td>${badge(x.status)}</td><td class="right"><button class="btn btn-line btn-sm" data-open="${x.id}">Open</button></td></tr>`)}</tbody></table></div>` : '';
    }, empty('Nothing waiting', 'New enquiries will appear here.', null, 'mail'));
    on(main, '[data-open]', el => {
      const e = list.find(x => String(x.id) === el.dataset.open);
      modal(e.number, html`<div class="stack"><dl class="kv"><dt>From</dt><dd>${e.name}, ${e.organisation}</dd><dt>Type</dt><dd>${e.orgType}</dd><dt>Mobile</dt><dd>${e.phone}</dd><dt>Email</dt><dd>${e.email || '-'}</dd><dt>Quantity</dt><dd>${e.quantity}</dd><dt>Message</dt><dd>${e.message}</dd>${e.artworkName ? html`<dt>Artwork</dt><dd>${e.artworkName}</dd>` : ''}</dl>
        ${e.notes.length ? html`<div><h4 class="mb">Notes</h4>${e.notes.map(n => html`<p class="small mb-0"><strong>${n.by}</strong> ${dateTime(n.at)}<br>${n.text}</p>`)}</div>` : ''}
        <form class="form" novalidate><div class="form-2">${field('status', 'Status', { type: 'select', value: e.status, options: ENQ })}${field('followUp', 'Follow-up date', { type: 'date', value: e.followUp ? e.followUp.slice(0, 10) : '' })}</div>${field('note', 'Add a note', { type: 'textarea', rows: 2 })}<button class="btn btn-red" type="submit">Save</button></form></div>`, async v => {
          await api.admin.updateEnquiry(e.id, { status: v.status, note: v.note, followUp: v.followUp ? new Date(v.followUp).toISOString() : null });
          list = await api.admin.enquiries(); render(); toast('Enquiry saved');
        });
    });
  });

  /* ---------- Quotes ---------- */
  const QST = ['Quote requested', 'Quote ready', 'Accepted', 'Ordered', 'Declined', 'Expired'];
  page('admin-quotes', { layout: 'admin', access: 'staff:quotes' }, async main => {
    const list = await api.admin.quotes();
    listing(main, title('Quotes', 'Reply within one working day.'), filterBar('Search quote or shop', QST), (q, s) => {
      const r = list.filter(x => (!s || x.status === s) && [x.number, x.company].join(' ').toLowerCase().includes(q));
      return r.length ? html`<div class="tw"><table class="t"><thead><tr><th>Quote</th><th>Shop</th><th>Requested</th><th class="num">Pieces</th><th>Valid until</th><th>Status</th></tr></thead><tbody>${r.map(x => html`<tr class="click" data-href="admin-quote.html?id=${x.id}"><td><a class="mono" href="admin-quote.html?id=${x.id}">${x.number}</a></td><td>${x.company}</td><td>${date(x.createdAt)}</td><td class="num">${pcs(x.lines)}</td><td>${x.validUntil ? date(x.validUntil) : '-'}</td><td>${badge(x.status)}</td></tr>`)}</tbody></table></div>` : '';
    }, empty('No quotes found', 'Quote requests will appear here.', null, 'file'));
  });

  page('admin-quote', { layout: 'admin', access: 'staff:quotes' }, async main => {
    const id = param('id');
    const render = async () => {
      const q = await api.admin.quote(id);
      const editable = ['Quote requested', 'Quote ready'].includes(q.status);
      const theirs = editable && q.latestFrom === 'retailer';
      main.innerHTML = html`<a class="link small" href="admin-quotes.html">Back to quotes</a>${title(q.number, q.company + ' · requested ' + date(q.createdAt), badge(q.status))}
      <div class="stack">
        ${theirs ? html`<div class="card card-pad row between"><div><h3>Amount from the retailer</h3><p class="muted mb-0">Accept it, or send your own amount below.</p></div><div class="right"><div class="muted small" style="text-decoration:line-through">${money(q.listTotal)}</div><div class="price" style="font-size:22px">${money(q.latestAmount)}</div><button class="btn btn-red mt" type="button" data-accept-amount="${q.latestAmount}">Accept amount</button></div></div>` : ''}
        ${['Accepted', 'Ordered'].includes(q.status) ? html`<div class="card card-pad row between"><div><h3>Final amount agreed</h3><p class="muted mb-0">The retailer pays against this amount.</p></div><div class="price" style="font-size:22px">${money(q.latestAmount)}</div></div>` : ''}
        <div class="card"><div class="card-head"><h3>Lines</h3><span class="small muted"><span>List value, before GST</span> ${money(q.listTotal)}</span></div><div class="tw"><table class="t"><thead><tr><th>Item</th><th>Colour</th><th>Size</th><th class="num">Pieces</th><th class="num">List price</th></tr></thead><tbody>${q.lines.map(l => html`<tr><td>${l.name}</td><td>${l.colour}</td><td>${l.size}</td><td class="num">${l.qty}</td><td class="num">${money(l.unitPrice)}</td></tr>`)}</tbody></table></div></div>
        <div class="card"><div class="card-head"><h3>Amounts</h3></div><div class="card-pad stack">
          ${amountTrail(q)}
          ${editable ? html`<form class="form" id="offer" novalidate>${field('amount', 'Your amount for all items, before GST (₹)', { type: 'number', required: true, min: 1, max: q.listTotal })}<div class="row"><button class="btn btn-red" type="submit">Send amount</button><button class="btn btn-danger" type="button" data-reject>Reject quote</button></div></form>` : ''}
        </div></div>
      </div>`;
      if (editable) onSubmit(main.querySelector('#offer'), async v => { await api.admin.sendOffer(id, v.amount); toast('Amount sent'); await render(); });
    };
    on(main, '[data-accept-amount]', el => confirmBox('Accept amount', 'This fixes the amount as the final price for this quote.', 'Accept amount', async () => { await api.admin.acceptQuote(id, el.dataset.acceptAmount); toast('Amount accepted'); await render(); }));
    on(main, '[data-reject]', () => confirmBox('Reject quote', 'This closes the quote.', 'Reject quote', async () => { await api.admin.rejectQuote(id); toast('Quote rejected'); await render(); }, true));
    await render();
  });

  /* ---------- Orders ---------- */
  const OST = ['Awaiting advance', 'Confirmed', 'Packing', 'Dispatched', 'Delivered', 'Paid in full', 'Artwork awaiting approval', 'In production', 'Awaiting balance', 'On hold', 'Cancelled', 'Expired'];
  page('admin-orders', { layout: 'admin', access: 'staff:orders' }, async main => {
    const list = await api.admin.orders();
    listing(main, title('Orders', 'Every regular and customised order.'), filterBar('Search order or shop', OST), (q, s) => {
      const r = list.filter(x => (!s || x.status === s) && [x.number, x.company].join(' ').toLowerCase().includes(q));
      return r.length ? html`<div class="tw"><table class="t"><thead><tr><th>Order</th><th>Shop</th><th>Date</th><th>Type</th><th class="num">Pieces</th><th class="num">Value</th><th class="num">Outstanding</th><th>Status</th></tr></thead><tbody>${r.map(o => html`<tr class="click" data-href="admin-order.html?id=${o.id}"><td><a class="mono" href="admin-order.html?id=${o.id}">${o.number}</a></td><td>${o.company}</td><td>${date(o.createdAt)}</td><td>${o.type === 'custom' ? 'Customised' : 'Regular'}</td><td class="num">${pcs(o.lines)}</td><td class="num">${money(o.subtotal)}</td><td class="num">${money(o.outstanding)}</td><td>${badge(o.status)}</td></tr>`)}</tbody></table></div>` : '';
    }, empty('No orders found', 'Try a different search.'));
  });

  const shipForm = () => html`<form class="form" novalidate>${field('courier', 'Courier or transporter', { required: true })}${field('lr', 'LR or tracking number', { required: true })}${field('url', 'Tracking link (optional)', { type: 'url' })}<button class="btn btn-red" type="submit">Mark as dispatched</button></form>`;

  page('admin-order', { layout: 'admin', access: 'staff:orders' }, async (main, { me }) => {
    const id = param('id');
    const render = async () => {
      const o = await api.admin.order(id);
      const is = (...a) => allowed(me, ...a);
      const actions = [];
      if (o.status === 'Confirmed' && is('Owner', 'Warehouse')) actions.push(html`<button class="btn btn-red" data-to="Packing">Start packing</button>`);
      if (o.status === 'Packing' && is('Owner', 'Warehouse')) actions.push(html`<button class="btn btn-red" data-ship>Dispatch order</button>`);
      if (o.status === 'Dispatched' && is('Owner', 'Warehouse')) actions.push(o.tracking ? html`<button class="btn btn-red" data-scan="${o.tracking.id}">${o.tracking.simulated ? 'Simulate next courier scan' : 'Refresh courier status'}</button>` : html`<button class="btn btn-red" data-to="Delivered">Mark as delivered</button>`);
      if (o.type === 'custom' && o.status === 'Awaiting advance' && is('Owner', 'Sales') && o.artwork?.status === 'approved' && o.payments.some(p => p.kind === 'advance' && p.status === 'verified')) actions.push(html`<button class="btn btn-red" data-auth>Authorise production</button>`);
      if (o.status === 'Production authorised' && is('Owner', 'Sales')) actions.push(html`<button class="btn btn-red" data-to="In production">Start production</button>`);
      if (o.status === 'In production' && is('Owner', 'Sales')) actions.push(html`<button class="btn btn-red" data-to="Awaiting balance">Production finished</button>`);
      if (o.status === 'Awaiting balance' && o.outstanding === 0 && is('Owner', 'Warehouse')) actions.push(html`<button class="btn btn-red" data-ship>Dispatch order</button>`);
      if (o.artwork?.status === 'changes' && is('Owner', 'Sales')) actions.push(html`<button class="btn btn-red" data-art>Send new proof</button>`);
      if (['Delivered', 'Dispatched'].includes(o.status) && o.outstanding > 0 && is('Owner', 'Finance')) actions.push(html`<button class="btn btn-navy" data-balance>Record balance</button>`);
      if (['Dispatched', 'Delivered'].includes(o.status) && o.paymentMode === 'cod' && o.outstanding > 0 && is('Owner', 'Warehouse', 'Sales')) actions.push(html`<button class="btn btn-danger" data-refused>Parcel refused</button>`);
      if (o.refundStatus === 'pending' && is('Owner', 'Finance')) actions.push(html`<button class="btn btn-navy" data-refund>Record refund paid</button>`);
      if (o.status === 'On hold') actions.push(html`<button class="btn btn-navy" data-resume>Resume order</button>`);
      else if (!['Delivered', 'Paid in full', 'Cancelled', 'Expired', 'Returned'].includes(o.status)) actions.push(html`<button class="btn btn-line" data-hold>Put on hold</button>`);
      if (['Awaiting advance', 'Confirmed', 'Packing'].includes(o.status) && is('Owner', 'Sales')) actions.push(html`<button class="btn btn-danger" data-cancel>Cancel order</button>`);

      main.innerHTML = html`<a class="link small" href="admin-orders.html">Back to orders</a>
      ${title(o.number, o.company + ' · ' + date(o.createdAt), html`<div class="row">${badge(o.status)}<a class="btn btn-line btn-sm" href="admin-invoice.html?id=${o.id}">View invoice</a></div>`)}
      <div class="stack">
        ${o.firstOrder || o.riskNote ? notice('warn', o.firstOrder ? 'First order from this retailer' : 'Payment risk', o.riskNote || 'Check the details before packing.') : ''}
        <div class="card card-pad">${tracker(o)}${actions.length ? html`<div class="row mt-l">${actions}</div>` : ''}</div>
        ${o.tracking ? trackingPanel(o.tracking) : ''}
        ${o.designBrief ? notice('info', 'Design brief', o.designBrief) : ''}
        ${o.artwork ? html`<div class="card card-pad"><h3 class="mb">Artwork, version ${o.artwork.version}</h3><div class="row" style="align-items:flex-start;flex-wrap:nowrap"><img src="${o.artwork.image}" alt="Artwork proof" width="96" height="120" style="object-fit:cover;border-radius:4px"><div><p class="mb-0">${o.artwork.note}</p><p class="small muted mb-0">${o.artwork.status === 'awaiting' ? 'Waiting for the retailer' : o.artwork.reply}</p></div></div></div>` : ''}
        <div class="card"><div class="card-head"><h3>Items (${pcs(o.lines)} pieces)</h3></div><div class="tw"><table class="t"><thead><tr><th>Item</th><th>Colour</th><th>Size</th><th class="num">Pieces</th><th class="num">Price</th><th class="num">Total</th></tr></thead><tbody>${o.lines.map(l => html`<tr><td>${l.name}<div class="small muted mono">${l.sku}</div></td><td>${l.colour}</td><td>${l.size}</td><td class="num">${l.qty}</td><td class="num">${money(l.unitPrice)}</td><td class="num">${money(l.qty * l.unitPrice)}</td></tr>`)}</tbody></table></div></div>
        <div class="two">
          <div class="card card-pad"><h3 class="mb">Money</h3><div class="sum"><div><span>Payment</span><span>${o.paymentMode === 'cod' ? 'Cash on delivery for the balance' : 'Prepaid: balance before dispatch'}</span></div><div><span>Retailer score</span><span><a class="link" href="admin-retailer.html?id=${o.clientId}">${scoreBadge(o.clientScore, o.clientTier)}</a></span></div><div><span>Order value</span><span>${money(o.subtotal)}</span></div><div><span>Advance (${o.advancePct}%)</span><span>${money(o.advanceDue)}</span></div><div><span>Verified payments</span><span>${money(o.paid)}</span></div><div class="tot"><span>Outstanding</span><span>${money(o.outstanding)}</span></div>
            ${o.refundDue != null ? html`<div><span>Cancellation charge (${o.cancelledBy === 'business' ? 'business reason' : 'retailer'})</span><span>${money(o.cancelDeduction || 0)}</span></div><div><span>Refund due</span><span>${money(o.refundDue)} ${o.refundStatus ? badge(o.refundStatus === 'refunded' ? 'Refunded' : 'Refund pending') : ''}</span></div>` : ''}</div>
            ${o.payments.map(p => html`<div class="row between small mt"><span class="mono">${p.ref}</span><span>${money(p.amount)}</span>${badge(p.status)}</div>`)}</div>
          <div class="card card-pad"><h3 class="mb">Delivery</h3><p>${o.address.label}<br><span class="muted">${o.address.line1}, ${o.address.city}, ${o.address.state} ${o.address.pin}<br>${o.address.phone}</span></p>${o.shipment ? html`<dl class="kv"><dt>Courier</dt><dd>${o.shipment.courier}</dd><dt>LR number</dt><dd class="mono">${o.shipment.lr}</dd></dl>` : ''}</div>
        </div>
        <div class="card card-pad"><h3 class="mb">History</h3>${timeline(o.history)}</div>
      </div>`;
      if (o.tracking) mountMap(main, o.tracking);
    };
    on(main, '[data-scan]', el => act(() => api.admin.refreshShipment(el.dataset.scan), 'Tracking updated').then(render));
    on(main, '[data-to]', el => act(() => api.admin.setOrderStatus(id, el.dataset.to), 'Order updated').then(render));
    on(main, '[data-auth]', () => act(() => api.admin.authoriseProduction(id), 'Production authorised').then(render));
    on(main, '[data-ship]', () => api.admin.bookCourier
      ? confirmBox('Book the courier', 'This books the pickup, takes the goods out of stock and starts tracking.', 'Book courier', async () => { await api.admin.bookCourier(id); toast('Courier booked'); await render(); })
      : modal('Dispatch order', shipForm(), async v => { await api.admin.shipOrder(id, v); toast('Order dispatched'); await render(); }));
    on(main, '[data-art]', () => modal('Send new proof', html`<form class="form" novalidate>${field('note', 'Note for the retailer', { type: 'textarea', required: true })}<button class="btn btn-red" type="submit">Send proof</button></form>`, async v => { await api.admin.sendArtwork(id, v.note); await render(); }));
    on(main, '[data-balance]', async () => {
      const o = await api.admin.order(id);
      modal('Record balance', html`<form class="form" novalidate>${field('amount', 'Amount (₹)', { type: 'number', required: true, value: o.outstanding })}${field('method', 'Received by', { type: 'select', required: true, options: ['Cash on delivery', 'UPI', 'Bank transfer'] })}${field('ref', 'Reference', { required: true })}<button class="btn btn-red" type="submit">Record payment</button></form>`, async v => { await api.admin.recordBalance(id, v); toast('Payment recorded'); await render(); });
    });
    on(main, '[data-hold]', () => reasonBox('Put order on hold', 'The reason is saved on the order.', 'Put on hold', async r => { await api.admin.holdOrder(id, r); await render(); }));
    on(main, '[data-resume]', () => act(() => api.admin.resumeOrder(id), 'Order resumed').then(render));
    on(main, '[data-cancel]', () => act(() => api.admin.cancellation(id)).then(q => {
      modal('Cancel order', html`<form class="form" novalidate>
        ${field('fault', 'Why is it being cancelled?', { type: 'select', required: true, options: [['retailer', 'The retailer asked to cancel (policy charge applies)'], ['business', 'Our reason, for example stock or a mistake (no charge)']] })}
        <div class="sum"><div><span>Paid so far</span><span>${money(q.paid)}</span></div><div><span>Charge if the retailer cancels (${q.deduction_percent}%, score ${q.score})</span><span>${money(q.deduction)}</span></div><div class="tot"><span>Refund if the retailer cancels</span><span>${money(q.refund)}</span></div></div>
        <p class="small muted mb-0">For our own reasons nothing is charged, the full ${money(q.paid)} is refunded and the score is not changed.</p>
        ${field('reason', 'Reason', { type: 'textarea', required: true, rows: 2 })}
        <div class="row between"><button type="button" class="btn btn-line" data-close>Go back</button><button type="submit" class="btn btn-danger">Cancel order</button></div></form>`, async v => { await api.admin.cancelOrder(id, v.reason, v.fault); toast('Order cancelled'); await render(); });
    }).catch(() => {}));
    on(main, '[data-refused]', () => reasonBox('Parcel refused', 'The order is marked returned, the policy charge is kept from the advance and the retailer\'s score drops by 20. Add the stock back from Inventory when the parcel arrives.', 'Mark as refused', async r => { await api.admin.codRefused(id, r); toast('Marked as refused'); await render(); }));
    on(main, '[data-refund]', () => modal('Record refund paid', html`<form class="form" novalidate>${field('ref', 'Bank or UPI reference', { required: true, maxlength: 100 })}<button class="btn btn-red" type="submit">Save</button></form>`, async v => { await api.admin.markRefunded(id, v.ref); toast('Refund recorded'); await render(); }));
    await render();
  });

  /* ---------- Payments ---------- */
  page('admin-payments', { layout: 'admin', access: 'staff:payments' }, async (main, { me }) => {
    const canVerify = allowed(me, 'Owner', 'Finance');
    let list = await api.admin.payments();
    const reload = async () => { list = await api.admin.payments(); render(); };
    const render = listing(main, title('Payments', 'Check each reference against the bank statement before verifying.'), filterBar('Search reference, order or shop', ['submitted', 'verified', 'rejected']), (q, s) => {
      const r = list.filter(x => (!s || x.status === s) && [x.ref, x.orderNumber, x.company].join(' ').toLowerCase().includes(q));
      return r.length ? html`<div class="tw"><table class="t"><thead><tr><th>Reference</th><th>Order</th><th>Shop</th><th>Kind</th><th class="num">Amount</th><th>Status</th><th></th></tr></thead><tbody>${r.map(p => html`<tr><td class="mono">${p.ref}<div class="small muted">${dateTime(p.at)}</div></td><td><a class="mono small" href="admin-order.html?id=${p.orderId}">${p.orderNumber}</a></td><td>${p.company}</td><td>${p.kind === 'advance' ? 'Advance' : 'Balance'}<div class="small muted">${p.method}</div></td><td class="num">${money(p.amount)}</td><td>${badge(p.status)}</td><td class="right nowrap">${p.status === 'submitted' && canVerify ? html`<button class="btn btn-red btn-sm" data-ok="${p.id}" data-o="${p.orderId}">Verify</button> <button class="btn btn-ghost btn-sm" data-no="${p.id}" data-o="${p.orderId}">Reject</button>` : ''}</td></tr>`)}</tbody></table></div>` : '';
    }, empty('No payments found', 'Submitted references will appear here.', null, 'rupee'));
    on(main, '[data-ok]', el => confirmBox('Verify this payment?', 'Only verify after you have found this reference on the bank statement.', 'Verify payment', async () => { await api.admin.verifyPayment(el.dataset.o, el.dataset.ok, { ok: true }); toast('Payment verified'); await reload(); }));
    on(main, '[data-no]', el => reasonBox('Reject this reference', 'The retailer will see this reason.', 'Reject', async reason => { await api.admin.verifyPayment(el.dataset.o, el.dataset.no, { ok: false, reason }); toast('Reference rejected'); await reload(); }));
  });

  /* ---------- Dispatch ---------- */
  page('admin-dispatch', { layout: 'admin', access: 'staff:dispatch' }, async (main, { me }) => {
    const canAct = allowed(me, 'Owner', 'Warehouse');
    const render = async () => {
      const list = await api.admin.dispatch();
      const section = (t, rows, actionFn) => html`<div class="card"><div class="card-head"><h3>${t}</h3><span class="small muted">${rows.length}</span></div>${rows.length ? html`<div class="tw"><table class="t"><tbody>${rows.map(o => html`<tr><td><a class="mono" href="admin-order.html?id=${o.id}">${o.number}</a><div class="small muted">${o.company}, ${o.address.city}</div></td><td class="num">${pcs(o.lines)} pieces</td><td>${o.shipment ? html`<span class="mono small">${o.shipment.lr}</span>` : badge(o.status)}</td><td class="right">${canAct ? actionFn(o) : ''}</td></tr>`)}</tbody></table></div>` : html`<p class="muted card-pad mb-0">Nothing here.</p>`}</div>`;
      main.innerHTML = html`${title('Dispatch', 'Pack confirmed orders, book the courier and follow deliveries.')}<div class="stack">
        ${section('To pack', list.filter(o => o.status === 'Confirmed'), o => html`<button class="btn btn-line btn-sm" data-to="Packing" data-id="${o.id}">Start packing</button>`)}
        ${section('Packing, ready to dispatch', list.filter(o => o.status === 'Packing'), o => html`<button class="btn btn-red btn-sm" data-ship="${o.id}">Dispatch</button>`)}
        ${section('On the way', list.filter(o => o.status === 'Dispatched'), o => o.tracking ? html`<a class="btn btn-line btn-sm" href="admin-order.html?id=${o.id}">Track</a>` : html`<button class="btn btn-line btn-sm" data-to="Delivered" data-id="${o.id}">Mark delivered</button>`)}
      </div>`;
    };
    on(main, '[data-to]', el => act(() => api.admin.setOrderStatus(el.dataset.id, el.dataset.to), 'Order updated').then(render));
    on(main, '[data-ship]', el => api.admin.bookCourier
      ? confirmBox('Book the courier', 'This books the pickup, takes the goods out of stock and starts tracking.', 'Book courier', async () => { await api.admin.bookCourier(el.dataset.ship); toast('Courier booked'); await render(); })
      : modal('Dispatch order', shipForm(), async v => { await api.admin.shipOrder(el.dataset.ship, v); toast('Order dispatched'); await render(); }));
    await render();
  });

  /* ---------- Products ---------- */
  const NO_PHOTO = 'assets/img/brand/mark-navy.png';
  page('admin-products', { layout: 'admin', access: 'staff:products' }, async main => {
    const list = await api.admin.products();
    listing(main, title('Products', 'Styles shown in the catalogue.', html`<a class="btn btn-red" href="admin-product.html">Add product</a>`), filterBar('Search name or code', ['active', 'hidden']), (q, s) => {
      const r = list.filter(x => (!s || x.status === s) && [x.name, x.style].join(' ').toLowerCase().includes(q));
      return r.length ? html`<div class="tw"><table class="t"><thead><tr><th>Style</th><th>Code</th><th class="num">Colours</th><th class="num">Price</th><th class="num">Available</th><th>Status</th></tr></thead><tbody>${r.map(p => html`<tr class="click" data-href="admin-product.html?id=${p.id}"><td><div class="row" style="flex-wrap:nowrap"><img src="${p.colours[0]?.images[0] || NO_PHOTO}" alt="" width="40" height="50" style="object-fit:cover;border-radius:4px"><a href="admin-product.html?id=${p.id}"><strong>${p.name}</strong></a></div></td><td class="mono small">${p.style}</td><td class="num">${p.colours.length}</td><td class="num">${money(p.price)}</td><td class="num">${p.totalAvailable}</td><td><span class="badge ${p.status === 'active' ? 'b-ok' : 'b-mute'}">${p.status === 'active' ? 'Active' : 'Hidden'}</span></td></tr>`)}</tbody></table></div>` : '';
    }, empty('No products yet', 'Add your first product and it will appear in the catalogue.', html`<a class="btn btn-red" href="admin-product.html">Add product</a>`));
  });

  page('admin-product', { layout: 'admin', access: 'staff:products' }, async main => {
    const id = param('id');
    const cats = await api.admin.categories();
    const colourRow = c => html`<div class="row" data-colour-row style="flex-wrap:nowrap"><input class="input" aria-label="Colour name" data-colour-name value="${c.name || ''}" placeholder="For example Sky Blue" ${c.name ? raw('readonly') : ''}><input type="color" aria-label="Colour swatch" data-colour-hex value="${c.hex || '#0A1121'}" style="width:52px;height:44px;padding:2px;border:1px solid var(--line-2);border-radius:8px;background:#fff"></div>`;
    const render = async () => {
      const p = id ? await api.admin.product(id) : { status: 'active', colours: [], sizes: [] };
      main.innerHTML = html`<a class="link small" href="admin-products.html">Back to products</a>${title(id ? p.name : 'Add product', id ? p.style : 'Add the details, then upload photos for each colour.')}
      <div class="stack">
      ${param('new') ? notice('ok', 'Product added', 'Now upload photos for each colour below.') : ''}
      <div class="form-card"><form class="form" novalidate>
        <div class="form-2">${field('name', 'Style name', { required: true, value: p.name || '' })}${field('style', 'Style code', { required: true, value: p.style || '', hint: id ? 'The code cannot be changed.' : 'Letters, numbers and dashes. For example VK7-TEE-01.' })}</div>
        <div class="form-2">${field('category_id', 'Category', { type: 'select', value: p.category_id || '', options: [['', 'Select'], ...cats.map(c => [c.id, c.name])] })}${field('newCategory', 'Or add a new category', { placeholder: 'For example T-Shirts' })}</div>
        <div class="form-2">${field('price', 'Trade price (₹ per piece)', { required: true, type: 'number', value: p.price ?? '' })}${field('status', 'Status', { type: 'select', value: p.status, options: [['active', 'Active: shown in catalogue'], ['hidden', 'Hidden']] })}</div>
        <div class="field" data-field="colours"><span class="label">Colours <span class="req">*</span></span><div class="stack" id="colours" style="gap:8px">${(p.colours.length ? p.colours : [{}]).map(colourRow)}</div><div><button class="btn btn-line btn-sm" type="button" data-add-colour>Add a colour</button></div><span class="err" hidden></span></div>
        <div class="form-2">${field('sizes', 'Sizes', { required: true, value: p.sizes.join(', '), hint: 'Separate with commas. For example S, M, L, XL.' })}${id ? '' : field('stock', 'Opening stock per size and colour', { type: 'number', value: 0, hint: 'You can correct each one later in Inventory.' })}</div>
        ${field('summary', 'Short description', { value: p.summary || '' })}${field('description', 'Full description', { type: 'textarea', value: p.description || '' })}
        <div class="row"><button class="btn btn-red" type="submit">Save product</button><a class="btn btn-line" href="admin-products.html">Cancel</a></div></form></div>
      ${id ? html`<div class="card"><div class="card-head"><h3>Photos by colour</h3><span class="small muted">JPG, PNG or WebP, up to 8 MB each</span></div><div class="card-pad stack">${p.colours.map(c => html`<div><strong>${c.name}</strong><div class="row mt" style="margin-top:8px">${c.images.map(img => html`<div style="position:relative"><img src="${img.url}" alt="${c.name}" width="84" height="104" style="object-fit:cover;border-radius:4px;border:1px solid var(--line)"><button type="button" class="btn btn-danger btn-sm" style="min-height:26px;padding:2px 8px;position:absolute;top:4px;right:4px" aria-label="Remove photo" data-remove-photo="${img.id}">×</button></div>`)}<label class="btn btn-line btn-sm">Upload photos<input class="sr" type="file" accept=".jpg,.jpeg,.png,.webp" multiple data-upload="${c.name}"></label></div></div>`)}</div></div>` : ''}
      </div>`;
      if (id) { const s = main.querySelector('#f-style'); s.readOnly = true; }
      onSubmit(main.querySelector('form'), async v => {
        const colours = [...main.querySelectorAll('[data-colour-row]')].map(r => ({ name: r.querySelector('[data-colour-name]').value.trim(), hex: r.querySelector('[data-colour-hex]').value })).filter(c => c.name);
        const sizes = v.sizes.split(',').map(x => x.trim()).filter(Boolean);
        const r = await api.admin.saveProduct({ ...v, id, colours, sizes });
        if (id) { toast('Product saved'); await render(); } else location.href = 'admin-product.html?id=' + r.id + '&new=1';
      });
    };
    on(main, '[data-add-colour]', () => main.querySelector('#colours').insertAdjacentHTML('beforeend', colourRow({})));
    on(main, '[data-upload]', async el => {
      if (!el.files.length) return;
      await act(() => api.admin.uploadPhotos(id, el.dataset.upload, el.files), 'Photos uploaded');
      await render();
    }, 'change');
    on(main, '[data-remove-photo]', el => confirmBox('Remove photo', 'This photo will be removed from the website.', 'Remove', async () => { await api.admin.removePhoto(id, el.dataset.removePhoto); await render(); }, true));
    await render();
  });

  /* ---------- Inventory ---------- */
  const REASONS = ['New stock received', 'Stock count correction', 'Damaged goods', 'Return from retailer', 'Other'];
  page('admin-inventory', { layout: 'admin', access: 'staff:inventory' }, async main => {
    let tab = 'stock';
    const render = async () => {
      const [inv, log] = await Promise.all([api.admin.inventory(), api.admin.stockLog()]);
      main.innerHTML = html`${title('Inventory', 'Available = on hand minus stock held for orders. Every correction needs a reason.')}
      <div class="card mb"><div class="tabs" role="tablist"><button role="tab" aria-selected="${String(tab === 'stock')}" data-tab="stock">Stock by size and colour</button><button role="tab" aria-selected="${String(tab === 'log')}" data-tab="log">Correction log</button></div></div>
      ${tab === 'stock' ? (inv.length ? html`<div class="stack">${inv.map(p => html`<details class="card" open><summary class="card-head" style="cursor:pointer"><strong>${p.name}</strong><span class="small muted mono">${p.style}</span></summary><div class="tw"><table class="t"><thead><tr><th>Colour</th><th>Size</th><th class="num">On hand</th><th class="num">Held</th><th class="num">Available</th><th></th></tr></thead><tbody>${p.rows.map(r => html`<tr><td>${r.colour}</td><td>${r.size}</td><td class="num">${r.onHand}</td><td class="num">${r.held}</td><td class="num"><strong>${r.available}</strong>${r.available === 0 ? html` <span class="badge b-bad">Out</span>` : ''}</td><td class="right"><button class="btn btn-line btn-sm" data-adj data-v="${r.variantId}" data-n="${p.name}" data-c="${r.colour}" data-z="${r.size}">Adjust</button></td></tr>`)}</tbody></table></div></details>`)}</div>` : html`<div class="card">${empty('No products yet', 'Add a product first, then manage its stock here.', html`<a class="btn btn-red" href="admin-product.html">Add product</a>`, 'list')}</div>`)
        : html`<div class="card">${log.length ? html`<div class="tw"><table class="t"><thead><tr><th>When</th><th>Item</th><th class="num">Change</th><th class="num">New on hand</th><th>Reason</th><th>By</th></tr></thead><tbody>${log.map(l => html`<tr><td>${dateTime(l.at)}</td><td>${l.product}<div class="small muted">${l.variant}</div></td><td class="num">${l.change > 0 ? '+' : ''}${l.change}</td><td class="num">${l.after}</td><td>${l.reason}${l.note ? html`<div class="small muted">${l.note}</div>` : ''}</td><td>${l.by}</td></tr>`)}</tbody></table></div>` : empty('No corrections yet', 'Stock corrections will be listed here.', null, 'list')}</div>`}`;
    };
    on(main, '[data-tab]', el => { tab = el.dataset.tab; render(); });
    on(main, '[data-adj]', el => {
      const d = el.dataset;
      modal('Adjust stock', html`<form class="form" novalidate><p class="mb-0"><strong>${d.n}</strong><br><span class="muted">${d.c}, size ${d.z}</span></p>${field('change', 'Change in pieces', { type: 'number', required: true, hint: 'Use a minus sign to reduce. For example -5.' })}${field('reason', 'Reason', { type: 'select', required: true, options: [['', 'Select'], ...REASONS] })}${field('note', 'Note', { })}<button class="btn btn-red" type="submit">Save correction</button></form>`, async v => {
        await api.admin.adjustStock({ variantId: Number(d.v), ...v }); toast('Stock updated'); await render();
      });
    });
    await render();
  });

  /* ---------- Reports ---------- */
  page('admin-reports', { layout: 'admin', access: 'staff:reports' }, async main => {
    const r = await api.admin.reports();
    const maxM = Math.max(1, ...r.monthly.map(m => m.sales)), maxP = Math.max(1, ...r.products.map(p => p.pieces));
    const label = k => { const [y, m] = k.split('-'); return new Date(Number(y), Number(m) - 1, 1).toLocaleDateString('en-IN', { month: 'short', year: 'numeric' }); };
    const bar = (l, v, max, shown) => html`<div class="bar-row"><span>${l}</span><div class="bar-track"><i style="width:${v / max * 100}%" title="${l}: ${shown}"></i></div><span class="right">${shown}</span></div>`;
    main.innerHTML = html`${title('Business overview', 'Monthly sales, money collected and payments still pending.')}
    <div class="stack"><div class="tiles"><div class="stat"><span>Total sales</span><strong>${money(r.sales)}</strong></div><div class="stat"><span>Collected</span><strong>${money(r.collected)}</strong></div><div class="stat"><span>Pending payments</span><strong>${money(r.outstanding)}</strong></div><div class="stat"><span>Orders</span><strong>${r.orders}</strong></div></div>
      <div class="card"><div class="card-head"><h3>Monthly sales</h3></div>${r.monthly.length ? html`<div class="card-pad"><div class="bars">${r.monthly.map(m => bar(label(m.month), m.sales, maxM, money(m.sales)))}</div></div><div class="tw"><table class="t"><thead><tr><th>Month</th><th class="num">Orders</th><th class="num">Pieces</th><th class="num">Sales</th><th class="num">Collected</th><th class="num">Pending</th></tr></thead><tbody>${r.monthly.map(m => html`<tr><td>${label(m.month)}</td><td class="num">${m.orders}</td><td class="num">${m.pieces}</td><td class="num">${money(m.sales)}</td><td class="num">${money(m.collected)}</td><td class="num">${money(m.pending)}</td></tr>`)}</tbody></table></div>` : empty('No sales yet', 'Monthly figures appear after the first order.', null, 'chart')}</div>
      <div class="card"><div class="card-head"><h3>Pending payments</h3><span class="small muted">Oldest first</span></div>${r.pending.length ? html`<div class="tw"><table class="t"><thead><tr><th>Order</th><th>Client</th><th>Stage</th><th class="num">Age</th><th class="num">Paid</th><th class="num">Pending</th></tr></thead><tbody>${r.pending.map(p => html`<tr class="click" data-href="admin-order.html?id=${p.id}"><td><a class="mono small" href="admin-order.html?id=${p.id}">${p.number}</a></td><td>${p.company}</td><td>${badge(p.stage)}</td><td class="num">${p.age_days} days</td><td class="num">${money(p.paid)}</td><td class="num"><strong>${money(p.outstanding)}</strong></td></tr>`)}</tbody></table></div>` : empty('Nothing pending', 'Every order is fully paid.', null, 'check')}</div>
      <div class="two"><div class="card"><div class="card-head"><h3>Money by client</h3></div>${r.retailers.length ? html`<div class="tw"><table class="t"><thead><tr><th>Client</th><th class="num">Orders</th><th class="num">Sales</th><th class="num">Pending</th></tr></thead><tbody>${r.retailers.map(x => html`<tr><td>${x.company}</td><td class="num">${x.orders}</td><td class="num">${money(x.billed)}</td><td class="num"><strong>${money(x.outstanding)}</strong></td></tr>`)}</tbody></table></div>` : empty('No clients yet', 'Clients appear after their first order.', null, 'users')}</div>
      <div class="card card-pad"><h3 class="mb">Pieces sold by style</h3>${r.products.length ? html`<div class="bars">${r.products.map(p => bar(p.name, p.pieces, maxP, p.pieces + ' pcs'))}</div>` : html`<p class="muted mb-0">Nothing sold yet.</p>`}</div></div></div>`;
    rowLinks(main);
  });

  page('admin-notifications', { layout: 'admin', access: 'staff:notifications' }, async main => {
    const list = await api.notifications.list();
    main.innerHTML = html`${title('Notifications')}<div class="card">${list.length ? list.map(n => html`<a href="${n.link}" style="display:block;padding:12px 20px;border-bottom:1px solid var(--line);text-decoration:none"><strong style="font-weight:${n.read ? 400 : 600}">${n.title}</strong><div class="small muted">${dateTime(n.at)}</div></a>`) : empty('Nothing waiting on you', 'New activity will appear here.', null, 'bell')}</div>`;
    api.notifications.readAll();
  });

  /* ---------- Staff, settings, log ---------- */
  const ROLE_TEXT = { Administrator: 'Sees and manages everything', Sales: 'Approves clients, answers enquiries and quotes', Inventory: 'Manages products and stock', Warehouse: 'Packs, dispatches and follows deliveries', Finance: 'Verifies and records payments' };
  page('admin-staff', { layout: 'admin', access: 'staff:staff' }, async main => {
    let data;
    const form = s => html`<form class="form" novalidate><input type="hidden" name="id" value="${s.id || ''}">${field('name', 'Name', { required: true, value: s.name || '' })}${s.id ? '' : html`${field('email', 'Work email', { type: 'email', required: true })}${field('password', 'First password', { type: 'password', required: true, hint: 'At least 10 characters. Share it privately.' })}`}${field('role_id', 'Role', { type: 'select', required: true, value: s.role_id || '', options: data.roles.map(r => [r.id, r.name]) })}<button class="btn btn-red" type="submit">Save</button></form>`;
    const render = async () => {
      data = await api.admin.staff();
      main.innerHTML = html`${title('Staff and roles', 'Each role only sees its own work.', html`<button class="btn btn-red" data-add>Add staff</button>`)}
      <div class="stack"><div class="card"><div class="tw"><table class="t"><thead><tr><th>Name</th><th>Email</th><th>Role</th><th>Status</th><th></th></tr></thead><tbody>${data.staff.map(s => html`<tr><td>${s.name}</td><td>${s.email}</td><td>${s.role}</td><td>${badge(s.active ? 'Active' : 'Inactive')}</td><td class="right nowrap"><button class="btn btn-line btn-sm" data-edit="${s.id}">Edit</button> <button class="btn btn-ghost btn-sm" data-toggle="${s.id}">${s.active ? 'Deactivate' : 'Reactivate'}</button></td></tr>`)}</tbody></table></div></div>
      <div class="card"><div class="card-head"><h3>What each role does</h3></div><div class="tw"><table class="t"><tbody>${data.roles.map(r => html`<tr><td><strong>${r.name}</strong></td><td>${ROLE_TEXT[r.name] || r.description || ''}</td></tr>`)}</tbody></table></div></div></div>`;
    };
    const save = async v => { await api.admin.saveStaff(v); toast('Saved'); await render(); };
    on(main, '[data-add]', () => modal('Add staff', form({}), save));
    on(main, '[data-edit]', el => modal('Edit staff', form(data.staff.find(s => String(s.id) === el.dataset.edit)), save));
    on(main, '[data-toggle]', el => act(() => api.admin.toggleStaff(el.dataset.toggle), 'Saved').then(render));
    await render();
  });

  page('admin-settings', { layout: 'admin', access: 'staff:settings' }, async main => {
    const s = await api.admin.allSettings();
    main.innerHTML = html`${title('Settings', 'Company details and business rules, without touching any code.')}
    <div class="stack" style="max-width:760px">
    <div class="form-card"><form class="form" novalidate>
      <h3>Company details</h3><p class="hint mb-0">Shown on the website, invoices and the Contact page.</p>
      ${field('legalName', 'Registered company name', { value: s.legalName || '' })}
      ${field('address', 'Registered address', { type: 'textarea', rows: 2, value: s.address || '' })}
      <div class="form-2">${field('gstin', 'GSTIN', { value: s.gstin || '', maxlength: 15 })}${field('phone', 'Phone', { value: s.phone || '' })}</div>
      <div class="form-2">${field('email', 'Email', { type: 'email', value: s.email || '' })}${field('whatsapp', 'WhatsApp number', { value: s.whatsapp || '', hint: 'With country code, digits only.' })}</div>
      ${field('hours', 'Business hours', { value: s.hours || '' })}
      <h3>Bank and UPI details</h3><p class="hint mb-0">Shown to signed-in retailers when a payment is due.</p>
      <div class="form-2">${field('upiId', 'UPI ID', { value: s.upiId || '' })}${field('bankName', 'Bank', { value: s.bankName || '' })}</div>
      <div class="form-2">${field('accountName', 'Account name', { value: s.accountName || '' })}${field('accountNumber', 'Account number', { value: s.accountNumber || '' })}</div>
      ${field('ifsc', 'IFSC', { value: s.ifsc || '' })}
      <h3>Minimum order</h3>
      ${checkbox('moqEnabled', 'Check the minimum order on every order and quote', { checked: s.moqEnabled })}
      <div class="form-2">${field('moq', 'Minimum pieces', { type: 'number', required: true, value: s.moq, min: 1 })}${field('moqMode', 'Count it', { type: 'select', value: s.moqMode, options: [['per_style', 'Per style: sizes and colours count together'], ['per_variant', 'Per size and colour'], ['per_order', 'Across the whole order']] })}</div>
      <h3>Payments and stock</h3>
      <div class="form-2">${field('advancePct', 'Advance required (%)', { type: 'number', required: true, value: s.advancePct, min: 20, max: 100, hint: 'At least 20%, as advised by our CA.' })}${field('holdHours', 'Stock hold (hours)', { type: 'number', required: true, value: s.holdHours })}</div>
      <div class="form-2">${field('quoteValidityDays', 'Quote valid for (days)', { type: 'number', required: true, value: s.quoteValidityDays })}${field('lowStock', 'Low-stock alert (pieces)', { type: 'number', required: true, value: s.lowStock ?? 20 })}</div>
      <h3>New retailers</h3><p class="hint mb-0">Extra care on first orders, depending on the order value.</p>
      <div class="form-2">${field('newMidValue', 'Higher advance above (₹)', { type: 'number', required: true, value: s.newMidValue, min: 0 })}${field('newMidPct', 'Higher advance (%)', { type: 'number', required: true, value: s.newMidPct, min: 20, max: 100 })}</div>
      ${field('newPrepaidAbove', 'Full payment before dispatch above (₹)', { type: 'number', required: true, value: s.newPrepaidAbove, min: 0 })}
      <h3>Cash on delivery</h3><p class="hint mb-0">Offered for the balance only, and only to retailers who meet all three rules. Staff can allow or block it for one retailer on the client page.</p>
      <div class="form-2">${field('codMinScore', 'Minimum payment score', { type: 'number', required: true, value: s.codMinScore, min: 0, max: 100 })}${field('codMinOrders', 'Orders paid in full first', { type: 'number', required: true, value: s.codMinOrders, min: 0 })}</div>
      ${field('codMaxOrder', 'Largest order on cash on delivery (₹)', { type: 'number', required: true, value: s.codMaxOrder, min: 0 })}
      <h3>Cancellations and late payment</h3><p class="hint mb-0">Charge as a percent of the order value. It is halved for an Excellent score, and 1.5 or 2 times for Watch or High risk. It never exceeds what was paid.</p>
      <div class="form-2">${field('cancelConfirmedPct', 'After the advance (%)', { type: 'number', required: true, value: s.cancelConfirmedPct, min: 0, max: 50 })}${field('cancelPackingPct', 'While packing, or parcel refused (%)', { type: 'number', required: true, value: s.cancelPackingPct, min: 0, max: 50 })}</div>
      ${field('lateDays', 'Balance counts as late after (days)', { type: 'number', required: true, value: s.lateDays, min: 1, max: 90 })}
      <h3>Invoices</h3>
      ${checkbox('taxInvoiceApproved', 'Our chartered accountant has approved this invoice format as a tax invoice', { checked: s.taxInvoiceApproved })}
      <div><button class="btn btn-red" type="submit">Save settings</button></div></form></div></div>`;
    onSubmit(main.querySelector('form'), async v => { await api.admin.saveSettings(v); toast('Settings saved'); });
  });

  page('admin-invoice', { layout: 'admin', access: 'staff:orders' }, async main => {
    const id = param('id'), i = await api.admin.invoice(id);
    main.innerHTML = html`<div class="row no-print"><button class="btn btn-navy" data-print>Print or save as PDF</button><a class="btn btn-line" href="admin-order.html?id=${id}">Back to order</a></div>${invoiceDoc(i)}`;
    on(main, '[data-print]', () => window.print());
  });

  page('admin-audit', { layout: 'admin', access: 'staff:audit' }, async main => {
    const list = await api.admin.audit();
    main.innerHTML = html`${title('Activity log', 'Who changed what, and when.')}<div class="card">${list.length ? html`<div class="tw"><table class="t"><thead><tr><th>When</th><th>Who</th><th>Action</th><th>On</th><th>Details</th></tr></thead><tbody>${list.map(l => html`<tr><td class="nowrap">${dateTime(l.at)}</td><td>${l.by}</td><td>${l.action}</td><td>${l.target}</td><td>${l.detail}</td></tr>`)}</tbody></table></div>` : empty('No activity yet', 'Changes made by staff will appear here.', null, 'list')}</div>`;
  });

  /* ---------- Customer support ---------- */
  page('admin-support', { layout: 'admin', access: 'staff:support' }, async (main, { me }) => {
    const S = api.support, STATUSES = Object.values(S.statuses);
    let data = await api.admin.support();
    const keyOf = (map, label) => Object.keys(map).find(k => map[k] === label);
    const head = () => html`${title('Customer support', 'Complaints and problems sent from the website. Contact each customer within one working day.')}
      <div class="tiles mb"><div class="stat"><span>New, not yet handled</span><strong>${data.meta.open}</strong></div><div class="stat"><span>Being handled</span><strong>${data.meta.in_progress}</strong></div><div class="stat"><span>Past the contact time</span><strong style="${data.meta.overdue ? 'color:var(--bad)' : ''}">${data.meta.overdue}</strong></div></div>`;
    const draw = () => listing(main, head(), filterBar('Search ticket, name, shop or order', STATUSES), (q, s) => {
      const r = data.list.filter(x => (!s || x.status === s) && [x.number, x.name, x.organisation, x.orderNumber, x.subject, x.phone, x.email].join(' ').toLowerCase().includes(q));
      return r.length ? html`<div class="tw"><table class="t"><thead><tr><th>Ticket</th><th>From</th><th>Problem</th><th>Priority</th><th>Contact by</th><th>Status</th><th></th></tr></thead><tbody>${r.map(x => html`<tr><td class="mono small">${x.number}<div class="muted">${date(x.createdAt)}</div></td><td><strong>${x.organisation || x.name}</strong><div class="small muted">${x.organisation ? x.name : ''} ${x.phone || x.email}</div></td><td><strong>${x.subject}</strong><div class="small muted">${x.category}${x.orderNumber ? ' · ' + x.orderNumber : ''}</div></td><td>${badge(x.priority)}</td><td>${['Resolved', 'Closed'].includes(x.status) ? '-' : html`<span style="${x.overdue ? 'color:var(--bad);font-weight:600' : ''}">${dateTime(x.contactBy)}${x.overdue ? ' (late)' : ''}</span>`}</td><td>${badge(x.status)}<div class="small muted">${x.assignedTo}</div></td><td class="right"><button class="btn btn-line btn-sm" data-open="${x.id}">Open</button></td></tr>`)}</tbody></table></div>` : '';
    }, empty('No support tickets', 'Problems customers report from the Support page will appear here.', null, 'help'));
    let render = draw();
    on(main, '[data-open]', el => {
      const t = data.list.find(x => String(x.id) === el.dataset.open);
      const via = { phone: 'Phone call', whatsapp: 'WhatsApp', email: 'Email' }[t.preferred] || t.preferred;
      modal(t.number + ' · ' + t.subject, html`<div class="stack">
        <dl class="kv"><dt>From</dt><dd>${t.name}${t.organisation ? ', ' + t.organisation : ''}</dd><dt>Mobile</dt><dd>${t.phone ? html`<a class="link" href="tel:${t.phone}">${t.phone}</a>` : '-'}</dd><dt>Email</dt><dd>${t.email ? html`<a class="link" href="mailto:${t.email}">${t.email}</a>` : '-'}</dd><dt>Contact by</dt><dd>${via}, before ${dateTime(t.contactBy)}</dd><dt>About</dt><dd>${t.category}${t.orderNumber ? ' · ' + t.orderNumber : ''}</dd><dt>Raised</dt><dd>${dateTime(t.createdAt)}</dd></dl>
        <div class="sup-msg">${t.message}</div>
        ${t.notes.length ? html`<div><h4 class="mb">Internal notes</h4>${t.notes.map(n => html`<p class="small mb-0"><strong>${n.by}</strong> ${dateTime(n.at)}<br>${n.text}</p>`)}</div>` : ''}
        <form class="form" novalidate>
          <div class="form-2">${field('status', 'Status', { type: 'select', value: t.status, options: STATUSES })}${field('priority', 'Priority', { type: 'select', value: t.priority, options: Object.values(S.priorities) })}</div>
          ${field('assignedTo', 'Handled by', { value: t.assignedTo || me.name })}
          ${field('reply', 'Reply to the customer', { type: 'textarea', rows: 3, value: t.reply, hint: 'The customer sees this on the Support page and in their account.' })}
          ${field('note', 'Internal note (staff only)', { type: 'textarea', rows: 2 })}
          <button class="btn btn-red" type="submit">Save</button></form></div>`, async v => {
        await api.admin.updateTicket(t.id, { status: keyOf(S.statuses, v.status), priority: keyOf(S.priorities, v.priority), assignedTo: v.assignedTo, reply: v.reply, note: v.note });
        data = await api.admin.support(); render = draw(); toast('Ticket saved');
      });
    });
  });
})();
