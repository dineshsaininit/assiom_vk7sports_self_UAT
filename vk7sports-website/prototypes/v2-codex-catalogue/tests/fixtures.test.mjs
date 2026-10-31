import test from 'node:test';
import assert from 'node:assert/strict';
import {products,variants} from '../data.mjs';
import {evaluate} from '../model.mjs';
import {garment} from '../art.mjs';
test('fictional catalogue has unique valid stock variants and no prices',()=>{
 const ids=new Set();for(const p of products){assert.equal('price' in p,false);assert.ok(garment(p).includes('<svg'));assert.equal(p.stock.length,p.colors.length*p.sizes.length);for(const v of variants(p)){assert.ok(!ids.has(v.variantId));ids.add(v.variantId);assert.ok(Number.isInteger(v.stock)&&v.stock>=0);}}
});
test('real demo fixture supports 24-piece request with exact shortage',()=>{
 const v=variants(products[0]);const r=evaluate([{...v[0],quantity:12},{...v[1],quantity:12}],24,'basket');assert.equal(r.total,24);assert.equal(r.shortage,4);assert.equal(r.eligible,true);
});
test('all three simulation bases honor a configured threshold',()=>{
 const v=variants(products[0])[0];for(const basis of ['basket','product','variant']){assert.equal(evaluate([{...v,quantity:30}],30,basis).eligible,true);assert.equal(evaluate([{...v,quantity:29}],30,basis).eligible,false);}
});
