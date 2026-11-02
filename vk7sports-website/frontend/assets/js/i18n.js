/* Website language. English is written in the pages themselves. For another language this file loads
   assets/lang/<code>.js and swaps each piece of text as it appears, so pages need no changes.
   To add a language: add it to LANGUAGES and create its file. Admin pages and invoices stay in English. */
(function () {
  const LANGUAGES = [['en', 'English'], ['hi', 'हिन्दी'], ['mr', 'मराठी']];
  const KEY = 'vk7-lang';
  const read = () => { try { return localStorage.getItem(KEY); } catch (e) { return null; } };
  const saved = read();
  const lang = LANGUAGES.some(l => l[0] === saved) ? saved : 'en';
  const page = document.body ? document.body.dataset.page || '' : '';
  const fixedEnglish = page.startsWith('admin') || page === 'invoice';
  window.VK7_I18N = { lang: fixedEnglish ? 'en' : lang, languages: LANGUAGES, showPicker: !fixedEnglish };

  document.addEventListener('change', e => {
    if (!e.target.matches || !e.target.matches('[data-lang]')) return;
    try { localStorage.setItem(KEY, e.target.value); } catch (err) { /* The choice lasts for this page only. */ }
    location.reload();
  });

  if (fixedEnglish || lang === 'en') return;
  document.documentElement.lang = lang;
  document.write(`<script src="assets/lang/${lang}.js"><\/script>`);
  document.addEventListener('DOMContentLoaded', start);

  function start() {
    const pack = window.VK7_LANG_PACK;
    if (!pack) return;
    const words = pack.words;
    const rules = pack.patterns.map(([from, to]) => [new RegExp(from), to]);
    const SKIP = 'script,style,textarea,code,.leaflet-control-attribution,[data-no-i18n]';

    const convert = text => {
      if (Object.prototype.hasOwnProperty.call(words, text)) return words[text];
      for (const [re, to] of rules) {
        const m = text.match(re);
        if (m) return to.replace(/\{(\d)\}/g, (_, i) => words[m[i]] || m[i]).replace(/\$(\d)/g, (_, i) => m[i]);
      }
      return null;
    };
    const textNode = n => {
      const el = n.parentElement;
      if (!el || el.closest(SKIP)) return;
      const raw = n.nodeValue, text = raw.replace(/\s+/g, ' ').trim();
      if (!text || !/[A-Za-z]/.test(text)) return;
      const out = convert(text);
      if (out === null) return;
      /* An option with no value attribute submits its text, so the English value is kept for the server. */
      if (el.tagName === 'OPTION' && !el.hasAttribute('value')) el.setAttribute('value', text);
      n.nodeValue = raw.replace(raw.trim(), out);
    };
    const attrs = el => {
      if (el.closest(SKIP)) return;
      ['placeholder', 'aria-label', 'title'].forEach(a => {
        const v = el.getAttribute(a);
        if (!v) return;
        const out = convert(v.trim());
        if (out !== null) el.setAttribute(a, out);
      });
    };
    const walk = root => {
      if (root.nodeType === 3) return textNode(root);
      if (root.nodeType !== 1) return;
      attrs(root);
      root.querySelectorAll('[placeholder],[aria-label],[title]').forEach(attrs);
      const w = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
      let n;
      while ((n = w.nextNode())) textNode(n);
    };
    walk(document.body);
    new MutationObserver(list => list.forEach(m => {
      if (m.type === 'characterData') textNode(m.target);
      else if (m.type === 'attributes') attrs(m.target);
      else m.addedNodes.forEach(walk);
    })).observe(document.body, { subtree: true, childList: true, characterData: true, attributes: true, attributeFilter: ['placeholder', 'aria-label', 'title'] });
  }
})();
