/* DEMO DATA ONLY. Style names, codes, prices, stock, companies and orders are fictional
   test values. Real products, prices and stock must come from VK7SPORTS.
   Photos are the supplied product images. */
window.VK7_SEED = (function () {
  const img = n => 'assets/img/products/' + n + '.jpg';
  const SIZES = ['S', 'M', 'L', 'XL', 'XXL'];
  const stock = (colours, sizes, base) => {
    const s = {};
    colours.forEach((c, ci) => sizes.forEach((z, zi) => {
      s[c.name + '|' + z] = base[(ci * 3 + zi) % base.length];
    }));
    return s;
  };

  const categories = [
    { id: 't-shirts', name: 'T-Shirts', image: img('tee-mint-front') },
    { id: 'singlets', name: 'Singlets', image: img('singlet-violet-front') },
    { id: 'jackets', name: 'Jackets', image: img('jacket-coral-front') },
    { id: 'pants', name: 'Pants', image: img('cargo-charcoal-full') },
    { id: 'long-sleeve', name: 'Long-Sleeve Tops', image: img('longsleeve-sage-back') }
  ];

  const tee = [
    { name: 'Sky Blue', hex: '#BBD9F1', code: 'SKY', images: ['tee-sky-front', 'tee-sky-back', 'tee-sky-model'] },
    { name: 'Mint Green', hex: '#BFE5BE', code: 'MNT', images: ['tee-mint-front', 'tee-mint-back', 'tee-mint-side', 'tee-mint-model', 'tee-mint-tag'] },
    { name: 'Aqua', hex: '#B6EADD', code: 'AQA', images: ['tee-aqua-front', 'tee-aqua-flat'] },
    { name: 'Lemon', hex: '#F4EDA8', code: 'LMN', images: ['tee-lemon-model', 'tee-lemon-back'] },
    { name: 'Lavender', hex: '#C5B8F0', code: 'LAV', images: ['tee-lavender-model'] },
    { name: 'Steel Blue', hex: '#5F7FA6', code: 'STL', images: ['tee-steel-action'] },
    { name: 'Black', hex: '#1F1F1F', code: 'BLK', images: ['tee-black-back'] }
  ];
  const singlet = [
    { name: 'Violet', hex: '#7A6AD8', code: 'VIO', images: ['singlet-violet-front', 'singlet-violet-back', 'singlet-violet-pair', 'singlet-violet-detail'] },
    { name: 'White', hex: '#FFFFFF', code: 'WHT', images: ['singlet-white-front', 'singlet-white-back'] }
  ];
  const jacket = [
    { name: 'Coral', hex: '#F08A6C', code: 'CRL', images: ['jacket-coral-front', 'jacket-coral-side', 'jacket-coral-full', 'jacket-coral-detail'] }
  ];
  const cargo = [
    { name: 'Charcoal', hex: '#2D3543', code: 'CHR', images: ['cargo-charcoal-full', 'cargo-charcoal-logo', 'cargo-charcoal-zip', 'cargo-charcoal-pocket'] },
    { name: 'Ash Grey', hex: '#CFD2D4', code: 'ASH', images: ['cargo-ash-logo', 'cargo-ash-waist'] }
  ];
  const longsleeve = [
    { name: 'Sage Grey', hex: '#B9C6BE', code: 'SGE', images: ['longsleeve-sage-back'] }
  ];
  const withImg = list => list.map(c => ({ ...c, images: c.images.map(img) }));

  const products = [
    {
      id: 'p-tee', slug: 'performance-crew-tee', style: 'VK7-TEE-01', name: 'Performance Crew Tee', category: 't-shirts', gender: 'Men',
      summary: 'Lightweight crew-neck training tee in a wide colour range.',
      description: 'A clean, everyday training tee with a contrast neck tape and the VK7 mark on the chest. Offered in a wide colour range so a shop can stock a full display from one style.',
      features: ['Crew neck with contrast tape', 'VK7 mark on chest, wordmark at hem', 'Regular athletic fit'],
      price: 285, isNew: true, customisable: true, status: 'active',
      colours: withImg(tee), sizes: SIZES, stock: stock(tee, SIZES, [120, 86, 64, 40, 18, 0, 72, 144, 96])
    },
    {
      id: 'p-singlet', slug: 'laser-cut-training-singlet', style: 'VK7-SNG-01', name: 'Laser-Cut Training Singlet', category: 'singlets', gender: 'Men',
      summary: 'Racer-back singlet with laser-cut ventilation down the front and back.',
      description: 'A racer-back gym and running singlet with laser-cut ventilation panels and a curved hem. Shown in Violet and White.',
      features: ['Racer back', 'Laser-cut ventilation panels', 'Curved hem'],
      price: 265, isNew: true, customisable: true, status: 'active',
      colours: withImg(singlet), sizes: SIZES, stock: stock(singlet, SIZES, [90, 60, 48, 22, 0, 75])
    },
    {
      id: 'p-jacket', slug: 'hooded-training-jacket', style: 'VK7-JKT-01', name: 'Hooded Training Jacket', category: 'jackets', gender: 'Women',
      summary: 'Light full-zip hooded jacket with side pockets.',
      description: 'A lightweight full-zip hooded jacket with an adjustable hood and two side pockets, finished with the VK7 mark and wordmark.',
      features: ['Full zip with hood', 'Two side pockets', 'VK7 mark on chest and hem'],
      price: 690, isNew: false, customisable: false, status: 'active',
      colours: withImg(jacket), sizes: ['S', 'M', 'L', 'XL'], stock: stock(jacket, ['S', 'M', 'L', 'XL'], [36, 48, 30, 14])
    },
    {
      id: 'p-cargo', slug: 'utility-cargo-pants', style: 'VK7-CRG-01', name: 'Utility Cargo Pants', category: 'pants', gender: 'Men',
      summary: 'Relaxed cargo pants with zip and flap pockets.',
      description: 'Relaxed-fit cargo pants with a textured print, side cargo pockets, a zip pocket and an elastic drawcord waist.',
      features: ['Elastic waist with drawcord', 'Side cargo pockets', 'Zip pocket'],
      price: 620, isNew: false, customisable: false, status: 'active',
      colours: withImg(cargo), sizes: ['M', 'L', 'XL', 'XXL'], stock: stock(cargo, ['M', 'L', 'XL', 'XXL'], [54, 72, 40, 12, 28, 9])
    },
    {
      id: 'p-longsleeve', slug: 'long-sleeve-training-top', style: 'VK7-LST-01', name: 'Long-Sleeve Training Top', category: 'long-sleeve', gender: 'Women',
      summary: 'Fitted long-sleeve top for training and warm-up.',
      description: 'A fitted long-sleeve top with shaped seams for training and warm-up. Only one photo is available so far.',
      features: ['Fitted cut', 'Shaped seams', 'Long sleeves'],
      price: 340, isNew: true, customisable: false, status: 'active',
      colours: withImg(longsleeve), sizes: ['S', 'M', 'L'], stock: stock(longsleeve, ['S', 'M', 'L'], [40, 52, 26])
    }
  ];

  const settings = {
    moqEnabled: true,
    moq: 24,
    moqMode: 'per_style',
    moqOnQuotes: true,
    customMoq: 100,
    advancePct: 10,
    customAdvancePct: 80,
    holdHours: 48,
    quoteValidityDays: 7,
    lowStock: 20,
    shortageNote: 'Additional stock may require 20–30 days.'
  };

  const PW = 'Demo@123';
  const retailers = [
    {
      id: 'r-alpha', status: 'approved', company: 'TEST-ALPHA Traders', contact: 'Asha Verma', email: 'alpha@example.test', password: PW, phone: '9000000001',
      shopType: 'Sports shop', gstin: '', proof: 'Shop licence (fictional)', city: 'Pune', state: 'Maharashtra', appliedAt: -60, priceList: 'Standard',
      addresses: [{ id: 'a1', label: 'Main shop', line1: '12 Test Market Road', city: 'Pune', state: 'Maharashtra', pin: '411001', phone: '9000000001', isDefault: true }],
      users: [{ id: 'u1', name: 'Asha Verma', email: 'alpha@example.test', role: 'Owner' }, { id: 'u2', name: 'Rohit Shah', email: 'rohit@example.test', role: 'Buyer' }]
    },
    {
      id: 'r-bravo', status: 'pending', company: 'TEST-BRAVO Sports', contact: 'Vikram Rao', email: 'bravo@example.test', password: PW, phone: '9000000002',
      shopType: 'Sports shop', gstin: '27ABCDE1234F1Z5', proof: 'GSTIN', city: 'Nagpur', state: 'Maharashtra', appliedAt: -1, priceList: 'Standard',
      addresses: [{ id: 'a1', label: 'Main shop', line1: '4 Sample Lane', city: 'Nagpur', state: 'Maharashtra', pin: '440001', phone: '9000000002', isDefault: true }],
      users: [{ id: 'u1', name: 'Vikram Rao', email: 'bravo@example.test', role: 'Owner' }]
    },
    {
      id: 'r-charlie', status: 'approved', company: 'TEST-CHARLIE Stores', contact: 'Meera Nair', email: 'charlie@example.test', password: PW, phone: '9000000003',
      shopType: 'Gym and fitness store', gstin: '', proof: 'Udyam certificate (fictional)', city: 'Kochi', state: 'Kerala', appliedAt: -40, priceList: 'Standard',
      addresses: [{ id: 'a1', label: 'Store', line1: '88 Demo Street', city: 'Kochi', state: 'Kerala', pin: '682001', phone: '9000000003', isDefault: true }],
      users: [{ id: 'u1', name: 'Meera Nair', email: 'charlie@example.test', role: 'Owner' }]
    }
  ];

  const staff = [
    { id: 's-owner', name: 'Demo Owner', email: 'owner@example.test', password: PW, role: 'Owner', active: true },
    { id: 's-admin', name: 'Demo Administrator', email: 'admin@example.test', password: PW, role: 'Administrator', active: true },
    { id: 's-sales', name: 'Demo Sales', email: 'sales@example.test', password: PW, role: 'Sales', active: true },
    { id: 's-inv', name: 'Demo Inventory', email: 'inventory@example.test', password: PW, role: 'Inventory', active: true },
    { id: 's-wh', name: 'Demo Warehouse', email: 'warehouse@example.test', password: PW, role: 'Warehouse', active: true },
    { id: 's-fin', name: 'Demo Finance', email: 'finance@example.test', password: PW, role: 'Finance', active: true }
  ];

  return { categories, products, settings, retailers, staff };
})();
