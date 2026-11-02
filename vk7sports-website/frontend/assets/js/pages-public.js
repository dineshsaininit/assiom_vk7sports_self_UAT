/* Public pages, sign-in and registration, catalogue, product page, track, policies. */
(function () {
  const { trackingPanel, mountMap, api, html, raw, money, param, icon, badge, tbc, notice, empty, pageHead, productCard, priceBlock, gridMarkup, bindGrid, field, checkbox, onSubmit, toast, on, act, page, cardSkeleton, dateTime, timeline, tracker, crumbs } = VK7;
  const CFG = window.VK7_CONFIG, C = CFG.contact;
  const contactValue = (v, label) => v ? v : tbc(label || 'To be confirmed');

  /* ---------- Home ---------- */
  page('home', { layout: 'public' }, async (main, { me }) => {
    const [cats, products, S] = await Promise.all([api.catalog.categories(), api.catalog.list({ sort: 'new' }), api.settings()]);
    const primary = !me ? html`<a class="btn btn-red" href="register.html">Apply for a trade account</a>` : html`<a class="btn btn-red" href="catalogue.html">Start an order</a>`;
    main.innerHTML = html`
    <section class="hero"><div class="wrap hero-in">
      <div class="hero-copy"><span class="eyebrow">Wholesale sportswear</span>
        <h1>Stock your shop with <em>VK7</em> sportswear.</h1>
        <p>Browse the range, choose sizes and colours on one simple order form, and follow every order from advance to delivery.</p>
        <div class="row">${primary}<a class="btn btn-outline-white" href="catalogue.html">View catalogue</a></div>
      </div>
      <div class="hero-img"><img src="assets/img/products/tee-steel-action.jpg" alt="Athlete running on a track in a VK7 Performance Crew Tee" fetchpriority="high"></div>
    </div></section>
    <section class="facts" aria-label="Key points"><div class="wrap facts-in">
      <div class="fact">${icon('box', 22)}<div><strong>${S.moq} pieces per style</strong><span>Mix sizes and colours</span></div></div>
      <div class="fact">${icon('shield', 22)}<div><strong>Approved retailers</strong><span>Trade prices after approval</span></div></div>
      <div class="fact">${icon('file', 22)}<div><strong>Quotes for larger orders</strong><span>Reply within one working day</span></div></div>
      <div class="fact">${icon('truck', 22)}<div><strong>Track every order</strong><span>From advance to delivery</span></div></div>
    </div></section>
    ${products.length ? html`<section class="sec"><div class="wrap">
      <div class="sec-head"><div><h2>Shop by category</h2></div><a class="link" href="catalogue.html">View all products</a></div>
      <div class="cat-grid">${cats.map(c => html`<a class="cat" href="catalogue.html?category=${c.id}"><img src="${c.image}" alt="" loading="lazy"><span>${c.name}</span></a>`)}</div>
    </div></section>
    <section class="sec sec-alt"><div class="wrap">
      <div class="sec-head"><div><h2>In the range now</h2><p>Trade prices appear once your account is approved.</p></div></div>
      <div class="pgrid">${products.slice(0, 4).map(p => productCard(p, me))}</div>
    </div></section>` : ''}
    <section class="sec"><div class="wrap">
      <div class="sec-head"><div><h2>How ordering works</h2><p>Four steps from sign-up to delivery.</p></div><a class="link" href="how-it-works.html">See the full process</a></div>
      <div class="steps">
        <div class="step"><h3>Register your shop</h3><p>Send your shop details. Our team reviews them and approves your account.</p></div>
        <div class="step"><h3>Choose styles</h3><p>See your trade price and enter quantities by size and colour.</p></div>
        <div class="step"><h3>Order or ask for a quote</h3><p>Place the order, or request a quote for a better rate on larger quantities.</p></div>
        <div class="step"><h3>Pay and track</h3><p>Pay the advance, then follow dispatch and delivery from your account.</p></div>
      </div>
    </div></section>
    <section class="sec sec-alt"><div class="wrap">
      <div class="sec-head"><div><h2>Two ways to order</h2></div></div>
      <div class="two">
        <div class="tile"><h3>Regular orders</h3><p>Ready styles from the catalogue.</p>
          <ul class="ticks"><li>Minimum ${S.moq} pieces per style</li><li>Mix sizes and colours</li><li>Faster dispatch</li><li>${S.advancePct}% advance, balance on delivery</li></ul>
          <a class="btn btn-navy" href="catalogue.html">Browse catalogue</a></div>
        <div class="tile"><h3>Customised orders</h3><p>Your logo, text, names or numbers on our styles.</p>
          <ul class="ticks"><li>Minimum about ${S.customMoq} pieces per design</li><li>You approve the artwork before production</li><li>Advance before production, balance before dispatch</li></ul>
          <a class="btn btn-line" href="custom-orders.html">Send a customised enquiry</a></div>
      </div>
    </div></section>
    <section class="sec"><div class="wrap">
      <div class="sec-head"><div><h2>Who we work with</h2></div></div>
      <div class="three">
        <div class="tile"><h3>Retailers and shopkeepers</h3><p>Place bulk orders, see trade prices and reorder easily.</p><a class="link" href="register.html">Apply for an account</a></div>
        <div class="tile"><h3>Schools, clubs and teams</h3><p>Team uniforms and large orders, handled by our sales team.</p><a class="link" href="enquiry.html">Send an enquiry</a></div>
        <div class="tile"><h3>New dealers</h3><p>Tell us about your business and we will get back to you.</p><a class="link" href="enquiry.html">Talk to sales</a></div>
      </div>
      <div class="cta mt-l"><div><h2>Ready to order?</h2><p>Apply for a trade account and see your prices once approved.</p></div>${primary}</div>
    </div></section>`;
  });

  /* ---------- Catalogue ---------- */
  page('catalogue', { layout: 'public' }, async (main, { me }) => {
    const [cats, facets] = await Promise.all([api.catalog.categories(), api.catalog.facets()]);
    const canSeePrice = me && (me.approved || me.kind === 'staff');
    const state = { q: param('q') || '', category: param('category') ? [param('category')] : [], gender: [], colour: [], size: [], inStock: false, customisable: false, sort: 'new' };
    const group = (title, key, items) => html`<div class="filter-group"><h4>${title}</h4>${items.map(i => html`<label class="check"><input type="checkbox" data-f="${key}" value="${i[0]}" ${state[key].includes(i[0]) ? raw('checked') : ''}>${i[2] ? html`<span class="swatch" style="background:${i[2]}"></span>` : ''}<span>${i[1]}</span></label>`)}</div>`;
    main.innerHTML = html`
      ${pageHead('Catalogue', canSeePrice ? 'Your trade prices are shown on every style.' : 'Browse the range. Trade prices are shown to approved retailers.', [['Home', 'index.html'], ['Catalogue']])}
      <div class="wrap"><div class="cat-layout">
        <aside class="filters" id="filters" aria-label="Filters">
          ${group('Category', 'category', cats.map(c => [c.id, c.name]))}
          ${facets.genders.length ? group('For', 'gender', facets.genders.map(g => [g, g])) : ''}
          ${group('Colour', 'colour', facets.colours.map(c => [c.name, c.name, c.hex]))}
          ${group('Size', 'size', facets.sizes.map(s => [s, s]))}
          <div class="filter-group"><h4>Other</h4>
            <label class="check"><input type="checkbox" data-t="inStock"><span>In stock only</span></label>
            <label class="check"><input type="checkbox" data-t="customisable"><span>Can be customised</span></label></div>
          <button class="btn btn-line btn-block btn-sm" type="button" data-clear>Clear all filters</button>
        </aside>
        <div>
          <div class="toolbar">
            <span id="count" class="muted" role="status"></span>
            <div class="row">
              <button class="btn btn-line btn-sm filter-btn" type="button" data-toggle-filters aria-controls="filters">Filters</button>
              <label class="sr" for="sort">Sort by</label>
              <select id="sort" class="input" style="width:auto;min-height:38px;padding:6px 10px">
                <option value="new">Newest first</option><option value="name">Name A to Z</option><option value="stock">Most stock</option>
                ${canSeePrice ? html`<option value="price-asc">Price low to high</option><option value="price-desc">Price high to low</option>` : ''}
              </select></div></div>
          <div class="chips" id="chips"></div>
          <div id="grid"></div>
        </div>
      </div></div>`;
    const grid = main.querySelector('#grid'), countEl = main.querySelector('#count'), chips = main.querySelector('#chips');
    let token = 0;
    const load = async () => {
      const mine = ++token;
      grid.innerHTML = cardSkeleton(3);
      try {
        const list = await api.catalog.list(state);
        if (mine !== token) return;
        countEl.textContent = list.length + (list.length === 1 ? ' style' : ' styles');
        const active = [...state.category.map(v => ['category', v, cats.find(c => c.id === v)?.name || v]), ...state.gender.map(v => ['gender', v, v]), ...state.colour.map(v => ['colour', v, v]), ...state.size.map(v => ['size', v, 'Size ' + v])];
        if (state.q) active.unshift(['q', state.q, 'Search: ' + state.q]);
        chips.innerHTML = html`${active.map(a => html`<button class="chip" data-chip="${a[0]}" data-v="${a[1]}" aria-label="Remove ${a[2]}">${a[2]} <span aria-hidden="true">&times;</span></button>`)}`;
        grid.innerHTML = list.length ? html`<div class="pgrid pgrid-3">${list.map(p => productCard(p, me))}</div>`
          : empty('No styles match', 'Try removing a filter, or send us an enquiry and we will help.', html`<div class="row" style="justify-content:center"><button class="btn btn-navy" data-clear>Clear all filters</button><a class="btn btn-line" href="enquiry.html">Send an enquiry</a></div>`, 'search');
      } catch (e) {
        grid.innerHTML = empty('Could not load products', e.message, html`<button class="btn btn-navy" data-reload>Try again</button>`, 'alert');
      }
    };
    on(main, '[data-f]', el => {
      const k = el.dataset.f;
      state[k] = el.checked ? [...state[k], el.value] : state[k].filter(v => v !== el.value);
      load();
    }, 'change');
    on(main, '[data-t]', el => { state[el.dataset.t] = el.checked; load(); }, 'change');
    on(main, '#sort', el => { state.sort = el.value; load(); }, 'change');
    on(main, '[data-reload]', load);
    on(main, '[data-toggle-filters]', () => main.querySelector('#filters').classList.toggle('open'));
    on(main, '[data-chip]', el => {
      const k = el.dataset.chip, v = el.dataset.v;
      if (k === 'q') { state.q = ''; const s = document.getElementById('site-q'); if (s) s.value = ''; }
      else { state[k] = state[k].filter(x => x !== v); const c = main.querySelector(`[data-f="${k}"][value="${CSS.escape(v)}"]`); if (c) c.checked = false; }
      load();
    });
    on(main, '[data-clear]', () => {
      Object.assign(state, { q: '', category: [], gender: [], colour: [], size: [], inStock: false, customisable: false });
      main.querySelectorAll('.filters input').forEach(i => { i.checked = false; });
      const s = document.getElementById('site-q'); if (s) s.value = '';
      load();
    });
    await load();
  });

  /* ---------- Product ---------- */
  page('product', { layout: 'public' }, async (main, { me }) => {
    const slug = param('p');
    if (!slug) return VK7.redirect('catalogue.html');
    const [p, S] = await Promise.all([api.catalog.get(slug), api.settings()]);
    document.title = p.name + ' | VK7SPORTS';
    const canOrder = me && me.kind === 'retailer' && me.approved;
    const cat = (await api.catalog.categories()).find(c => c.id === p.category);
    let existing = {};
    if (canOrder) { const cart = await api.cart.get(); cart.lines.filter(l => l.productId === p.id).forEach(l => { existing[l.colour + '|' + l.size] = l.qty; }); }
    const pick = param('colour');
    const startColour = p.colours.find(c => c.name === pick) || p.colours[0];
    const moqLabel = S.moqMode === 'per_style' ? `${S.moq} pieces per style. Sizes and colours can be mixed.` : S.moqMode === 'per_variant' ? `${S.moq} pieces for each size and colour.` : `${S.moq} pieces across the whole order.`;

    const orderPanel = canOrder ? html`
      <div class="row between mb"><h2 style="font-size:18px">Enter your quantities</h2>${priceBlock(p, me)}</div>
      ${gridMarkup(p, existing)}
      <div class="mx-foot">
        <div class="row between"><strong id="pcs">0 pieces</strong><span id="val" class="muted"></span></div>
        <div class="meter" id="meter"><i style="width:0"></i></div>
        <div id="moqmsg" class="small" role="status"></div>
        <div id="shortmsg" class="mt" hidden>${notice('warn', 'More than we have in stock', html`Some quantities are above current stock. ${S.shortageNote} You can reduce the quantity, or request a quote and our team will advise.`)}</div>
        <div class="row mt"><button class="btn btn-red grow" id="add" type="button">Add to order list</button><a class="btn btn-line" href="cart.html">View order list</a></div>
      </div>`
      : me && me.kind === 'retailer' ? notice('info', 'Your account is awaiting approval', html`You can browse the range now. Prices and ordering open once our team approves your shop. <a class="link" href="account.html">View status</a>`)
      : me && me.kind === 'staff' ? notice('info', 'Signed in as staff', 'Ordering is available to retailer accounts.')
      : html`<div class="card card-pad"><h3>Want to order this style?</h3><p class="muted">Trade prices and ordering are available to approved retailers.</p><div class="row"><a class="btn btn-red" href="login.html?next=${encodeURIComponent('product.html?p=' + p.slug)}">Sign in</a><a class="btn btn-line" href="register.html">Apply for an account</a></div></div>`;

    main.innerHTML = html`<div class="wrap">
      <div style="padding-top:18px">${crumbs([['Home', 'index.html'], ['Catalogue', 'catalogue.html'], [cat ? cat.name : 'Products', 'catalogue.html?category=' + p.category], [p.name]])}</div>
      <div class="pdp">
        <div>
          <div class="gallery-main"><img id="hero" src="${startColour.images[0]}" alt="${p.name} in ${startColour.name}"></div>
          <div class="thumbs" id="thumbs"></div>
        </div>
        <div class="stack">
          <div><span class="small muted mono">${p.style}</span><h1>${p.name}</h1><p class="muted mb-0">${p.summary}</p></div>
          <div><span class="label">Colours</span> <span class="muted small" id="colourName">${startColour.name}</span>
            <div class="swatches mt" style="margin-top:6px">${p.colours.map(c => html`<button class="swatch" style="background:${c.hex};width:30px;height:30px;padding:0;${c.name === startColour.name ? 'box-shadow:0 0 0 2px #fff,0 0 0 4px var(--navy);' : ''}" title="${c.name}" aria-label="Show ${c.name}" data-swatch="${c.name}" type="button"></button>`)}</div></div>
          <div class="notice n-info"><div><strong>Minimum order</strong>${moqLabel}</div></div>
          ${orderPanel}
          <div class="card card-pad"><h3 class="mb" style="margin-bottom:8px">Details</h3><p class="muted">${p.description}</p>
            <dl class="spec">
              <dt>Category</dt><dd>${cat ? cat.name : ''}</dd><dt>Sizes</dt><dd>${p.sizes.join(', ')}</dd>
              
              <dt>Customisation</dt><dd>${p.customisable ? html`Available. <a class="link" href="custom-orders.html?style=${p.id}">Send a customised enquiry</a>` : 'Not offered on this style'}</dd>
            </dl></div>
        </div>
      </div>
      <section class="sec" style="padding-bottom:0"><h2 class="mb">More styles</h2><div class="pgrid">${p.related.map(x => productCard(x, me))}</div></section>
    </div>`;

    const hero = main.querySelector('#hero'), thumbs = main.querySelector('#thumbs');
    const showColour = c => {
      thumbs.innerHTML = html`${c.images.map((src, i) => html`<button class="thumb" type="button" data-src="${src}" aria-label="Photo ${i + 1} of ${c.name}" aria-current="${String(i === 0)}"><img src="${src}" alt=""></button>`)}`;
      hero.src = c.images[0]; hero.alt = p.name + ' in ' + c.name;
      main.querySelector('#colourName').textContent = c.name;
      main.querySelectorAll('[data-swatch]').forEach(b => { b.style.boxShadow = b.dataset.swatch === c.name ? '0 0 0 2px #fff,0 0 0 4px var(--navy)' : ''; });
    };
    showColour(startColour);
    on(main, '[data-swatch]', el => showColour(p.colours.find(c => c.name === el.dataset.swatch)));
    on(main, '[data-src]', el => { hero.src = el.dataset.src; thumbs.querySelectorAll('.thumb').forEach(t => t.setAttribute('aria-current', t === el)); });

    if (canOrder) {
      let lines = [];
      bindGrid(main, l => {
        lines = l;
        const total = l.reduce((s, x) => s + x.qty, 0), over = l.some(x => x.qty > x.available);
        main.querySelector('#pcs').textContent = total + (total === 1 ? ' piece' : ' pieces');
        main.querySelector('#val').textContent = total ? money(total * p.price) + ' before GST' : '';
        const need = Math.max(0, S.moq - total), meter = main.querySelector('#meter');
        meter.querySelector('i').style.width = Math.min(100, total / S.moq * 100) + '%';
        meter.classList.toggle('done', need === 0);
        main.querySelector('#moqmsg').textContent = !total ? `Enter at least ${S.moq} pieces for this style.` : need ? `Add ${need} more to reach the minimum of ${S.moq}.` : 'Minimum order met.';
        main.querySelector('#shortmsg').hidden = !over;
      });
      main.querySelector('#add').onclick = async e => {
        const b = e.currentTarget; b.disabled = true;
        try {
          const v = await api.cart.setStyle(p.id, lines);
          toast('Order list updated');
          const c = document.querySelector('.tool .count');
          if (c) c.textContent = v.pieces; else if (v.pieces) location.reload();
        } catch (err) { toast(err.message, true); }
        b.disabled = false;
      };
    }
  });

  /* ---------- Marketing and information ---------- */
  page('about', { layout: 'public' }, async main => {
    main.innerHTML = html`${pageHead('About VK7SPORTS', 'Sportswear for champions, supplied to shops through a simple wholesale process.', [['Home', 'index.html'], ['About']])}
    <section class="sec"><div class="wrap"><div class="two" style="align-items:center">
      <div class="prose"><h2 style="margin-top:0;font-size:24px">A wholesale partner for sports retailers</h2>
        <p>VK7SPORTS supplies sportswear in bulk to shopkeepers and retailers, who sell it on to their own customers. Orders are placed in bulk, so retailers get trade pricing and a range they can display with confidence.</p>
        <p>This website brings the whole order into one place: your prices, your size and colour mix, your payments and your deliveries.</p>
        <a class="btn btn-red" href="register.html">Apply for a trade account</a></div>
      <img src="assets/img/products/singlet-violet-pair.jpg" alt="VK7 Laser-Cut Training Singlet, front and back" style="border-radius:8px;border:1px solid var(--line)">
    </div></div></section>
    <section class="sec sec-alt"><div class="wrap"><div class="three">
      <div class="tile"><h3>Clear trade pricing</h3><p>Approved retailers see their own price, and larger orders can be quoted.</p></div>
      <div class="tile"><h3>One order, one record</h3><p>Your order, payments and dispatch details stay together in your account.</p></div>
      <div class="tile"><h3>People behind the system</h3><p>Our team reviews accounts, quotes and payments, and you can always talk to sales.</p></div>
    </div></div></section>`;
  });

  page('how', { layout: 'public' }, async main => {
    const S = await api.settings();
    const step = (t, d) => html`<div class="step"><h3>${t}</h3><p>${d}</p></div>`;
    main.innerHTML = html`${pageHead('How it works', 'From registering your shop to reordering your best sellers.', [['Home', 'index.html'], ['How it works']])}
    <section class="sec"><div class="wrap"><div class="steps">
      ${step('Register and get approved', 'Send your shop details and proof of business. Our team reviews every application.')}
      ${step('Browse and check prices', 'See the full range with your trade price and live stock for each size and colour.')}
      ${step('Build your order', `Enter quantities by size and colour. The minimum is ${S.moq} pieces per style.`)}
      ${step('Pay the advance', `Pay ${S.advancePct}% by UPI or bank transfer and send us the reference within ${S.holdHours} hours. Your stock is held for you.`)}
      ${step('We verify and confirm', 'Our finance team checks the payment, then your order is confirmed.')}
      ${step('Packing and dispatch', 'We pack your order and share the courier or LR number.')}
      ${step('Receive your goods', 'Pay the balance as agreed and check your goods on delivery.')}
      ${step('Reorder easily', 'Repeat any past order in one click from your account.')}
    </div></div></section>
    <section class="sec sec-alt"><div class="wrap"><div class="sec-head"><div><h2>Terms at a glance</h2><p>These are the current planned terms and may change once VK7SPORTS confirms them.</p></div></div>
      <div class="card"><div class="tw"><table class="t"><thead><tr><th>Term</th><th>Regular order</th><th>Customised order</th></tr></thead><tbody>
        <tr><td>Minimum quantity</td><td>${S.moq} pieces per style</td><td>About ${S.customMoq} pieces per design</td></tr>
        <tr><td>Advance</td><td>${S.advancePct}% to confirm</td><td>About ${S.customAdvancePct}% after artwork approval</td></tr>
        <tr><td>Balance</td><td>On delivery</td><td>Before dispatch</td></tr>
        <tr><td>Stock</td><td>Held ${S.holdHours} hours for your advance</td><td>Made to order</td></tr>
        <tr><td>Quotes</td><td colspan="2">Valid ${S.quoteValidityDays} days. An accepted quote locks the price.</td></tr>
      </tbody></table></div></div>
      <div class="row mt-l"><a class="btn btn-red" href="register.html">Apply for a trade account</a><a class="btn btn-line" href="faq.html">Read the FAQs</a></div>
    </div></section>`;
  });

  const FAQS = S => [
    ['Who can order from VK7SPORTS?', 'Approved retailers and shopkeepers. Schools, clubs and teams can send an enquiry and our sales team will help.'],
    ['Why can I not see prices?', 'Trade prices are shown only to approved retailers. Apply for an account and they will appear once you are approved.'],
    ['What is the minimum order?', `${S.moq} pieces per style. You can mix sizes and colours within a style. Customised orders start at about ${S.customMoq} pieces per design.`],
    ['How do I pay?', `Regular orders need a ${S.advancePct}% advance by UPI or bank transfer. Enter your payment reference on the order page and our team will verify it against the bank statement.`],
    ['What if I do not pay the advance in time?', `Stock is held for ${S.holdHours} hours. After that the order expires and the stock is released.`],
    ['What happens if a size is out of stock?', 'You can reduce the quantity, or request a quote and our team will advise on availability.'],
    ['Can I get a better price on a large order?', `Yes. Request a quote from your order list. Quotes are valid for ${S.quoteValidityDays} days and an accepted quote locks the price.`],
    ['How do I track my order?', 'Sign in to your account, or use the Track an order page with your order number and mobile number.']
  ];
  page('faq', { layout: 'public' }, async main => {
    const S = await api.settings();
    main.innerHTML = html`${pageHead('Frequently asked questions', null, [['Home', 'index.html'], ['FAQs']])}
    <section class="sec"><div class="wrap"><div class="prose" style="max-width:800px">
      ${FAQS(S).map(f => html`<details class="card card-pad" style="margin-bottom:10px"><summary style="font-weight:600;cursor:pointer">${f[0]}</summary><p class="mt mb-0">${f[1]}</p></details>`)}
      <p class="mt-l">Still have a question? <a class="link" href="contact.html">Contact us</a></p>
    </div></div></section>`;
  });

  page('contact', { layout: 'public' }, async main => {
    main.innerHTML = html`${pageHead('Contact us', 'Questions about an order or your account? We are happy to help.', [['Home', 'index.html'], ['Contact']])}
    <section class="sec"><div class="wrap"><div class="split">
      <div class="form-card" id="box"><h2 class="mb" style="font-size:20px">Send us a message</h2>
        <form class="form" novalidate>
          <div class="form-2">${field('name', 'Your name', { required: true, autocomplete: 'name' })}${field('phone', 'Mobile number', { required: true, type: 'tel', autocomplete: 'tel', inputmode: 'numeric', maxlength: 10 })}</div>
          <div class="form-2">${field('email', 'Email', { type: 'email', autocomplete: 'email' })}${field('organisation', 'Shop or organisation')}</div>
          ${field('message', 'How can we help?', { type: 'textarea', required: true })}
          <button class="btn btn-red" type="submit">Send message</button>
        </form></div>
      <div class="card card-pad"><h3 class="mb">Reach us directly</h3>
        <dl class="kv" style="grid-template-columns:90px 1fr">
          <dt>Phone</dt><dd>${contactValue(C.phone)}</dd><dt>WhatsApp</dt><dd>${C.whatsapp ? html`<a class="link" href="https://wa.me/${C.whatsapp}">Chat with sales</a>` : tbc()}</dd>
          <dt>Email</dt><dd>${C.email ? html`<a class="link" href="mailto:${C.email}">${C.email}</a>` : tbc()}</dd><dt>Address</dt><dd>${contactValue(C.address)}</dd><dt>Hours</dt><dd>${contactValue(C.hours)}</dd>
        </dl></div>
    </div></div></section>`;
    onSubmit(main.querySelector('form'), async v => {
      const r = await api.enquiries.contact(v);
      main.querySelector('#box').innerHTML = html`${notice('ok', 'Message sent', html`Your reference is <span class="mono">${r.number}</span>. Our team will reply soon.`)}`;
    });
  });

  const ORG = ['School or college', 'Club or team', 'Academy or gym', 'Dealer or distributor', 'Company or event', 'Other'];
  const QTY = ['100 to 250 pieces', '250 to 500 pieces', '500 to 1,000 pieces', 'More than 1,000 pieces'];
  const enquiryDone = (el, r, what) => {
    el.innerHTML = html`<div class="center" style="padding:20px 0"><div class="state-ico" style="background:var(--ok-bg);color:var(--ok)">${icon('check', 24)}</div><h2>Thank you</h2><p class="muted">We have received your ${what}.</p><p class="mono" style="font-size:18px;font-weight:700">${r.number}</p><p class="muted">Please keep this reference. Our sales team will contact you within one working day.</p><a class="btn btn-navy" href="catalogue.html">Browse the catalogue</a></div>`;
  };
  page('enquiry', { layout: 'public' }, async main => {
    main.innerHTML = html`${pageHead('Bulk enquiry', 'For schools, clubs, teams and new dealers. Tell us what you need and our sales team will call you.', [['Home', 'index.html'], ['Bulk enquiry']])}
    <section class="sec"><div class="wrap"><div class="split">
      <div class="form-card" id="box"><form class="form" novalidate>
        <div class="form-2">${field('name', 'Contact person', { required: true, autocomplete: 'name' })}${field('phone', 'Mobile number', { required: true, type: 'tel', inputmode: 'numeric', maxlength: 10 })}</div>
        <div class="form-2">${field('organisation', 'Organisation name', { required: true })}${field('orgType', 'Organisation type', { type: 'select', required: true, options: [['', 'Select'], ...ORG] })}</div>
        <div class="form-2">${field('city', 'City', { required: true })}${field('email', 'Email', { type: 'email' })}</div>
        <div class="form-2">${field('quantity', 'Approximate quantity', { type: 'select', required: true, options: [['', 'Select'], ...QTY] })}${field('requiredBy', 'Needed by', { type: 'date' })}</div>
        ${field('message', 'What do you need?', { type: 'textarea', required: true, placeholder: 'For example: sports day T-shirts in two colours' })}
        <button class="btn btn-red" type="submit">Send enquiry</button>
      </form></div>
      <div class="card card-pad"><h3 class="mb">What happens next</h3><ul class="ticks"><li>Our sales team reviews your enquiry</li><li>We call you within one working day</li><li>You receive a quotation for your quantity</li></ul><p class="muted small mb-0">Shop owners should <a class="link" href="register.html">apply for a trade account</a> instead, to order online.</p></div>
    </div></div></section>`;
    onSubmit(main.querySelector('form'), async v => enquiryDone(main.querySelector('#box'), await api.enquiries.create({ ...v, type: 'bulk' }), 'enquiry'));
  });

  page('custom', { layout: 'public' }, async main => {
    const [S, list] = await Promise.all([api.settings(), api.catalog.list({ customisable: true })]);
    main.innerHTML = html`${pageHead('Customised orders', 'Your logo, text, names or numbers on VK7 styles. Send your idea and our team will prepare a quote.', [['Home', 'index.html'], ['Customised orders']])}
    <section class="sec"><div class="wrap">
      <div class="steps mb" style="margin-bottom:32px">
        <div class="step"><h3>Enquiry and quote</h3><p>Tell us the style, quantity and design. We send a quote.</p></div>
        <div class="step"><h3>Approve the artwork</h3><p>You check a proof and approve it, or ask for changes.</p></div>
        <div class="step"><h3>Advance and production</h3><p>After your advance is verified, production starts.</p></div>
        <div class="step"><h3>Balance and dispatch</h3><p>Pay the balance and we dispatch your order.</p></div>
      </div>
      <div class="split">
        <div class="form-card" id="box"><h2 class="mb" style="font-size:20px">Send a customised enquiry</h2><form class="form" novalidate>
          <div class="form-2">${field('name', 'Contact person', { required: true })}${field('phone', 'Mobile number', { required: true, type: 'tel', inputmode: 'numeric', maxlength: 10 })}</div>
          <div class="form-2">${field('organisation', 'Team or organisation', { required: true })}${field('orgType', 'Type', { type: 'select', required: true, options: [['', 'Select'], ...ORG] })}</div>
          <div class="form-2">${field('city', 'City', { required: true })}${field('email', 'Email', { type: 'email' })}</div>
          <div class="form-2">${field('styleId', 'Base style', { type: 'select', value: param('style') || '', options: [['', 'Not sure yet'], ...list.map(p => [p.id, p.name])] })}${field('quantity', 'Approximate quantity', { type: 'select', required: true, options: [['', 'Select'], ...QTY] })}</div>
          ${field('message', 'Describe your design', { type: 'textarea', required: true, placeholder: 'Logo position, colours, names and numbers' })}
          <p class="hint mb-0">Keep your logo file ready, ideally PDF, AI, CDR or a high-quality PNG. We will ask for it after we contact you.</p>
          ${checkbox('rightsOk', 'I confirm that I own, or have permission to use, the logos and artwork I am sharing.')}
          <button class="btn btn-red" type="submit">Send enquiry</button>
        </form></div>
        <div class="card card-pad"><h3 class="mb">Good to know</h3><ul class="ticks"><li>Minimum about ${S.customMoq} pieces per design</li><li>About ${S.customAdvancePct}% advance after artwork approval</li><li>Balance before dispatch</li><li>Production starts only after artwork and advance are both done</li></ul><img src="assets/img/products/tee-mint-tag.jpg" alt="VK7 logo and tags on a Performance Crew Tee" style="border-radius:8px" loading="lazy"></div>
      </div></div></section>`;
    onSubmit(main.querySelector('form'), async v => {
      enquiryDone(main.querySelector('#box'), await api.enquiries.create({ ...v, type: 'custom' }), 'customised order enquiry');
    });
  });

  const POLICIES = {
    terms: ['Terms of sale', [['Who can buy', 'Goods are sold only to approved trade customers for resale.'], ['Minimum order', 'Each order must meet the minimum order quantity shown on the website.'], ['Prices', 'Prices shown are trade prices and exclude GST unless stated. An accepted quote locks the price for that order.'], ['Payment', 'An advance is required to confirm an order. The order is confirmed only after the payment is verified.'], ['Stock', 'Stock is held for a limited time while the advance is awaited. If the advance is not received in time, the order expires.'], ['Cancellation', 'An order can be cancelled online until the advance is verified. After that, please contact sales.']]],
    shipping: ['Shipping policy', [['Dispatch', 'Orders are packed after confirmation and sent by courier or transporter. You will receive the courier or LR number on your order page.'], ['Delivery charges', 'Delivery charges and partners will be listed here once confirmed.'], ['Delivery time', 'Delivery time depends on your location and the transporter.']]],
    returns: ['Returns and replacements', [['Checking your goods', 'Please check your goods when they arrive and tell us about any damage or shortage as soon as you can.'], ['Replacements', 'Replacement rules will be listed here once confirmed.'], ['Customised orders', 'Customised goods are made to your approved artwork, so please check the proof carefully before approving it.']]],
    privacy: ['Privacy policy', [['What we collect', 'Your shop details, contact details, order history and the payment references you submit.'], ['How we use it', 'To review your application, process your orders and contact you about them.'], ['Sharing', 'We share details with delivery partners only as needed to deliver your order.'], ['Your choices', 'Contact us to correct your details or to ask about your information.']]]
  };
  page('policy', { layout: 'public' }, async main => {
    const key = param('doc');
    const d = POLICIES[key];
    if (!d) return VK7.redirect('policy.html?doc=terms');
    document.title = d[0] + ' | VK7SPORTS';
    main.innerHTML = html`${pageHead(d[0], null, [['Home', 'index.html'], [d[0]]])}
    <section class="sec"><div class="wrap"><div class="split">
      <div class="prose">${notice('warn', 'Draft', 'This text is a draft and has not yet been approved by VK7SPORTS or its legal adviser.')}${d[1].map(s => html`<h2>${s[0]}</h2><p>${s[1]}</p>`)}</div>
      <nav class="card card-pad" aria-label="Policies"><h3 class="mb">Policies</h3><div class="stack" style="gap:8px">${Object.keys(POLICIES).map(k => html`<a class="link" href="policy.html?doc=${k}">${POLICIES[k][0]}</a>`)}</div></nav>
    </div></div></section>`;
  });

  page('track', { layout: 'public' }, async main => {
    main.innerHTML = html`${pageHead('Track an order', 'Enter your order number and the mobile number on the order.', [['Home', 'index.html'], ['Track an order']])}
    <section class="sec"><div class="wrap"><div class="split">
      <div class="stack"><div class="form-card"><form class="form" novalidate>
        <div class="form-2">${field('number', 'Order number', { required: true, value: param('number') || '', placeholder: 'VK7-ORD-2026-00101' })}${field('phone', 'Mobile number', { required: true, type: 'tel', inputmode: 'numeric', maxlength: 10 })}</div>
        <button class="btn btn-red" type="submit">Track order</button></form></div>
      <div id="out"></div></div>
      <div class="card card-pad"><h3 class="mb">Have an account?</h3><p class="muted">Sign in to see all your orders, payments and documents.</p><a class="btn btn-line" href="account-orders.html">Go to my orders</a></div>
    </div></div></section>`;
    onSubmit(main.querySelector('form'), async v => {
      const o = await api.orders.track(v);
      main.querySelector('#out').innerHTML = html`<div class="card"><div class="card-head"><h3 class="mono">${o.number}</h3>${badge(o.status)}</div><div class="card-pad stack">
        ${tracker(o)}
        ${o.tracking ? trackingPanel(o.tracking) : o.shipment ? html`<dl class="kv"><dt>Courier</dt><dd>${o.shipment.courier}</dd><dt>LR number</dt><dd class="mono">${o.shipment.lr}</dd></dl>` : ''}
        <div><h4 class="mb">History</h4>${timeline(o.history)}</div></div></div>`;
      if (o.tracking) mountMap(main, o.tracking);
    });
  });

  /* ---------- Auth ---------- */
  const safeNext = v => (v && /^[a-z0-9-]+\.html(\?[^/]*)?$/i.test(v)) ? v : null;

  page('login', { layout: 'public' }, async (main, { me }) => {
    if (me) return VK7.redirect(me.kind === 'staff' ? 'admin.html' : 'account.html');
    main.innerHTML = html`<div class="auth"><div class="auth-card"><h1 style="font-size:24px">Sign in</h1><p class="muted">Welcome back. Sign in to see trade prices and your orders.</p>
      <form class="form" novalidate>
        ${field('email', 'Email', { type: 'email', required: true, autocomplete: 'username' })}
        ${field('password', 'Password', { type: 'password', required: true, autocomplete: 'current-password' })}
        <div class="row between"><span></span><a class="link small" href="forgot-password.html">Forgot password?</a></div>
        <button class="btn btn-red btn-block" type="submit">Sign in</button>
      </form>
      <p class="center mt-l mb-0">New to VK7SPORTS? <a class="link" href="register.html">Apply for a trade account</a></p></div></div>`;
    const form = main.querySelector('form');
    onSubmit(form, async v => {
      await api.auth.login(v);
      location.href = safeNext(param('next')) || 'account.html';
    });
  });

  page('register', { layout: 'public' }, async (main, { me }) => {
    if (me) return VK7.redirect(me.kind === 'staff' ? 'admin.html' : 'account.html');
    main.innerHTML = html`<div class="auth"><div class="auth-card wide"><h1 style="font-size:24px">Apply for a trade account</h1><p class="muted">For retailers and shopkeepers. Our team reviews every application, usually within one working day.</p>
      <form class="form" novalidate>
        <h3>Your shop</h3>
        <div class="form-2">${field('company', 'Shop or business name', { required: true, autocomplete: 'organization' })}${field('shopType', 'Type of business', { type: 'select', required: true, options: [['', 'Select'], 'Sports shop', 'Clothing store', 'Gym and fitness store', 'Distributor', 'Other'] })}</div>
        ${field('address', 'Shop address', { required: true, autocomplete: 'street-address' })}
        <div class="form-2">${field('city', 'City', { required: true })}${field('state', 'State', { type: 'select', required: true, options: [['', 'Select state'], ...window.VK7_STATES] })}</div>
        <div class="form-2">${field('pin', 'PIN code', { required: true, inputmode: 'numeric', maxlength: 6 })}<span></span></div>
        <h3>Proof of business</h3>
        <div class="form-2">${field('gstin', 'GSTIN', { maxlength: 15, hint: 'Enter your GSTIN if you have one.' })}${field('proof', 'Or another proof', { hint: 'For example: shop licence or Udyam certificate.' })}</div>
        <h3>Your login</h3>
        <div class="form-2">${field('contact', 'Your name', { required: true, autocomplete: 'name' })}${field('phone', 'Mobile number', { required: true, type: 'tel', inputmode: 'numeric', maxlength: 10 })}</div>
        ${field('email', 'Email', { type: 'email', required: true, autocomplete: 'email' })}
        <div class="form-2">${field('password', 'Password', { type: 'password', required: true, autocomplete: 'new-password', hint: 'At least 8 characters.' })}${field('confirm', 'Confirm password', { type: 'password', required: true, autocomplete: 'new-password' })}</div>
        ${checkbox('agree', html`I agree to the <a class="link" href="policy.html?doc=terms" target="_blank">terms of sale</a> and <a class="link" href="policy.html?doc=privacy" target="_blank">privacy policy</a>.`)}
        <button class="btn btn-red" type="submit">Submit application</button>
      </form><p class="mt-l mb-0">Already have an account? <a class="link" href="login.html">Sign in</a></p></div></div>`;
    onSubmit(main.querySelector('form'), async v => {
      const r = await api.auth.register(v);
      if (r && r.pending) {
        main.innerHTML = html`<div class="auth"><div class="auth-card center"><h1 style="font-size:24px">Application received</h1><p class="muted">Thank you. We will review your shop and email you once it is approved. You can sign in after that.</p><a class="btn btn-navy" href="catalogue.html">Browse catalogue</a></div></div>`;
        return;
      }
      location.href = 'account.html?welcome=1';
    });
  });

  page('forgot', { layout: 'public' }, async main => {
    main.innerHTML = html`<div class="auth"><div class="auth-card" id="box"><h1 style="font-size:24px">Reset your password</h1><p class="muted">Enter your email and we will send you a reset link.</p>
      <form class="form" novalidate>${field('email', 'Email', { type: 'email', required: true })}<button class="btn btn-red btn-block" type="submit">Send reset link</button></form>
      <p class="center mt-l mb-0"><a class="link" href="login.html">Back to sign in</a></p></div></div>`;
    onSubmit(main.querySelector('form'), async v => {
      await api.auth.forgot(v);
      main.querySelector('#box').innerHTML = html`${notice('ok', 'Check your email', 'If an account exists for that email, a reset link is on its way.')}<p class="center mt-l mb-0"><a class="link" href="login.html">Back to sign in</a></p>`;
    });
  });

  page('admin-login', { layout: 'bare' }, async (main, { me }) => {
    if (me && me.kind === 'staff') return VK7.redirect('admin.html');
    main.innerHTML = html`<div class="auth" style="min-height:100vh;background:var(--navy)"><div class="auth-card">
      <img src="assets/img/brand/logo-navy.png" alt="VK7SPORTS" style="height:34px;margin-bottom:18px">
      <h1 style="font-size:22px">Staff sign-in</h1><p class="muted">For VK7SPORTS staff only.</p>
      <form class="form" novalidate>${field('email', 'Work email', { type: 'email', required: true, autocomplete: 'username' })}${field('password', 'Password', { type: 'password', required: true, autocomplete: 'current-password' })}<button class="btn btn-navy btn-block" type="submit">Sign in</button></form>
      <p class="center mt-l mb-0"><a class="link" href="index.html">Back to website</a></p></div></div>`;
    const form = main.querySelector('form');
    onSubmit(form, async v => { await api.auth.staffLogin(v); location.href = 'admin.html'; });
  });

  page('not-found', { layout: 'public' }, async main => {
    main.innerHTML = html`<div class="err404"><b>404</b><h1>Page not found</h1><p class="muted">The page you are looking for has moved or does not exist.</p><div class="row" style="justify-content:center"><a class="btn btn-red" href="index.html">Go to home</a><a class="btn btn-line" href="catalogue.html">View catalogue</a></div></div>`;
  });
})();
