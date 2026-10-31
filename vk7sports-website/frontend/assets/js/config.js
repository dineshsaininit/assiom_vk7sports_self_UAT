/* Where the website finds the backend. Company and bank details are entered in the admin's
   Settings page and loaded from the server. Until then pages show a "To be confirmed" tag. */
window.VK7_CONFIG = {
  apiBase: 'http://127.0.0.1:8000/api/v1',
  brand: { name: 'VK7SPORTS', tagline: 'Sportswear for champions' },
  contact: { legalName: null, phone: null, whatsapp: null, email: null, address: null, hours: null, gstin: null },
  payment: { upiId: null, bankName: null, accountName: null, accountNumber: null, ifsc: null }
};
