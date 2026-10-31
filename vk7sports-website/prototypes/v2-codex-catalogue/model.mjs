export const bases = {unconfirmed:'Unconfirmed — select a demo basis',basket:'Across the quotation',product:'Per product',variant:'Per size × colour variant'};
export function evaluate(lines, threshold, basis) {
 if (!Number.isSafeInteger(threshold) || threshold < 1 || threshold > 9999) throw new Error('MOQ must be a whole number from 1 to 9,999.');
 if (!(basis in bases)) throw new Error('Unknown MOQ basis.');
 const groups = new Map(); let total=0, shortage=0;
 for (const line of lines) {
  if (!Number.isSafeInteger(line.quantity) || line.quantity<0 || line.quantity>9999) throw new Error('Enter whole quantities from 0 to 9,999.');
  if (!Number.isSafeInteger(line.stock) || line.stock<0) throw new Error('Invalid demo stock.');
  if (!line.quantity) continue;
  total+=line.quantity; shortage+=Math.max(0,line.quantity-line.stock);
  const key=basis==='product'?line.productId:basis==='variant'?line.variantId:'quotation';
  groups.set(key,(groups.get(key)||0)+line.quantity);
 }
 const failures=[...groups].filter(([,qty])=>qty<threshold);
 return {total,shortage,failures,eligible:total>0 && basis!=='unconfirmed' && failures.length===0};
}
