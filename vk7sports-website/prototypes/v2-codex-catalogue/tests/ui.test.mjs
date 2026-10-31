// Executes the actual app handlers against a minimal DOM double; not a browser.
import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {readFileSync} from 'node:fs';
import {products,variants} from '../data.mjs';
import {evaluate,bases} from '../model.mjs';
import {garment} from '../art.mjs';
function setup(){
 const elements=new Map(),timers=[];
 const get=id=>{if(!elements.has(id))elements.set(id,{value:'',checked:false,disabled:false,innerHTML:'',textContent:'',className:'',focus(){this.focused=true;},scrollIntoView(){},showModal(){this.open=true;},close(){this.open=false;},addEventListener(){},setAttribute(){},removeAttribute(){},querySelectorAll(){return [];}});return elements.get(id);};
 get('threshold').value='24';get('basis').value='basket';get('category').value='all';get('quantityForm').elements={namedItem:name=>get(name)};
 const context=vm.createContext({products,variants,evaluate,bases,garment,document:{getElementById:get,addEventListener(){}},setTimeout:fn=>{timers.push(fn);return timers.length;},clearTimeout(){},console});
 vm.runInContext(readFileSync(new URL('../app.mjs',import.meta.url),'utf8').replace(/^import .*;\n/gm,''),context);
 return {get,timers,run:code=>vm.runInContext(code,context)};
}
test('search and category filter compose, unmatched search is empty',()=>{const h=setup();h.run("catalogueState='ready'");h.get('search').value=' JACKET ';h.run('renderCatalogue()');assert.match(h.get('cards').innerHTML,/Court warm-up/);h.get('category').value='Training';h.run('renderCatalogue()');assert.match(h.get('catalogueStatus').innerHTML,/No products found/);});
test('mixed quantities save, edit and exact shortage summary',()=>{const h=setup();h.run("openProduct('velocity')");h.get('velocity-0-0').value='12';h.get('velocity-0-1').value='12';h.run('saveMatrix({preventDefault(){}})');assert.equal(h.get('count').textContent,24);h.run('openSummary()');assert.match(h.get('quoteContent').innerHTML,/4 pieces exceed/);assert.equal(h.get('submitDemo').disabled,true);});
test('23, 24 and 25 pieces update review eligibility',()=>{const h=setup();for(const qty of [23,24,25]){h.run(`draft.set('velocity-0-0',${qty});renderDraft()`);assert.equal(h.get('review').disabled,qty<24);}});
test('browser bad number input is rejected rather than treated as zero',()=>{const h=setup();h.run("openProduct('velocity')");h.get('velocity-0-0').value='';h.get('velocity-0-0').validity={badInput:true};assert.equal(h.run('validateMatrix()'),false);});
test('loading callback cannot overwrite a later explicit error state',()=>{const h=setup();h.run("catalogueState='error';renderCatalogue()");h.timers[0]();assert.match(h.get('catalogueStatus').innerHTML,/could not load/);});
test('loading, ready, explicit empty and error retry render distinct states',()=>{const h=setup();assert.match(h.get('catalogueStatus').innerHTML,/Loading/);h.timers[0]();assert.match(h.get('cards').innerHTML,/Velocity/);h.run("catalogueState='empty';renderCatalogue()");assert.match(h.get('catalogueStatus').innerHTML,/No products/);h.run("catalogueState='error';renderCatalogue()");h.get('retryCatalogue').onclick();assert.match(h.get('catalogueStatus').innerHTML,/Loading/);h.timers.at(-1)();assert.match(h.get('cards').innerHTML,/Velocity/);});
test('zeroing saved quantities clears draft; invalid threshold disables review',()=>{const h=setup();h.run("draft.set('velocity-0-0',24);renderDraft()");h.get('threshold').value='1.5';h.run('renderDraft()');assert.equal(h.get('review').disabled,true);assert.match(h.get('eligibility').innerHTML,/whole number/);h.run("openProduct('velocity');saveMatrix({preventDefault(){}})");assert.equal(h.get('count').textContent,0);assert.match(h.get('draft').innerHTML,/Your collection starts here/);});
test('mixed sizes and colours contribute to basket MOQ; unconfirmed blocks review',()=>{const h=setup();h.run("openProduct('velocity')");for(const id of ['velocity-0-0','velocity-0-1','velocity-1-0','velocity-1-1'])h.get(id).value='6';h.run('saveMatrix({preventDefault(){}})');assert.equal(h.get('count').textContent,24);assert.equal(h.get('review').disabled,false);h.get('basis').value='unconfirmed';h.run('renderDraft()');assert.equal(h.get('review').disabled,true);});
test('failed quotation can retry inside its modal and success stays disabled',async()=>{const h=setup();h.run("draft.set('velocity-0-0',24);openSummary()");h.get('shortageAck').checked=true;h.get('failRequest').checked=true;const pending=h.run('submitDemo()');h.timers.at(-1)();await pending;assert.match(h.get('submissionStatus').innerHTML,/retryWithoutFailure/);h.get('failRequest').checked=false;const retry=h.run('submitDemo()');h.timers.at(-1)();await retry;assert.match(h.get('submissionStatus').innerHTML,/Nothing was sent/);h.get('shortageAck').onchange();assert.equal(h.get('submitDemo').disabled,true);});
