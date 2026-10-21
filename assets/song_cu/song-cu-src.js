import * as THREE from 'three';
import { Programs } from './programs.js';
import { SongCuAudio } from './audio.js';

let state=null, controls=[0,0,0,0], disposed=false, paused=false, raf=0, dirty=true;
let gesture=null, lastFrame=0, animate=false, serial=0, pending=null, sendTimer=0, tapAt=-1000;
const bridge=(type,extra={})=>window.SongCuGame?.postMessage(JSON.stringify({type,epoch:state?.epoch,...extra}));
const listeners=[],geometries=new Set(),materials=new Set(),textures=new Set(),picks=[];
const sounds=new SongCuAudio(),programs=new Programs();
window.loadSongCuSeasons=data=>{if(!disposed&&typeof data==='string'&&data.startsWith('data:image/png;base64,'))programs.seasons.src=data;};
const ray=new THREE.Raycaster(),pointer=new THREE.Vector2();
function listen(target,type,handler,options){
  target.addEventListener(type,handler,options);listeners.push(()=>target.removeEventListener(type,handler,options));
}
function fail(){if(!disposed){window.pauseSongCu?.();bridge('error');}}
listen(window,'error',fail);listen(window,'unhandledrejection',fail);

const scene=new THREE.Scene();scene.background=new THREE.Color('#ece2d1');
const camera=new THREE.PerspectiveCamera(36,1,.1,60);
let renderer;
try {renderer=new THREE.WebGLRenderer({antialias:false,powerPreference:'low-power'});}
catch(_){bridge('error');throw new Error('WebGL unavailable');}
renderer.setPixelRatio(Math.min(devicePixelRatio||1,1.5));renderer.outputColorSpace=THREE.SRGBColorSpace;
const canvas=renderer.domElement;document.body.appendChild(canvas);
scene.add(new THREE.HemisphereLight('#fff1d1','#454c42',2.1));
const light=new THREE.DirectionalLight('#fff2dd',3.1);light.position.set(-3,6,5);scene.add(light);
const fill=new THREE.DirectionalLight('#c2d4c8',.7);fill.position.set(4,2,-3);scene.add(fill);
const root=new THREE.Group();scene.add(root);

function mat(color,roughness=.8,metalness=.1){
  const m=new THREE.MeshStandardMaterial({color,roughness,metalness});materials.add(m);return m;
}
function mesh(parent,geo,material,x=0,y=0,z=0){
  geometries.add(geo);materials.add(material);const m=new THREE.Mesh(geo,material);
  m.position.set(x,y,z);parent.add(m);return m;
}
function rounded(w,h,depth,r=.1){
  const x=-w/2,y=-h/2,s=new THREE.Shape();
  s.moveTo(x+r,y);s.lineTo(x+w-r,y);s.quadraticCurveTo(x+w,y,x+w,y+r);
  s.lineTo(x+w,y+h-r);s.quadraticCurveTo(x+w,y+h,x+w-r,y+h);
  s.lineTo(x+r,y+h);s.quadraticCurveTo(x,y+h,x,y+h-r);
  s.lineTo(x,y+r);s.quadraticCurveTo(x,y,x+r,y);
  const g=new THREE.ExtrudeGeometry(s,{depth,bevelEnabled:true,bevelSegments:2,steps:1,bevelSize:.045,bevelThickness:.045,curveSegments:6});
  g.translate(0,0,-depth/2);return g;
}
const shell=mat('#424740'),bezel=mat('#202b28'),metal=mat('#979486',.45,.4),ivory=mat('#ddd0ae');
mesh(root,rounded(5.15,3.6,2.35,.22),shell,0,-.1,-.82);
mesh(root,rounded(5.02,3.48,.10,.2),metal,0,-.1,.39);
mesh(root,rounded(4.91,3.37,.12,.2),shell,0,-.1,.46);
mesh(root,rounded(3.94,3.03,.15,.27),bezel,-.46,.02,.53);
mesh(root,rounded(.82,3.05,.12,.09),mat('#565b50'),2,.02,.53);
// Side vents and casing seam make the depth visible without loading a model.
for(let i=0;i<7;i++)mesh(root,new THREE.BoxGeometry(.025,.055,.75),bezel,2.59,.70-i*.17,-.85);
mesh(root,new THREE.BoxGeometry(.025,3.0,.035),metal,2.59,-.05,-1.65);

const texture=new THREE.CanvasTexture(programs.canvas);texture.colorSpace=THREE.SRGBColorSpace;
texture.generateMipmaps=false;texture.minFilter=texture.magFilter=THREE.LinearFilter;textures.add(texture);
const maskCanvas=document.createElement('canvas');maskCanvas.width=640;maskCanvas.height=480;
const mc=maskCanvas.getContext('2d');mc.fillStyle='#000';mc.fillRect(0,0,640,480);mc.fillStyle='#fff';
mc.beginPath();mc.roundRect(0,0,640,480,56);mc.fill();
const maskTexture=new THREE.CanvasTexture(maskCanvas);textures.add(maskTexture);
const screenGeometry=new THREE.PlaneGeometry(3.7,2.78,24,18),vertices=screenGeometry.attributes.position;
for(let i=0;i<vertices.count;i++){
  const x=vertices.getX(i)/1.85,y=vertices.getY(i)/1.39;
  vertices.setZ(i,.16*(1-x*x)*(1-y*y));
}
screenGeometry.computeVertexNormals();
const screen=mesh(root,screenGeometry,new THREE.MeshBasicMaterial({
  map:texture,alphaMap:maskTexture,transparent:true,toneMapped:false,
}),-.46,.02,.64);
screen.userData.kind='screen';picks.push(screen);
mesh(root,screenGeometry,new THREE.MeshPhongMaterial({
  color:'#e6eddb',specular:'#fff6d5',shininess:65,transparent:true,opacity:.07,
  alphaMap:maskTexture,depthWrite:false,
}),-.46,.02,.66);

function label(value,x,y,width=.9,height=.23){
  const image=document.createElement('canvas');image.width=384;image.height=96;
  const c=image.getContext('2d');c.fillStyle='#ddd4b8';c.font='600 65px sans-serif';c.textAlign='center';c.textBaseline='middle';c.fillText(value,192,48);
  const map=new THREE.CanvasTexture(image);map.colorSpace=THREE.SRGBColorSpace;textures.add(map);
  return mesh(root,new THREE.PlaneGeometry(width,height),new THREE.MeshBasicMaterial({map,transparent:true,toneMapped:false}),x,y,.71);
}
label('KÊNH',2,1.27,.83,.24);label('ÂM LƯỢNG',2,.12,.83,.24);label('NGUỒN',2,-1.6,.78,.22);
function knob(y,index){
  const group=new THREE.Group();group.position.set(2,y,.76);root.add(group);
  const surround=mesh(group,new THREE.CylinderGeometry(.38,.38,.09,32),bezel);surround.rotation.x=Math.PI/2;
  const disc=mesh(group,new THREE.CylinderGeometry(.31,.33,.23,32),metal,0,0,.10);disc.rotation.x=Math.PI/2;
  mesh(group,rounded(.065,.28,.025,.018),ivory,0,.10,.23);
  const ring=mesh(group,new THREE.TorusGeometry(.40,.025,8,36),new THREE.MeshBasicMaterial({color:'#d3c997'}),0,0,.22);ring.visible=false;
  return {group,ring,index,kind:'control'};
}
const knobs=[knob(.73,2),knob(-.38,3)];
let yaw=0,pitch=0,spin=0;
for(let i=0;i<5;i++)mesh(root,rounded(.57,.035,.02,.012),bezel,2,-.9-i*.075,.63);
const power=mesh(root,new THREE.CylinderGeometry(.18,.18,.15,24),mat('#b3a786'),2,-1.31,.72);power.rotation.x=Math.PI/2;
const led=mesh(root,new THREE.SphereGeometry(.055,12,8),new THREE.MeshBasicMaterial({color:'#55604e'}),1.70,-1.31,.70);
mesh(root,rounded(.45,.20,.75,.04),bezel,-1.8,-2.02,-.6);
mesh(root,rounded(.45,.20,.75,.04),bezel,1.8,-2.02,-.6);
mesh(scene,rounded(5.8,.15,3.2,.05),mat('#9d8862'),0,-2.22,-.75);

function antenna(x,index){
  const group=new THREE.Group();group.position.set(x,1.8,-1.1);root.add(group);
  const rodMaterial=mat('#9f9c8d',.4,.55);
  mesh(group,new THREE.SphereGeometry(.16,16,10),bezel);
  mesh(group,new THREE.CylinderGeometry(.047,.065,1.55,10),rodMaterial,0,.78,0);
  const tip=mesh(group,new THREE.SphereGeometry(.095,12,8),rodMaterial,0,1.58,0);
  return {group,tip,rodMaterial,index,kind:'control'};
}
const antennas=[antenna(-.32,0),antenna(.32,1)];

// A contrasting patch lives on the actual horizontal top surface.
const roofMaterial=mat('#6e7563',.8,.05);
const roof=mesh(root,new THREE.BoxGeometry(3.55,.05,1.82),roofMaterial,-.3,1.765,-.82);
roof.userData.kind='roof';picks.push(roof);

function updateGeometry(){
  antennas.forEach((a,i)=>{
    a.group.rotation.z=(i===0?1:-1)*(.12+(controls[i]+1)*.50);
    a.rodMaterial.color.set(gesture?.index===i?'#e1cf94':'#9f9c8d');
  });
  knobs.forEach(k=>{
    const value=controls[k.index];
    k.group.rotation.z=gesture?.index===k.index&&gesture.rotation!==undefined?gesture.rotation:-value*2.25;
    k.ring.visible=gesture?.index===k.index;
  });
  roofMaterial.color.set(gesture?.kind==='roof'?'#8e987b':'#6e7563');
  led.material.color.set(state?.powered?'#b7bf7b':'#55604e');
  root.rotation.set(pitch,yaw,0);
  root.updateMatrixWorld(true);
}
function resize(){
  const w=Math.max(1,canvas.clientWidth),h=Math.max(1,canvas.clientHeight);
  renderer.setSize(w,h,false);camera.aspect=w/h;
  const half=Math.tan(THREE.MathUtils.degToRad(camera.fov/2));
  const distance=Math.max(6.1/(2*half),6.5/(2*half*camera.aspect));
  const target=new THREE.Vector3(0,.35,-.65);
  camera.position.copy(target).add(new THREE.Vector3(.29,.36,.89).normalize().multiplyScalar(distance));
  camera.lookAt(target);camera.updateProjectionMatrix();requestDraw();
}
function requestDraw(){
  dirty=true;
  if(!raf&&!disposed&&!paused&&state?.active&&!document.hidden)raf=requestAnimationFrame(frame);
}
function frame(now){
  raf=0;if(disposed||paused||!state?.active||document.hidden)return;
  if(now-lastFrame<32){raf=requestAnimationFrame(frame);return;}
  lastFrame=now;
  const tapping=now-tapAt<260;
  if(dirty||animate||gesture||tapping||Math.abs(spin)>.0001){
    if(!gesture&&Math.abs(spin)>.0001){yaw+=spin;spin*=.86;}
    updateGeometry();
    root.position.y=!state.reduceMotion&&tapping?-.025*Math.sin((now-tapAt)/260*Math.PI):0;
    const result=programs.draw({...state,controls},now,{
      holding:gesture?.kind==='roof',duration:gesture?now-gesture.started:0,
    });
    animate=result.animate;texture.needsUpdate=true;renderer.render(scene,camera);dirty=false;
    if(result.playbackEnd!==undefined)bridge('action',{kind:'playbackEnd',playback:result.playbackEnd});
  }
  if(animate||gesture||tapping||Math.abs(spin)>.0001)raf=requestAnimationFrame(frame);
}
function cancelGesture(){
  const old=gesture;gesture=null;
  if(old&&canvas.hasPointerCapture(old.id))canvas.releasePointerCapture(old.id);
  updateGeometry();
}
function flush(){
  clearTimeout(sendTimer);sendTimer=0;
  if(!pending||!state?.active||paused||disposed){pending=null;return;}
  const value=pending;pending=null;serial++;
  bridge('action',{kind:'control',index:value.index,value:value.value,serial});
}
function sendControl(index){
  pending={index,value:controls[index]};
  if(!sendTimer)sendTimer=setTimeout(flush,40);
}
window.applySongCu=function(next){
  if(disposed||!next||typeof next.epoch!=='number')return;
  if(state&&next.epoch===state.epoch&&next.revision<state.revision)return;
  const previous=state,newEpoch=!previous||next.epoch!==previous.epoch;
  if(newEpoch){
    clearTimeout(sendTimer);sendTimer=0;pending=null;serial=next.ack;cancelGesture();
    controls=[...next.controls];tapAt=-1000;
  }else if(!gesture&&!pending&&next.ack>=serial)controls=[...next.controls];
  state=next;paused=false;
  sounds.configure({...state,volume:(controls[3]+1)/4,active:state.active&&!document.hidden});
  if(previous&&previous.epoch===state.epoch){
    if(previous.channel!==state.channel)sounds.play('channel');
    if(previous.powered!==state.powered)sounds.play(state.powered?'on':'off');
    if(previous.playback!==state.playback&&state.playing)sounds.play('signal');
  }
  if(previous&&previous.epoch===state.epoch&&state.complete&&!previous.complete)sounds.play('success');
  if(!state.active){
    flush();cancelGesture();cancelAnimationFrame(raf);raf=0;sounds.pause();
  }else{updateGeometry();requestDraw();}
};

function clientPoint(world){
  const rect=canvas.getBoundingClientRect(),p=world.clone().project(camera);
  return new THREE.Vector2(rect.left+(p.x+1)*.5*rect.width,rect.top+(1-p.y)*.5*rect.height);
}
function segmentDistance(p,a,b){
  const ab=b.clone().sub(a),den=ab.lengthSq();
  const t=den?THREE.MathUtils.clamp(p.clone().sub(a).dot(ab)/den,0,1):0;
  return p.distanceTo(a.clone().addScaledVector(ab,t));
}
function hit(event){
  root.updateMatrixWorld(true);
  const p=new THREE.Vector2(event.clientX,event.clientY);
  const front=new THREE.Vector3(0,0,1).applyQuaternion(root.quaternion)
    .dot(camera.position.clone().sub(root.position).normalize())>.15;
  // Screen-space hit targets retain a usable size when the camera is angled.
  for(const k of knobs){
    const center=clientPoint(k.group.getWorldPosition(new THREE.Vector3()));
    const radius=Math.max(27,center.distanceTo(clientPoint(k.group.localToWorld(new THREE.Vector3(.4,0,0))))+8);
    if(front&&p.distanceTo(center)<=radius)return {kind:'control',index:k.index};
  }
  if(front&&p.distanceTo(clientPoint(power.getWorldPosition(new THREE.Vector3())))<=25)return {kind:'power'};
  let nearest=null,nearestDistance=24;
  for(const a of antennas){
    const start=clientPoint(a.group.localToWorld(new THREE.Vector3(0,.35,0)));
    const end=clientPoint(a.tip.getWorldPosition(new THREE.Vector3()));
    const distance=segmentDistance(p,start,end);
    if(distance<nearestDistance){nearestDistance=distance;nearest={kind:'control',index:a.index};}
  }
  if(nearest)return nearest;
  const rect=canvas.getBoundingClientRect();
  pointer.set((event.clientX-rect.left)/rect.width*2-1,-(event.clientY-rect.top)/rect.height*2+1);
  ray.setFromCamera(pointer,camera);
  const contact=ray.intersectObjects(picks,false)[0];
  if(!contact)return null;
  if(contact.object===roof)return {kind:'roof'};
  const target=programs.hit(contact.uv);
  return target?{kind:'screen',target}:null;
}
function action(kind,extra={}){
  if(!state?.active||paused||disposed)return;
  if(kind!=='power'&&(!state.powered||state.complete))return;
  flush();bridge('action',{kind,...extra});
  if(kind==='roof')sounds.play('tap');
}
function down(event){
  if(!state?.active||paused||disposed||gesture)return;
  const picked=hit(event)||{kind:'orbit'};
  if(!state.powered&&!['power','orbit'].includes(picked.kind))return;
  if(state.complete&&!['power','orbit'].includes(picked.kind)&&picked.index!==3)return;
  sounds.unlock();canvas.setPointerCapture(event.pointerId);
  if(picked.kind==='control')sounds.play('click');
  gesture={...picked,id:event.pointerId,x:event.clientX,y:event.clientY,
    origin:picked.index===undefined?0:controls[picked.index],axis:null,started:performance.now(),moved:false};
  spin=0;
  if(picked.kind==='control'&&picked.index>=2){
    const k=knobs.find(k=>k.index===picked.index);
    gesture.center=clientPoint(k.group.getWorldPosition(new THREE.Vector3()));
    gesture.angle=Math.atan2(event.clientY-gesture.center.y,event.clientX-gesture.center.x);
    gesture.rotation=-controls[picked.index]*2.25;
  }
  updateGeometry();requestDraw();
}
function move(event){
  if(!gesture||gesture.id!==event.pointerId)return;
  const g=gesture,dx=event.clientX-g.x,dy=g.y-event.clientY;
  if(Math.hypot(dx,dy)>(g.kind==='roof'?18:10))g.moved=true;
  if(g.kind==='orbit'||(g.kind==='roof'&&g.moved)){
    yaw+=(event.clientX-(g.lastX??g.x))*.009;
    pitch=THREE.MathUtils.clamp(pitch+(event.clientY-(g.lastY??g.y))*.006,-.8,.8);
    spin=state.reduceMotion?0:THREE.MathUtils.clamp((event.clientX-(g.lastX??g.x))*.002,-.035,.035);
    g.lastX=event.clientX;g.lastY=event.clientY;requestDraw();return;
  }
  if(g.kind!=='control')return;
  if(g.index>=2){
    if(Math.hypot(event.clientX-g.center.x,event.clientY-g.center.y)<9)return;
    const angle=Math.atan2(event.clientY-g.center.y,event.clientX-g.center.x);
    const delta=Math.atan2(Math.sin(angle-g.angle),Math.cos(angle-g.angle));g.angle=angle;
    g.rotation=THREE.MathUtils.clamp(g.rotation-delta,-2.25,2.25);
    const value=-g.rotation/2.25;
    if(g.index===2){
      const old=Math.round((controls[2]+1)*3.5),candidate=(value+1)*3.5;
      if(Math.abs(candidate-old)>.62){controls[2]=Math.round(candidate)/3.5-1;sounds.play('channel');}
    }else{controls[3]=value;sounds.configure({...state,volume:(value+1)/4});}
    updateGeometry();sendControl(g.index);requestDraw();return;
  }
  if(!g.axis&&Math.hypot(dx,dy)>=3)g.axis=Math.abs(dx)>=Math.abs(dy)?'x':'y';
  if(!g.axis)return;
  let delta=g.axis==='x'?dx:dy;
  if(g.index<2){
    // Drag outward to lower an antenna, inward/upward to raise it.
    if(g.axis==='x'&&g.index===0)delta=-delta;
    if(g.axis==='y')delta=-delta;
  }
  controls[g.index]=THREE.MathUtils.clamp(g.origin+delta*(g.index<2?.01:.012),-1,1);
  updateGeometry();sendControl(g.index);requestDraw();
}
function up(event){
  if(!gesture||gesture.id!==event.pointerId)return;
  const g=gesture,duration=performance.now()-g.started;
  flush();cancelGesture();
  if(g.kind==='control'){bridge('action',{kind:'saveControls'});requestDraw();return;}
  if(g.moved){requestDraw();return;}
  if(g.kind==='power')action('power');
  else if(g.kind==='roof'){
    tapAt=performance.now();
    action('roof',{duration:Math.round(duration)});
  }else if(g.kind==='screen'){
    const end=hit(event);
    if(end?.kind==='screen'&&end.target.kind===g.target.kind)action(g.target.kind);
  }
  requestDraw();
}
listen(canvas,'pointerdown',down);listen(canvas,'pointermove',move);listen(canvas,'pointerup',up);
listen(canvas,'pointercancel',()=>{flush();cancelGesture();requestDraw();});
listen(canvas,'lostpointercapture',()=>{if(gesture){flush();cancelGesture();requestDraw();}});
listen(canvas,'webglcontextlost',e=>{e.preventDefault();fail();});
listen(window,'resize',resize);
const observer=new ResizeObserver(resize);observer.observe(canvas);
listen(document,'visibilitychange',()=>{
  if(document.hidden)window.pauseSongCu();
  else if(state?.active){paused=false;sounds.configure(state);requestDraw();}
});
window.pauseSongCu=function(){
  spin=0;
  flush();paused=true;cancelGesture();cancelAnimationFrame(raf);raf=0;clearTimeout(sendTimer);sendTimer=0;pending=null;sounds.pause();
};
window.disposeSongCu=function(){
  if(disposed)return;
  window.pauseSongCu();disposed=true;observer.disconnect();listeners.splice(0).forEach(remove=>remove());
  sounds.dispose();programs.dispose();textures.forEach(t=>t.dispose());geometries.forEach(g=>g.dispose());materials.forEach(m=>m.dispose());
  renderer.dispose();renderer.forceContextLoss();canvas.remove();picks.length=0;scene.clear();
};
listen(window,'pagehide',()=>window.disposeSongCu());
// Read-only measurements for native touch and rendered-screen regression tests.
window.songCuSnapshot=()=>{
  const pixels=programs.context.getImageData(0,0,640,480).data;
  let picture=0;for(let i=0;i<pixels.length;i+=97)picture=(picture*31+pixels[i])>>>0;
  return {controls:[...controls],yaw,pitch,volume:sounds.volume,picture,raf,
    seasons:programs.seasons.complete&&programs.seasons.naturalWidth>0,
    channel:programs.channel,
    targets:[...knobs.map(k=>k.group),...antennas.map(a=>a.tip),power].map(g=>{
      const p=clientPoint(g.getWorldPosition(new THREE.Vector3())),r=canvas.getBoundingClientRect();
      return {x:(p.x-r.left)/r.width,y:(p.y-r.top)/r.height};
    })};
};
resize();bridge('ready');
