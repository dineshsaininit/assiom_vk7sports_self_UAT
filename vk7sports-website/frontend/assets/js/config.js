/* Site settings. Anything marked null is a fact VK7SPORTS has not confirmed yet.
   Pages show a visible "To be confirmed" tag until the real value is entered here. */
window.VK7_CONFIG = {
  // Set to false, once the backend is connected, to remove the yellow demo strip and demo sign-in shortcuts.
  demoMode: true,
  // 'mock' = browser demo backend in api.js. See INTEGRATION.md for connecting Bagisto.
  apiMode: 'mock',
  apiBase: '',

  brand: { name: 'VK7SPORTS', tagline: 'Sportswear for champions' },

  contact: {
    legalName: null,
    phone: null,
    whatsapp: null, // digits with country code, for example 919800000000
    email: null,
    address: null,
    hours: null,
    gstin: null
  },

  payment: {
    upiId: null,
    bankName: null,
    accountName: null,
    accountNumber: null,
    ifsc: null
  }
};
