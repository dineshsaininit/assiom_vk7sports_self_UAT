/* Where the website finds the backend. Company and bank details are entered in the admin's
   Settings page and loaded from the server. Until then pages show a "To be confirmed" tag. */
window.VK7_CONFIG = {
  apiBase: 'http://127.0.0.1:8000/api/v1',
  brand: { name: 'VK7SPORTS', tagline: 'Sportswear for champions' },
  contact: { legalName: null, phone: null, whatsapp: null, email: null, address: null, hours: null, gstin: null },
  payment: { upiId: null, bankName: null, accountName: null, accountNumber: null, ifsc: null }
};
window.VK7_STATES = [['AN', 'Andaman and Nicobar Islands'], ['AP', 'Andhra Pradesh'], ['AR', 'Arunachal Pradesh'], ['AS', 'Assam'], ['BR', 'Bihar'], ['CH', 'Chandigarh'], ['CT', 'Chhattisgarh'], ['DN', 'Dadra and Nagar Haveli'], ['DD', 'Daman and Diu'], ['DL', 'Delhi'], ['GA', 'Goa'], ['GJ', 'Gujarat'], ['HR', 'Haryana'], ['HP', 'Himachal Pradesh'], ['JK', 'Jammu and Kashmir'], ['JH', 'Jharkhand'], ['KA', 'Karnataka'], ['KL', 'Kerala'], ['LD', 'Lakshadweep'], ['MP', 'Madhya Pradesh'], ['MH', 'Maharashtra'], ['MN', 'Manipur'], ['ML', 'Meghalaya'], ['MZ', 'Mizoram'], ['NL', 'Nagaland'], ['OR', 'Odisha'], ['PY', 'Puducherry'], ['PB', 'Punjab'], ['RJ', 'Rajasthan'], ['SK', 'Sikkim'], ['TN', 'Tamil Nadu'], ['TG', 'Telangana'], ['TR', 'Tripura'], ['UP', 'Uttar Pradesh'], ['UT', 'Uttarakhand'], ['WB', 'West Bengal']];
