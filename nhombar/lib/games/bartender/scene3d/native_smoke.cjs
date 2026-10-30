// Bounded ADB helper: only the existing emulator, app inspection and gestures.
const {execFileSync} = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const adb='D:/Dev/Android/Sdk/platform-tools/adb.exe';
const output=path.join(__dirname,'test-output');
fs.mkdirSync(output,{recursive:true});
const run=(...args)=>execFileSync(adb,['-s','emulator-5554',...args],{timeout:30000,maxBuffer:12*1024*1024});
const action=process.argv[2];
const numbers=()=>process.argv.slice(3).map(v=>{if(!/^\d+$/.test(v)||Number(v)>10000)throw Error('Invalid coordinate');return v;});
switch(action){
  case 'screen': {
    const name=process.argv[3]||'screen';if(!/^[a-z0-9-]+$/.test(name))throw Error('Invalid name');
    const file=path.join(output,`android-${name}.png`);
    fs.writeFileSync(file,run('exec-out','screencap','-p'));console.log(file);break;
  }
  case 'tap': {const n=numbers();if(n.length!==2)throw Error('Expected x y');run('shell','input','tap',...n);break;}
  case 'swipe': {const n=numbers();if(n.length!==5)throw Error('Expected x1 y1 x2 y2 duration');run('shell','input','swipe',...n);break;}
  case 'ui': {
    run('shell','uiautomator','dump','/sdcard/bartender-ui.xml');
    const xml=run('shell','cat','/sdcard/bartender-ui.xml').toString();
    fs.writeFileSync(path.join(output,'android-ui.xml'),xml);
    const nodes=[...xml.matchAll(/<node\b[^>]*>/g)].map(m=>Object.fromEntries([...m[0].matchAll(/([\w-]+)="([^"]*)"/g)].map(a=>[a[1],a[2]])));
    console.log(JSON.stringify(nodes.filter(n=>n.text||n['content-desc']).map(n=>({label:n.text||n['content-desc'],bounds:n.bounds,click:n.clickable==='true'})),null,2));break;
  }
  case 'metrics': {
    const memory=run('shell','dumpsys','meminfo','com.example.nhom_bar').toString();
    const gfx=run('shell','dumpsys','gfxinfo','com.example.nhom_bar').toString();
    fs.writeFileSync(path.join(output,'android-metrics.txt'),memory+'\n'+gfx);
    console.log(memory.split('\n').filter(l=>/TOTAL PSS|TOTAL RSS/.test(l)).join('\n'));
    console.log(gfx.split('\n').filter(l=>/Total frames|Janky frames|percentile/.test(l)).join('\n'));break;
  }
  default: throw Error('Supported: screen, tap, swipe, ui, metrics');
}
