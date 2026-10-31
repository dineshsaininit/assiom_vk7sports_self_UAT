import test from 'node:test';
import assert from 'node:assert/strict';
import { evaluate } from '../model.mjs';
const lines = [{productId:'a',variantId:'a-n-m',quantity:12,stock:8},{productId:'a',variantId:'a-n-l',quantity:12,stock:20}];
test('24 pieces meets basket MOQ and reports exact shortage',()=>{
 const r=evaluate(lines,24,'basket'); assert.equal(r.eligible,true); assert.equal(r.total,24); assert.equal(r.shortage,4);
});
test('23 pieces fails threshold',()=>assert.equal(evaluate([{...lines[0],quantity:23}],24,'basket').eligible,false));
test('unconfirmed basis never silently selects a policy',()=>assert.equal(evaluate(lines,24,'unconfirmed').eligible,false));
test('product and variant bases produce different outcomes',()=>{ assert.equal(evaluate(lines,24,'product').eligible,true); assert.equal(evaluate(lines,24,'variant').eligible,false); });
test('every selected product must meet product basis',()=>assert.equal(evaluate([...lines,{productId:'b',variantId:'b-m',quantity:1,stock:0}],24,'product').eligible,false));
test('empty requests cannot qualify',()=>assert.equal(evaluate([],24,'basket').eligible,false));
test('invalid quantities and thresholds are rejected',()=>{for(const q of [-1,1.5,NaN,10000]) assert.throws(()=>evaluate([{...lines[0],quantity:q}],24,'basket')); for(const t of [0,1.5,NaN]) assert.throws(()=>evaluate(lines,t,'basket'));});
test('zero entries do not create extra MOQ groups',()=>assert.equal(evaluate([...lines,{productId:'b',variantId:'b',quantity:0,stock:0}],24,'product').eligible,true));
