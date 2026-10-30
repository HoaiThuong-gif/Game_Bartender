// Actual WebGL/pointer/lifecycle checks in headless Chrome, not an FPS benchmark
// for Android. Playwright is a development dependency of the frontend.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');
const { buildSync } = require('esbuild');
const source = buildSync({entryPoints:[path.join(__dirname,'scene.mjs')],
  bundle:true, minify:true, format:'iife', write:false}).outputFiles[0].text;
const output = path.join(__dirname, 'test-output');
fs.mkdirSync(output,{recursive:true});
const fixture = (station='juicer', round=1) => ({station,stationName:{juicer:'Máy ép trái cây',blender:'Máy xay sinh tố',cuttingBoard:'Thớt & Dao',shaker:'Bình lắc Cocktail'}[station],round,busy:false,
  items:['orange','lemon','strawberry','milk','ice','sugar','orange_juice','lemon_juice'].map((kind,i)=>({id:`item${i}`,kind,processable:i<2})),
  orders:[{id:'order1',product:'orange_juice'},{id:'order2',product:'lemon_juice'}]});
async function main(){
  const browser=await chromium.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true,
    args:['--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
  const page=await browser.newPage({viewport:{width:920,height:470}});
  const errors=[],requests=[];page.on('pageerror',e=>errors.push(String(e)));page.on('request',r=>requests.push(r.url()));
  try {
    await page.setContent('<!doctype html><html><head><meta charset="utf-8"></head><body></body></html>');
    await page.evaluate(()=>{window.events=[];window.Bartender3D={postMessage:raw=>window.events.push(JSON.parse(raw))};});
    await page.addScriptTag({content:source});
    await page.waitForFunction(()=>window.events.some(e=>e.type==='ready'),{timeout:30000});
    await page.evaluate(state=>window.setBartenderState(state),fixture());
    assert.equal(await page.evaluate(()=>window.bartenderSnapshot().spawning),8);
    await page.waitForFunction(()=>window.bartenderSnapshot().spawning===0);
    await page.waitForTimeout(100);
    const snapshot=()=>page.evaluate(()=>window.bartenderSnapshot());
    const initial=await snapshot();assert.equal(initial.items.length,8);assert.ok(initial.triangles<50000);assert.ok(initial.drawCalls<140);
    await page.waitForTimeout(300);assert.equal((await snapshot()).renders,initial.renders,'idle must not render');
    const target=initial.items[0].screen;
    await page.mouse.move(target.x,target.y);await page.mouse.down();
    for(let i=1;i<=10;i++){await page.mouse.move(target.x+i*4,target.y+i*2);await page.waitForTimeout(18);}
    const dragging=await snapshot();assert.equal(dragging.dragging,true);assert.ok(dragging.renders>initial.renders);assert.notDeepEqual(dragging.items[0].position,initial.items[0].position);
    await page.mouse.move(initial.station.x,initial.station.y,{steps:8});await page.mouse.up();await page.waitForTimeout(80);
    assert.equal((await snapshot()).loaded,'item0');
    const processCount=()=>page.evaluate(()=>window.events.filter(e=>e.type==='action'&&e.action==='process').length);
    assert.equal(await processCount(),0,'dropping only loads the machine');
    for(let i=0;i<3;i++) await page.mouse.click(initial.station.x,initial.station.y);
    assert.equal(await processCount(),0,'three presses must not finish');
    await page.mouse.click(initial.station.x,initial.station.y);
    assert.equal(await processCount(),1,'four presses finish one processing action');
    await page.evaluate(state=>{state.items[0].kind='orange_juice';state.items[0].processable=false;window.setBartenderState(state);},fixture());
    await page.waitForTimeout(80);
    async function throwItem(id,x,y){
      const item=(await snapshot()).items.find(i=>i.id===id);
      await page.mouse.move(item.screen.x,item.screen.y);await page.mouse.down();
      await page.mouse.move(x,y,{steps:12});await page.mouse.up();
    }
    const product=(await snapshot()).items.find(i=>i.id==='item0');
    await throwItem('item0',product.screen.x,30);
    assert.ok(await page.evaluate(()=>window.events.some(e=>e.type==='action'&&e.action==='submit'&&e.order==='order1')));
    await page.evaluate(state=>window.setBartenderState(state),fixture());
    await throwItem('item1',915,270);
    assert.ok(await page.evaluate(()=>window.events.some(e=>e.type==='action'&&e.action==='right'&&e.id==='item1')));
    await page.evaluate(state=>window.setBartenderState(state),fixture());
    await throwItem('item4',460,460);
    assert.ok(await page.evaluate(()=>window.events.some(e=>e.type==='action'&&e.action==='trash'&&e.id==='item4')));
    await page.evaluate(state=>{state.items=[{id:'berry',kind:'strawberry',processable:true}];window.setBartenderState(state);},fixture('cuttingBoard',3));
    await page.waitForFunction(()=>window.bartenderSnapshot().spawning===0);
    const cut=await snapshot();await throwItem('berry',cut.station.x,cut.station.y);
    for(let i=0;i<4;i++)await page.mouse.click(cut.station.x,cut.station.y);
    assert.equal(await processCount(),1,'taps must not cut');
    for(let i=0;i<4;i++){
      await page.mouse.move(cut.station.x-25,cut.station.y);await page.mouse.down();
      await page.mouse.move(cut.station.x+35,cut.station.y+15,{steps:5});await page.mouse.up();
      assert.equal(await processCount(),i===3?2:1,'four separate cuts required');
    }
    assert.equal(await page.locator('.tag:visible').count(),0,'ingredient names must be hidden');
    assert.equal(await page.locator('#serve:visible').count(),0,'no submit button');
    for(const station of ['cuttingBoard','blender','shaker','juicer']){await page.evaluate(state=>window.setBartenderState(state),fixture(station,2));await page.waitForFunction(()=>window.bartenderSnapshot().spawning===0);await page.waitForTimeout(50);await page.screenshot({path:path.join(output,`station-${station}.png`)});}
    await page.setViewportSize({width:1400,height:480});
    await page.waitForTimeout(80);
    await page.screenshot({path:path.join(output,'wide-closeup.png')});
    await page.evaluate(state=>{state.items[7]={id:'falling',kind:'orange',processable:true};window.setBartenderState(state);},fixture('juicer',2));
    assert.equal((await snapshot()).spawning,1,'only the new item should fall');
    const airborne=(await snapshot()).items.find(i=>i.id==='falling').position[1];
    await page.waitForTimeout(250);
    assert.ok((await snapshot()).items.find(i=>i.id==='falling').position[1]<airborne,'fruit falls toward table');
    await page.waitForFunction(()=>window.bartenderSnapshot().spawning===0);
    await page.setViewportSize({width:920,height:470});
    await page.evaluate(state=>{state.items=Array.from({length:27},(_,i)=>({id:`many${i}`,kind:'orange',processable:true}));window.setBartenderState(state);},fixture());
    assert.equal((await snapshot()).items.length,8);await page.locator('#next').click();assert.equal((await snapshot()).items[0].id,'many8');await page.locator('#next').click();assert.equal((await snapshot()).items.length,8);await page.locator('#next').click();assert.equal((await snapshot()).items.length,3);
    await page.locator('#quality').click();assert.ok((await snapshot()).pixelRatio<=.8);
    await page.setViewportSize({width:560,height:260});await page.evaluate(state=>window.setBartenderState(state),fixture());await page.waitForTimeout(120);await page.screenshot({path:path.join(output,'compact.png')});
    await page.waitForFunction(()=>window.bartenderSnapshot().spawning===0);
    assert.equal(await page.locator('#hint:visible').count(),0);
    await page.evaluate(()=>window.setBartenderActive(false));const paused=await snapshot();await page.waitForTimeout(200);assert.equal((await snapshot()).renders,paused.renders);assert.equal(paused.raf,0);
    await page.evaluate(()=>window.setBartenderActive(true));await page.waitForTimeout(100);
    await page.evaluate(()=>window.disposeBartender());await page.waitForTimeout(100);const disposed=await snapshot();assert.equal(disposed.disposed,true);assert.equal(disposed.raf,0);assert.equal(disposed.items.length,0);assert.equal(disposed.resources,0);
    assert.deepEqual(errors,[]);assert.deepEqual(requests,[],'scene must make no external asset/CDN requests');
    const report={passed:true,initial,dragging,disposed,errors,requests};fs.writeFileSync(path.join(output,'verification.json'),JSON.stringify(report,null,2));
    console.log(JSON.stringify({passed:true,triangles:initial.triangles,drawCalls:initial.drawCalls,output}));
  } catch(error) {
    await page.screenshot({path:path.join(output,'failure.png')});
    throw error;
  } finally {await browser.close();}
}
main().catch(e=>{console.error(e);process.exitCode=1;});
