// Offline WebGL interaction checks. Software rendering is not Android FPS evidence.
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {chromium}=require('playwright');
const {buildSync}=require('esbuild');
const source=buildSync({entryPoints:[path.join(__dirname,'scene.mjs')],bundle:true,minify:true,format:'iife',write:false}).outputFiles[0].text;
const output=path.join(__dirname,'test-output');fs.mkdirSync(output,{recursive:true});
const kinds=['orange','lemon','strawberry','milk','ice','sugar','orange_juice','lemon_juice'];
const fixture=(station='juicer',round=1)=>({station,stationName:station,round,busy:false,
 items:kinds.map((kind,i)=>({id:`item${i}`,kind,processable:i<2})),orders:[{id:'order1',product:'orange_juice'},{id:'order2',product:'lemon_juice'}]});
const solo=(station='juicer',round=2)=>({...fixture(station,round),items:[{id:'item0',kind:station==='cuttingBoard'?'strawberry':'orange',processable:true}]});
async function main(){
 const browser=await chromium.launch({executablePath:process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true,
 args:['--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
 const page=await browser.newPage({viewport:{width:1100,height:470}}),errors=[],requests=[];
 page.on('pageerror',e=>errors.push(String(e)));page.on('request',r=>requests.push(r.url()));
 try{
  await page.setContent('<!doctype html><html><head><meta charset="utf-8"></head><body></body></html>');
  await page.evaluate(()=>{window.events=[];window.Bartender3D={postMessage:raw=>window.events.push(JSON.parse(raw))};});
  await page.addScriptTag({content:source});await page.waitForFunction(()=>window.events.some(e=>e.type==='ready'),{timeout:30000});
  const snapshot=()=>page.evaluate(()=>window.bartenderSnapshot());
  const settle=async()=>{await page.waitForFunction(()=>window.bartenderSnapshot().spawning===0);await page.waitForTimeout(100);};
  const set=async state=>{await page.evaluate(s=>window.setBartenderState(s),state);await settle();};
  const actions=()=>page.evaluate(()=>window.events.filter(e=>e.type==='action'));
  async function drag(id,x,y){
   const item=(await snapshot()).items.find(i=>i.id===id);assert.ok(item,`missing ${id}`);
   await page.mouse.move(item.screen.x,item.screen.y);await page.mouse.down();
   await page.mouse.move(x,y,{steps:14});await page.mouse.up();await page.waitForTimeout(50);
  }
  await page.evaluate(s=>window.setBartenderState(s),fixture());
  assert.equal((await snapshot()).spawning,8);await settle();
  const initial=await snapshot();assert.equal(initial.items.length,8);assert.ok(initial.drawCalls<120);
  await set({...fixture(),busy:true,active:false,preparationId:123});
  await page.waitForFunction(()=>window.events.some(e=>e.type==='sceneReady'&&e.preparationId===123));
  const prepared=await snapshot();
  assert.equal(prepared.bufferResizes,initial.bufferResizes,'state updates must not reallocate canvas');
  assert.equal(prepared.layoutPasses,initial.layoutPasses,'busy updates must not rebuild pile');
  const beforeBlocked=(await actions()).length;
  await page.mouse.click(prepared.items[0].screen.x,prepared.items[0].screen.y);
  assert.equal((await actions()).length,beforeBlocked,'preparation blocks interaction');
  await set({...fixture(),active:true});
  const settled=await snapshot();
  await page.waitForTimeout(350);assert.equal((await snapshot()).renders,settled.renders,'settled table must not render');
  await page.evaluate(s=>window.setBartenderState(s),solo('juicer',20));
  await page.waitForTimeout(350);
  const falling=(await snapshot()).items[0];
  await page.mouse.click(falling.screen.x,falling.screen.y);
  await settle();assert.ok((await snapshot()).items[0].position[1]<1.1,'catch/release while falling must settle rather than freeze in the air');
  await set(solo());
  assert.equal((await snapshot()).stationPhase,'empty');
  await page.screenshot({path:path.join(output,'juicer-empty.png')});
  const station=(await snapshot()).station;
  await drag('item0',station.x,station.y);
  assert.equal((await snapshot()).loaded,'item0');assert.equal((await snapshot()).stationPhase,'loaded');
  assert.equal((await actions()).length,0,'loading must not process');
  await page.screenshot({path:path.join(output,'juicer-loaded.png')});
  for(let i=0;i<3;i++)await page.mouse.click(station.x,station.y);
  assert.equal((await actions()).length,0,'three presses do not finish');
  assert.equal((await snapshot()).strokes,3);
  await page.waitForTimeout(450);await page.screenshot({path:path.join(output,'juicer-pressing.png')});
  await page.mouse.click(station.x,station.y);
  assert.equal((await actions()).filter(e=>e.action==='process').length,1);
  await set({...solo(),items:[{id:'item0',kind:'orange_juice',processable:false}]});
  assert.equal((await snapshot()).stationPhase,'empty');
  const drink=(await snapshot()).items[0];await drag('item0',drink.screen.x,20);
  assert.ok((await actions()).some(e=>e.action==='submit'&&e.order==='order1'));
  await set(solo('juicer',3));await drag('item0',1095,240);
  assert.ok((await actions()).some(e=>e.action==='right'));
  await set(solo('juicer',4));await drag('item0',400,465);
  assert.ok((await actions()).some(e=>e.action==='trash'));
  await set(solo('cuttingBoard',5));const cut=(await snapshot()).station;await drag('item0',cut.x,cut.y);
  for(let i=0;i<4;i++)await page.mouse.click(cut.x,cut.y);
  const count=(await actions()).filter(e=>e.action==='process').length;assert.equal(count,1,'taps do not cut');
  for(let i=0;i<4;i++){
   await page.mouse.move(cut.x-25,cut.y);await page.mouse.down();await page.mouse.move(cut.x+35,cut.y+12,{steps:5});await page.mouse.up();
   assert.equal((await actions()).filter(e=>e.action==='process').length,i===3?2:1);
  }
  for(const station of ['juicer','cuttingBoard','blender','shaker']){
   await set(fixture(station,6));await page.screenshot({path:path.join(output,`station-${station}.png`)});
  }
  const pile={...fixture('juicer',7),items:Array.from({length:80},(_,i)=>({id:`pile${i}`,kind:kinds[i%kinds.length],processable:i%8<2}))};
  await set(pile);const dense=await snapshot();
  assert.equal(dense.items.length,80,'all inbox items must remain on the table');
  assert.equal(new Set(dense.items.map(i=>i.id)).size,80);assert.ok(dense.items.some(i=>i.id==='pile79'));
  assert.equal(await page.locator('#paging').count(),0,'no pages');
  assert.ok(Math.max(...dense.items.map(i=>i.position[1]))>1.7,'random pile must form layers');
  assert.ok(new Set(dense.items.map(i=>i.position[0].toFixed(2))).size>30,'positions must not be a grid');
  assert.ok(dense.drawCalls<230,'merged item meshes bound draw calls for a busy table');
  await page.screenshot({path:path.join(output,'pile-80.png')});
  const poses=Object.fromEntries(dense.items.map(i=>[i.id,i.position]));
  await set({...pile,busy:true});assert.deepEqual(Object.fromEntries((await snapshot()).items.map(i=>[i.id,i.position])),poses,'snapshot updates must not shuffle pile');
  assert.equal((await snapshot()).bufferResizes,dense.bufferResizes,'busy state keeps canvas buffer');
  assert.equal((await snapshot()).layoutPasses,dense.layoutPasses,'busy state keeps pile layout');
  await set({...pile,items:pile.items.filter(i=>i.id!=='pile0')});assert.equal((await snapshot()).items.length,79,'remove only the real removed item');
  await page.waitForTimeout(300);const idle=await snapshot();await page.waitForTimeout(300);assert.equal((await snapshot()).renders,idle.renders,'pile sleeps');
  await set({...pile,round:8,items:pile.items.slice(0,27)});await page.setViewportSize({width:1400,height:480});await page.waitForTimeout(150);
  await page.screenshot({path:path.join(output,'pile-playfield.png')});
  await page.locator('#quality').click();assert.ok((await snapshot()).pixelRatio<=.8);
  await page.setViewportSize({width:560,height:260});await page.waitForTimeout(150);await page.screenshot({path:path.join(output,'compact.png')});
  assert.equal(await page.locator('#hint:visible').count(),0);assert.equal(await page.locator('.tag:visible').count(),0);assert.equal(await page.locator('#serve:visible').count(),0);
  await page.evaluate(()=>window.setBartenderActive(false));const paused=await snapshot();await page.waitForTimeout(200);assert.equal((await snapshot()).renders,paused.renders);
  await page.evaluate(()=>window.setBartenderActive(true));await page.waitForTimeout(100);
  await page.evaluate(()=>window.disposeBartender());const disposed=await snapshot();assert.equal(disposed.resources,0);assert.equal(disposed.items.length,0);assert.equal(disposed.raf,0);
  assert.deepEqual(errors,[]);assert.deepEqual(requests,[]);
  fs.writeFileSync(path.join(output,'verification.json'),JSON.stringify({passed:true,initial,dense,disposed},null,2));
  console.log(JSON.stringify({passed:true,initialDrawCalls:initial.drawCalls,pileDrawCalls:dense.drawCalls,pileTriangles:dense.triangles,output}));
 }catch(e){await page.screenshot({path:path.join(output,'failure.png')});throw e;}finally{await browser.close();}
}
main().catch(e=>{console.error(e);process.exitCode=1;});
