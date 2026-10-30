// Offline renderer. Game rules and network state remain in Dart.
import * as T from "three";
import { mergeGeometries } from "three/addons/utils/BufferGeometryUtils.js";
const host = document.createElement("div");
host.innerHTML = `<style>
*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#ead4af;font-family:system-ui,sans-serif;color:#56331f;touch-action:none;user-select:none}
canvas{display:block;width:100%;height:100%;outline:0;touch-action:none}
#title{position:absolute;top:9px;left:12px;padding:6px 11px;background:#fff5dfed;border-radius:12px;pointer-events:none;font-size:12px;font-weight:700}
#hint{position:absolute;bottom:9px;left:50%;transform:translateX(-50%);max-width:74%;padding:6px 12px;border-radius:12px;background:#fff5dfed;font-size:11px;text-align:center;pointer-events:none;white-space:nowrap}
.zone{position:absolute;border:2px dashed #c68d56;border-radius:13px;background:#fff2d6dd;color:#724521;padding:8px 10px;font-size:11px;font-weight:700;min-height:40px}
.zone.hot{background:#b8efd3;border-color:#319a73}.side{top:44%;min-width:48px;text-align:center;pointer-events:none;opacity:.85}
#left{left:7px}#right{right:7px}#trash{left:10px;bottom:9px}#serve{right:10px;bottom:9px;background:#d6efce;border-color:#76a86b}
#actions{position:absolute;left:50%;bottom:40px;transform:translateX(-50%);display:none;gap:5px;padding:5px;background:#fff4deed;border-radius:13px;white-space:nowrap}
button{border:1px solid #bf8b52;border-radius:9px;background:#ffe0a0;color:#59371f;padding:7px 10px;min-height:34px;font:600 11px system-ui;cursor:pointer}button:disabled{opacity:.45;cursor:default}button:active{transform:scale(.97)}
#paging{position:absolute;right:9px;top:8px;display:none;gap:4px;align-items:center;font-size:11px;background:#fff4deed;padding:3px;border-radius:10px}
.tag{position:absolute;left:0;top:0;font-size:10px;font-weight:600;background:#fff4dfec;padding:3px 7px;border-radius:7px;white-space:nowrap;pointer-events:none;will-change:transform}
.tag.chosen{background:#ffe399;outline:2px solid #c98335}#quality{position:absolute;right:10px;top:46px;padding:5px;font-size:10px;min-height:26px;background:#fff4decc}
@media(max-height:260px){.tag{font-size:9px}#hint{font-size:10px;bottom:6px}.zone{padding:5px;min-height:30px;font-size:10px}#actions{bottom:35px}#title{font-size:11px;padding:4px 8px}}
#paging,#hint,#title,#labels,.side,#trash,#serve,#passL,#passR{display:none!important}
#orders{position:absolute;top:8px;left:50%;transform:translateX(-50%);display:flex;gap:6px;pointer-events:none;max-width:70%;overflow:hidden}
.ticket{background:#fff5df;border:2px solid #d7a66c;border-radius:10px;padding:5px 14px;font-size:clamp(24px,4.4vh,36px);box-shadow:0 3px 0 #b98750}
#title{top:68px}#paging{top:68px}#quality{top:105px}
#actions{bottom:14px}#quality{top:auto;bottom:12px;font-size:14px;min-height:38px}#paging{top:auto;bottom:12px;right:auto;left:12px;font-size:16px}#paging button{font-size:22px;min-width:40px}#hint{font-size:10px;background:#fff5dfbb}
#hint.toast{display:block!important}
#orders{top:12px;left:16px;transform:none;gap:10px;max-width:82%;overflow:visible}
.ticket{position:relative;display:flex;align-items:center;justify-content:center;width:84px;height:66px;padding:6px;border:1px solid #e8c895;border-top:5px solid #348a72;border-radius:5px 5px 14px 14px;background:linear-gradient(#fffdf3,#fff1d3);box-shadow:0 6px 10px #45270e30;font-size:26px}
.ticket:before{content:'';position:absolute;top:-10px;left:28px;width:28px;height:9px;border-radius:3px;background:#ac7035;box-shadow:inset 0 2px #d69d5c}
.ticket svg{width:64px;height:50px}.ticket.hot{border-color:#4aaf8c;transform:translateY(3px)}
#quality{width:38px;height:38px;padding:0;border-radius:50%;background:#fff7e0dd;border:1px solid #d7af76;color:#85542d;font-size:22px;box-shadow:0 3px 8px #57301826}
#work{position:absolute;left:50%;transform:translate(-50%,-50%);color:#307f68;background:#fff9e5ed;border:1px solid #cda766;border-radius:30px;padding:1px 9px;font-size:17px;letter-spacing:4px;pointer-events:none;box-shadow:0 3px 8px #40260f20}
</style><div id="work"></div><div id="orders"></div><div id="title"></div><div id="hint">↑ Nộp món · ↓ Bỏ đồ · ← → Chuyền</div>
<div id="left" class="zone side">←<br>Chuyền</div><div id="right" class="zone side">→<br>Chuyền</div>
<button id="trash" class="zone" aria-label="Bỏ vật phẩm đã chọn">Bỏ đồ</button><button id="serve" class="zone" aria-label="Nộp sản phẩm đã chọn">Nộp đơn</button>
<div id="actions"><button id="passL">← Chuyền</button><button id="process">Chế biến</button><button id="passR">Chuyền →</button></div>
<button id="quality" aria-label="Đổi chất lượng hình ảnh">◈</button><div id="labels"></div>`;
document.body.appendChild(host);
const el = (id) => host.querySelector("#" + id);
const tell = (type, value = {}) => window.Bartender3D?.postMessage(JSON.stringify({ type, ...value }));
let scene, camera, renderer, canvas, stationModel, disposed = false, active = true;
let raf = 0, drag = null, selected = null, pending = false, pendingTimer = 0;
let loaded = null, strokes = 0;
let pulseAt = -10000, lowQuality = false, sensorAvailable = true, renders = 0;
let state = { items: [], orders: [], station: null, round: null, busy: false };
const models = /* @__PURE__ */ new Map(), geometries = /* @__PURE__ */ new Map(), materials = /* @__PURE__ */ new Map(), resources = /* @__PURE__ */ new Set();
const listeners = [], frames = [], itemShapes = new Map();
let itemMaterial, selectionRing, pileShadows, shadowMaterial;
let lastFrame = 0, toastTimer = 0;
let bufferResizes=0,shadowUpdates=0,layoutPasses=0,shadowDirty=true,orderSignature='',reportedPreparation=null;
let bufferWidth=0,bufferHeight=0,bufferRatio=0;
const shadowMatrix=new T.Matrix4(),shadowPosition=new T.Vector3(),shadowScale=new T.Vector3(1,1,1),shadowRotation=new T.Quaternion().setFromAxisAngle(new T.Vector3(1,0,0),-Math.PI/2);
const pointer = new T.Vector2(), ray = new T.Raycaster(), plane = new T.Plane(new T.Vector3(0, 1, 0), -0.78), hit = new T.Vector3();
const projected = new T.Vector3();
let bounds;
function listen(target, type, fn, options) {
  target.addEventListener(type, fn, options);
  listeners.push(() => target.removeEventListener(type, fn, options));
}
function geo(key, make) {
  if (!geometries.has(key)) {
    const g = make();
    geometries.set(key, g);
    resources.add(g);
  }
  return geometries.get(key);
}
function material(color) {
  if (!materials.has(color)) {
    const m = new T.MeshLambertMaterial({ color });
    materials.set(color, m);
    resources.add(m);
  }
  return materials.get(color);
}
function mesh(parent, geometry, color, x = 0, y = 0, z = 0, scale) {
  const m = new T.Mesh(geometry, material(color));
  m.position.set(x, y, z);
  if (scale) m.scale.set(...scale);
  parent.add(m);
  return m;
}
const box = () => geo("box", () => new T.BoxGeometry(1, 1, 1));
const ball = () => geo("ball", () => new T.SphereGeometry(1, 16, 10));
const cyl = () => geo("cylinder", () => new T.CylinderGeometry(1, 1, 1, 16));
const cone = () => geo("cone", () => new T.ConeGeometry(1, 1, 12));
function cube(p, c, x, y, z, sx, sy, sz) {
  return mesh(p, box(), c, x, y, z, [sx, sy, sz]);
}
function sphere(p, c, x, y, z, sx, sy = sx, sz = sx) {
  return mesh(p, ball(), c, x, y, z, [sx, sy, sz]);
}
function cylinder(p, c, x, y, z, r, h) {
  return mesh(p, cyl(), c, x, y, z, [r, h, r]);
}
function leaf(p, x, y, z, s = 0.19) {
  const l = sphere(p, 5608540, x, y, z, s, 0.055, s * 0.5);
  l.rotation.z = 0.4;
}
function face(p, z = 0.36, y = 0.13) {
  for (const x of [-0.115, 0.115]) sphere(p, 6044199, x, y, z, 0.029);
  const mouth = sphere(p, 9195573, 0, y - 0.105, z, 0.05, 0.018, 0.015);
  return mouth;
}
function batch(root) {
  root.updateMatrixWorld(true);
  const groups = /* @__PURE__ */ new Map();
  root.traverse((o) => {
    if (!o.isMesh) return;
    const g = o.geometry.clone().applyMatrix4(o.matrixWorld);
    if (!groups.has(o.material)) groups.set(o.material, []);
    groups.get(o.material).push(g);
  });
  root.clear();
  root.position.set(0, 0, 0);
  for (const [mat, parts] of groups) {
    const merged = mergeGeometries(parts);
    parts.forEach((g) => g.dispose());
    resources.add(merged);
    root.add(new T.Mesh(merged, mat));
  }
}
function environment() {
  const room = new T.Group();
  scene.add(room);
  cube(room, 15322533, 0, -0.65, -0.4, 30, 0.4, 20);
  cube(room, 0x835a3c, 0, 2.1, -3.6, 20, 6, 0.2);
  for(let i=0;i<15;i++) cube(room,i%2?0x486d60:0x50796a,-6.6+i*.94,.9,-3.44,.91,1.2,.08);
  cube(room,0xd7af6d,0,1.53,-3.39,14,.035,.08);
  cube(room, 11367248, 0, 1.7, -3.38, 12, 0.13, 0.55);
  cube(room, 11367248, 0, 3.05, -3.38, 12, 0.13, 0.55);
  for (let i = 0; i < 10; i++) {
    const x = -4.7 + i * 1.04;
    const y = i % 2 ? 2.2 : 3.5;
    cylinder(room, [10271363, 14790751, 10905681, 8759457][i % 4], x, y, -3.3, 0.17, 0.66);
    cylinder(room, 7162164, x, y + 0.39, -3.3, 0.085, 0.18);
  }
  for (const x of [-4.7, 4.7]) {
    cylinder(room, 14265463, x, 1.7, -2.65, 0.27, 0.44);
    for (let i = 0; i < 5; i++) sphere(room, 6327120, x + Math.sin(i * 2) * 0.18, 2.1 + i * 0.065, -2.65 + Math.cos(i) * 0.14, 0.23, 0.38, 0.2);
  }
  for (const x of [-3, 0, 3]) {
    cylinder(room, 7885882, x, 4.15, -1.85, 0.025, 1.3);
    mesh(room, cone(), 14920274, x, 3.45, -1.85, [0.42, 0.28, 0.42]);
  }
  cube(room, 9131575, 0, -0.02, 0, 11.2, 0.55, 6.35);
  cube(room,0x865035,0,.24,0,11.6,.18,6.6);
  for(const x of [-5.7,5.7]) cube(room,0xd5a765,x,.4,0,.12,.07,6.55);
  cube(room,0xe0b77b,0,.4,3.22,11.5,.07,.1);
  const grain = document.createElement("canvas");
  grain.width = grain.height = 256;
  const ctx = grain.getContext("2d");
  ctx.fillStyle = "#fff0d6";
  ctx.fillRect(0, 0, 256, 256);
  for (let i = 0; i < 90; i++) {
    const y = i * 47.1 % 256;
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.bezierCurveTo(75, y + Math.sin(i) * 8, 180, y - 4, 256, y + 2);
    ctx.strokeStyle = i % 3 ? "rgba(133,82,37,.10)" : "rgba(255,255,255,.4)";
    ctx.lineWidth = i % 4 ? 0.7 : 1.5;
    ctx.stroke();
  }
  const texture = new T.CanvasTexture(grain);
  texture.colorSpace = T.SRGBColorSpace;
  resources.add(texture);
  for (let i = 0; i < 8; i++) {
    const plank = cube(room, i % 2 ? 0xc99353 : 0xd29c5b, 0, 0.365, -2.85 + i * 0.81, 11.3, 0.025, 0.79);
    plank.material.map = texture;
  }
  cube(room,0x75432d,0,-.18,3.16,11.5,.43,.15);
  cube(room,0xbd8d57,0,-.04,3.25,10.9,.025,.04);
  for(const x of [-5.25,5.25]) sphere(room,0xdfb87b,x,-.19,3.26,.065,.065,.025);
  for (const x of [-4.8, 4.8]) cube(room, 10249536, x, -1.1, 2.45, 0.35, 1.4, 0.35);
  batch(room);
}
function torus(parent, color, x,y,z,radius,tube) {
  const m=mesh(parent,geo(`ring:${radius}:${tube}`,()=>new T.TorusGeometry(radius,tube,8,32)),color,x,y,z);
  m.rotation.x=-Math.PI/2; return m;
}
function makeStation(type) {
  const g = new T.Group();
  g.position.set(0, 0.39, -1.5);
  cube(g, 16179893, 0, 0.03, 0, 2.6, 0.08, 1.5);
  if (type === "juicer") {
    // Enamel citrus press: empty bowl/cone, a raised head and a separate juice glass.
    cylinder(g,0x285e52,0,.12,.05,.77,.24);
    cylinder(g,0x458e78,0,.27,.02,.68,.28);
    cylinder(g,0xf9e7bc,0,.48,.02,.64,.22);
    torus(g,0xfff5d8,0,.62,.02,.57,.065);
    mesh(g,cone(),0xf4c86b,0,.77,.02,[.3,.36,.3]);
    for(let i=0;i<8;i++) {
      const a=i*Math.PI/4; const rib=cube(g,0xcaa754,Math.sin(a)*.2,.76,.02+Math.cos(a)*.2,.025,.27,.045);
      rib.rotation.y=a;
    }
    cube(g,0x25574c,-.53,.9,-.43,.19,1.55,.23);
    cylinder(g,0xe9bf6f,-.53,1.63,-.43,.13,.18).rotation.z=Math.PI/2;
    const head=new T.Group();head.position.set(0,1.5,.02);g.add(head);
    cylinder(head,0xffedca,0,0,0,.52,.16);
    torus(head,0xc59a54,0,-.07,0,.45,.03);
    const lever=cube(head,0x326e5d,.4,.12,0,1,.1,.16); lever.rotation.z=.15;
    cylinder(head,0xeac577,.92,.18,0,.11,.29).rotation.z=Math.PI/2;
    g.userData.head=head;
    cube(g,0xb6c2b7,.64,.44,.2,.38,.1,.14);
    cylinder(g,0xf5e6c3,.94,.27,.35,.23,.48);
    const juice=cylinder(g,0xffb62f,.94,.1,.35,.195,.01);g.userData.juice=juice;
    torus(g,0xfff7df,.94,.53,.35,.215,.025);
    for(let i=0;i<4;i++) sphere(g,0xbacbb8,-.24+i*.16,.29,.66,.038);
  } else if (type === "blender") {
    cylinder(g, 7575430, 0, 0.18, 0, 0.43, 0.3);
    cylinder(g, 12439999, 0, 0.65, 0, 0.32, 0.65);
    cylinder(g, 5860444, 0, 1, 0, 0.37, 0.09);
    cube(g, 15131081, 0.41, 0.68, 0, 0.12, 0.39, 0.18);
    sphere(g, 16040550, 0, 0.19, 0.42, 0.08);
  } else if (type === "shaker") {
    cylinder(g, 13158842, 0, 0.49, 0, 0.31, 0.9);
    sphere(g, 14738131, 0, 0.98, 0, 0.31, 0.15, 0.31);
    cylinder(g, 10727334, 0, 1.13, 0, 0.13, 0.18);
    cylinder(g, 9742236, 0, 0.53, 0, 0.319, 0.08);
  } else if (type === "cuttingBoard") {
    cube(g, 11763790, 0, 0.13, 0, 1.65, 0.18, 0.95);
    cube(g, 14795148, -0.3, 0.23, 0, 0.7, 0.025, 0.55);
    const knife = cube(g, 12963775, 0.3, 0.3, 0, 0.12, 0.045, 0.7);
    knife.rotation.y = -0.5;g.userData.knife=knife;
    const handle = cube(g, 6705210, 0.47, 0.32, -0.4, 0.14, 0.09, 0.32);
    handle.rotation.y = -0.5;g.userData.handle=handle;
  } else {
    cylinder(g, 11897688, 0, 0.13, 0, 0.48, 0.18);
    sphere(g, 16172643, 0, 0.43, 0, 0.31);
    leaf(g, 0.16, 0.69, 0);
  }
  g.scale.setScalar(1.35);
  return g;
}
function makeItem(kind) {
  const g = new T.Group();
  if(itemShapes.has(kind)) {
    g.add(new T.Mesh(itemShapes.get(kind),itemMaterial));g.scale.setScalar(1.25);return g;
  }
  if (kind === "orange" || kind === "lemon") {
    const lemon = kind === "lemon";
    sphere(g, lemon ? 15979612 : 15769922, 0, 0, 0, lemon ? 0.43 : 0.37, lemon ? 0.3 : 0.38, 0.34);
    cylinder(g, 9137475, 0, 0.37, 0, 0.028, 0.15);
    leaf(g, 0.12, 0.4, 0);
    if (!lemon) {
      for (let i=0;i<12;i++) {
        const a=i*2.4;
        mesh(g,geo('pore',()=>new T.IcosahedronGeometry(1,0)),0xe88b18,Math.sin(a)*.28,Math.cos(a)*.25,.22+Math.sin(i)*.025,[.016,.016,.016]);
      }
      sphere(g, 0xffd57a, -.13,.18,.25,.07,.045,.02);
    }
    face(g, 0.36);
  } else if (kind === "strawberry" || kind === "cut_strawberry") {
    const cut = kind === "cut_strawberry";
    const n = cut ? 3 : 1;
    for (let i = 0; i < n; i++) {
      const part = mesh(g, cone(), 14120548, (i - (n - 1) / 2) * 0.19, cut ? -0.08 : 0, 0, [cut ? 0.19 : 0.34, cut ? 0.35 : 0.65, cut ? 0.2 : 0.32]);
      part.rotation.z = Math.PI;
    }
    if (!cut) {
      sphere(g, 14115938, 0, 0.08, 0, 0.33, 0.29, 0.31);
      leaf(g, 0.1, 0.32, 0, 0.25);
      face(g, 0.34);
      for (const x of [-0.17, 0, 0.17]) {
        sphere(g, 16769952, x, 0.24, 0.2, 0.014, 0.025, 0.012);
      }
    }
  } else if (kind === "ice") {
    const m = cube(g, 11785170, 0, 0, 0, 0.54, 0.5, 0.5);
    m.rotation.y = 0.4;
    cube(g, 14018270, -0.13, 0.13, 0.26, 0.13, 0.13, 0.015);
  } else if (kind === "milk") {
    cube(g, 15920591, 0, 0, 0, 0.48, 0.65, 0.44);
    cube(g, 9615794, 0, -0.1, 0.23, 0.49, 0.19, 0.025);
    cube(g, 14997428, 0, 0.38, 0, 0.49, 0.13, 0.44);
    face(g, 0.23, 0.08);
  } else if (kind === "sugar") {
    cube(g, 15190167, 0, 0, 0, 0.53, 0.57, 0.35);
    cube(g, 16050119, 0, 0.05, 0.19, 0.35, 0.21, 0.025);
    face(g, 0.21, 0.08);
  } else {
    const red = kind.includes("strawberry");
    const cocktail = kind === "citrus_cocktail" || kind === "strawberry_lemonade";
    const c = red ? 14188924 : kind.includes("lemon") ? 15061092 : 15577937;
    cylinder(g, 15458244, 0, -0.08, 0, 0.29, 0.65);
    cylinder(g, c, 0, -0.01, 0, 0.3, 0.48);
    cylinder(g, 16246982, 0, 0.28, 0, 0.315, 0.055);
    const straw = cylinder(g, 7575169, 0.1, 0.48, -0.03, 0.021, 0.48);
    straw.rotation.z = -0.2;
    face(g, 0.3);
    if (cocktail) {
      sphere(g, 14791517, -0.24, 0.36, 0, 0.16, 0.16, 0.04);
      leaf(g, 0.22, 0.32, 0);
    }
  }
  g.updateMatrixWorld(true);
  const parts=[];
  g.traverse(o=>{
    if(!o.isMesh)return;
    const part=(o.geometry.index?o.geometry.toNonIndexed():o.geometry.clone()).applyMatrix4(o.matrixWorld);
    const colors=new Float32Array(part.getAttribute('position').count*3);
    for(let i=0;i<colors.length;i+=3) colors.set([o.material.color.r,o.material.color.g,o.material.color.b],i);
    part.setAttribute('color',new T.BufferAttribute(colors,3));parts.push(part);
  });
  const shape=mergeGeometries(parts);parts.forEach(p=>p.dispose());
  resources.add(shape);itemShapes.set(kind,shape);
  if(!itemMaterial){itemMaterial=new T.MeshLambertMaterial({vertexColors:true});resources.add(itemMaterial);}
  g.clear();g.add(new T.Mesh(shape,itemMaterial));g.scale.setScalar(1.25);
  return g;
}
// The pile is presentation state only. No inbox cap, deletion, pages or network coordinates.
function pileHeight(x,z,placed) {
  let y=.9;
  for(const other of placed) {
    const d=Math.hypot(x-other.rest.x,z-other.rest.z);
    if(d<.94) y=Math.max(y,other.rest.y+Math.sqrt(.94*.94-d*d)*.93);
  }
  return y;
}
function newRest(placed) {
  // A random drop rolls a short distance toward a lower local resting place.
  // This forms a heap instead of unsupported tall columns or a regular grid.
  const x=(Math.random()-.5)*8.3,z=.15+Math.random()*2.2;
  let best=new T.Vector3(x,pileHeight(x,z,placed),z);
  for(let i=0;i<7;i++) {
    const a=Math.random()*Math.PI*2;
    const cx=T.MathUtils.clamp(x+Math.cos(a)*.65,-4.5,4.5),cz=T.MathUtils.clamp(z+Math.sin(a)*.45,.05,2.5);
    const y=pileHeight(cx,cz,placed);
    if(y<best.y-.035)best.set(cx,y,cz);
  }
  return best;
}
function updatePileShadows() {
  if(!shadowMaterial) {
    const c=document.createElement('canvas');c.width=c.height=64;
    const ctx=c.getContext('2d'),g=ctx.createRadialGradient(32,32,2,32,32,32);
    g.addColorStop(0,'rgba(61,35,17,.32)');g.addColorStop(.45,'rgba(61,35,17,.16)');g.addColorStop(1,'rgba(61,35,17,0)');
    ctx.fillStyle=g;ctx.fillRect(0,0,64,64);
    const texture=new T.CanvasTexture(c);resources.add(texture);
    shadowMaterial=new T.MeshBasicMaterial({map:texture,transparent:true,depthWrite:false});resources.add(shadowMaterial);
  }
  if(!pileShadows||pileShadows.instanceMatrix.count<models.size) {
    if(pileShadows){scene.remove(pileShadows);pileShadows.dispose();resources.delete(pileShadows);}
    pileShadows=new T.InstancedMesh(geo('pileShadow',()=>new T.PlaneGeometry(1.55,1.3)),shadowMaterial,Math.max(1,2**Math.ceil(Math.log2(Math.max(1,models.size)))));
    pileShadows.instanceMatrix.setUsage(T.DynamicDrawUsage);pileShadows.frustumCulled=false;
    resources.add(pileShadows);scene.add(pileShadows);
  }
  shadowUpdates++;
  let i=0;
  for(const m of models.values()) {
    if(m.id===loaded)continue;
    shadowPosition.set(m.group.position.x,.392,m.group.position.z);
    shadowMatrix.compose(shadowPosition,shadowRotation,shadowScale);
    pileShadows.setMatrixAt(i++,shadowMatrix);
  }
  pileShadows.count=i;pileShadows.instanceMatrix.needsUpdate=true;shadowDirty=false;
}
function reflowPile(animate=true) {
  const placed=[];
  for(const m of [...models.values()].filter(m=>m.id!==loaded&&m.id!==drag?.id).sort((a,b)=>a.rest.y-b.rest.y)) {
    const y=pileHeight(m.rest.x,m.rest.z,placed);
    if(Math.abs(y-m.rest.y)>.03) {
      m.rest.y=y;
      if(animate) m.spawn={at:performance.now(),from:m.group.position.clone(),landing:m.rest.clone(),sign:m.tilt<0?-1:1};
      else m.group.position.copy(m.rest);
    }
    placed.push(m);
  }
}
function syncStationVisual() {
  const item=models.get(loaded);
  if(stationModel?.userData.head) stationModel.userData.head.position.y=item?1.16:1.5;
  if(stationModel?.userData.juice) {
    const fill=item?strokes/4:0;
    const juice=stationModel.userData.juice;
    juice.scale.y=Math.max(.01,fill*.32);juice.position.y=.11+fill*.16;
  }
  if(item) {
    item.group.position.set(0,state.station==='juicer'?1.55:1.2,-1.48);
    item.group.rotation.set(0,0,0);
    item.group.scale.setScalar(state.station==='juicer'?.94:1.1);
  }
}

function hint(text,temporary=false) {
  if(!temporary)return;
  el('hint').textContent=text;el('hint').classList.add('toast');clearTimeout(toastTimer);
  toastTimer=setTimeout(()=>el('hint').classList.remove('toast'),2400);
}
function choose(id) {
  const selectionChanged=selected!==id;
  selected = id;
  el('work').style.display=loaded&&state.station!=='shaker'?'block':'none';
  el("work").textContent = loaded && state.station !== "shaker" ? "●".repeat(strokes)+"○".repeat(4-strokes) : "";
  const item = state.items.find((i) => i.id === id);
  el("actions").style.display = item && state.station === "shaker" && !sensorAvailable ? "flex" : "none";
  if(selectionRing) selectionRing.visible=!!item;
  const shake = state.station === "shaker";
  el("process").textContent = shake ? sensorAvailable ? "Lắc điện thoại" : "Lắc giả lập" : "Chế biến";
  el("process").disabled = !item?.processable || shake && sensorAvailable || pending || state.busy;
  el("serve").disabled = !item || !state.orders.some((o) => o.product === item.kind) || pending || state.busy;
  el("trash").disabled = !item || pending || state.busy;
  el("passL").disabled = el("passR").disabled = !item || pending || state.busy;
  if(selectionChanged)tell("selected", { id });
  requestRender();
}
function action(name, id = selected) {
  const item = state.items.find((i) => i.id === id);
  if (!item || pending || state.busy) return;
  const order = state.orders.find((o) => o.product === item.kind);
  if (name === "submit" && !order) {
    hint("Món này chưa khớp đơn đang chờ.", true);
    return;
  }
  if (name === "process" && (!item.processable || state.station === "shaker" && sensorAvailable)) {
    hint(state.station === "shaker" ? "Lắc điện thoại để pha chế món đã chọn." : "Trạm này chưa xử lý được món đã chọn.", true);
    return;
  }
  pending = true;
  clearTimeout(pendingTimer);
  pendingTimer = setTimeout(() => {
    pending = false;
    choose(selected);
    hint("Đang chờ cập nhật vật phẩm…", true);
  }, 5e3);
  choose(selected);
  tell("action", { action: name, id, order: order?.id, round: state.round });
}
// Progress stays local to this item and station; only the final stroke requests
// the existing Dart processing action. Room/schema contracts stay unchanged.
function loadStation(id) {
  const item=state.items.find(i=>i.id===id);
  if(!item?.processable){hint("Nguyên liệu này cần trạm khác.",true);return;}
  if(loaded && loaded!==id){
    const previous=models.get(loaded);if(previous){previous.group.scale.setScalar(1.25);previous.group.position.copy(previous.rest);}
  }
  if(loaded!==id){loaded=id;strokes=0;}
  const m=models.get(id);if(m)m.spawn=null;
  reflowPile();syncStationVisual();shadowDirty=true;choose(id);requestRender();
}
function work() {
  if(!loaded||pending||state.busy||strokes>=4||state.station==='shaker')return;
  const item=state.items.find(i=>i.id===loaded);if(!item?.processable)return;
  strokes++;pulseAt=performance.now();syncStationVisual();choose(selected);
  if(strokes===4)action('process',loaded);
  requestRender();
}
function drinkIcon(product) {
  const red=product.includes('strawberry'), lemon=product.includes('lemon');
  const c=red?'#ed7182':lemon?'#edcc52':'#f5a43a';
  return `<svg viewBox="0 0 80 60" aria-hidden="true"><ellipse cx="42" cy="54" rx="25" ry="4" fill="#c3955733"/><path d="M31 14h29l-4 36c-1 6-19 6-21 0z" fill="#fff9e5" stroke="#a87943" stroke-width="1.6"/><path d="M34 27h23l-3 22c-4 3-13 3-17 0z" fill="${c}"/><path d="m50 31 5-26h9" fill="none" stroke="#408574" stroke-width="3.5" stroke-linecap="round"/><ellipse cx="45" cy="15" rx="14" ry="3" fill="#fff8e8" stroke="#b89665"/><circle cx="20" cy="36" r="11" fill="${c}" stroke="#d49a36"/><path d="M18 24q6-8 13-4-4 7-13 4" fill="#509160"/><path d="M16 30q-4 3-3 6" fill="none" stroke="#fff4ba" stroke-width="2.3" stroke-linecap="round"/><circle cx="42" cy="36" r="1.3" fill="#684326"/><circle cx="50" cy="36" r="1.3" fill="#684326"/></svg>`;
}
function refresh() {
  const validLoaded=state.items.find(i=>i.id===loaded&&i.processable);
  if(!validLoaded){loaded=null;strokes=0;}
  else if(strokes===4&&!pending)strokes=0; // Retry a refused/no-op after Dart acknowledgment.
  let layoutChanged=false;
  const ids=new Set(state.items.map(i=>i.id));
  if(drag&&!drag.work&&!ids.has(drag.id))drag=null;
  for(const [id,m] of models) if(!ids.has(id)) {
    scene.remove(m.group);models.delete(id);layoutChanged=true;
  }
  for(const item of state.items) {
    let m=models.get(item.id);
    if(m&&m.kind!==item.kind){
      layoutChanged=true;
      scene.remove(m.group);const group=makeItem(item.kind);group.userData.itemId=item.id;
      group.position.copy(m.rest);scene.add(group);m.group=group;m.kind=item.kind;m.spawn=null;
    }
    if(!m){
      const group=makeItem(item.kind);group.userData.itemId=item.id;scene.add(group);
      const rest=newRest([...models.values()].filter(o=>o.id!==loaded));
      const tilt=(Math.random()-.5)*.24;
      group.position.copy(rest);group.position.y+=4+Math.random();
      layoutChanged=true;
      m={id:item.id,group,kind:item.kind,rest,tilt,spawn:{at:performance.now(),from:group.position.clone(),landing:rest.clone(),sign:tilt<0?-1:1}};
      models.set(item.id,m);
    }
  }
  if(layoutChanged){layoutPasses++;reflowPile();shadowDirty=true;frameCamera();}
  const nextOrders=JSON.stringify(state.orders);
  if(nextOrders!==orderSignature){
    orderSignature=nextOrders;
    el('orders').replaceChildren(...state.orders.map(o=>{
      const ticket=document.createElement('div');ticket.className='ticket';ticket.innerHTML=drinkIcon(o.product);return ticket;
    }));
  }
  syncStationVisual();choose(state.items.some(i=>i.id===selected)?selected:null);
  requestRender();
}
window.setBartenderState = (next) => {
  if (disposed) return;
  if (next.round !== state.round) {
    drag = null;
    loaded = null; strokes = 0;
    selected = null;
    for (const m of models.values()) {
      scene.remove(m.group);
    }
    models.clear();
  }
  const changed = next.station !== state.station;
  if(changed){loaded=null;strokes=0;}
  state = next;
  pending = false;
  clearTimeout(pendingTimer);
  if (changed || !stationModel) {
    if (stationModel) scene.remove(stationModel);
    stationModel = makeStation(state.station);
    scene.add(stationModel);
  }
  el("title").textContent = state.stationName || "Quầy pha chế";
  refresh();
};
window.setBartenderSensor = (value) => {
  sensorAvailable = !!value;
  choose(selected);
};
function requestRender() {
  if (!raf && active && !disposed && !document.hidden) raf = requestAnimationFrame(render);
}
function render(now) {
  raf = 0;
  if (disposed || !active || document.hidden) return;
  if (lastFrame && drag) {
    frames.push(Math.min(1e3, now - lastFrame));
    if (frames.length > 120) frames.shift();
  }
  lastFrame = now;
  let animating = false;
  for (const m of models.values()) {
    if (!m.spawn) continue;
    const t = (now-m.spawn.at)/1000;
    const landing=m.spawn.landing;
    if (t >= 1.25) {
      m.group.position.copy(landing); m.group.rotation.set(0,m.tilt*.5,m.tilt); m.spawn=null;
    } else {
      const falling=t<.45;
      const bounce=falling ? (m.spawn.from.y-landing.y)*(1-(t/.45)**2) : Math.abs(Math.sin((t-.45)*Math.PI/.4))*.65*Math.max(0,1-(t-.45)/.8);
      const roll=falling?0:Math.sin((t-.45)*Math.PI/.8)*.34;
      m.group.position.set(landing.x+roll*m.spawn.sign,landing.y+bounce,landing.z);
      m.group.rotation.z=m.tilt+roll*m.spawn.sign;
      m.group.rotation.x=roll*.65;
      animating=true;
    }
  }
  const pulse=(now-pulseAt)/420;
  if(pulse>=0&&pulse<1&&stationModel){
    const squash=Math.sin(pulse*Math.PI);
    if(stationModel.userData.head)stationModel.userData.head.position.y=1.16-squash*.24;
    else if(stationModel.userData.knife){
      stationModel.userData.knife.position.y=.3+.28*(1-squash);
      stationModel.userData.handle.position.y=.32+.28*(1-squash);
    }else stationModel.rotation.z=squash*.055;
    animating=true;
  }else if(stationModel){
    if(stationModel.userData.head)stationModel.userData.head.position.y=loaded?1.16:1.5;
    stationModel.rotation.z=0;
    if(stationModel.userData.knife){stationModel.userData.knife.position.y=.3;stationModel.userData.handle.position.y=.32;}
  }
  if(selectionRing){
    const m=models.get(selected);selectionRing.visible=!!m;
    if(m){selectionRing.position.set(m.group.position.x,m.group.position.y-.43,m.group.position.z);}
  }
  if(shadowDirty||animating||drag)updatePileShadows();
  renderer.render(scene, camera);
  renders++;
  if(state.preparationId!=null&&!animating&&!drag&&reportedPreparation!==state.preparationId){
    reportedPreparation=state.preparationId;
    const preparationId=state.preparationId,round=state.round;
    // Report after a submitted frame, not before shader compilation or first drops.
    requestAnimationFrame(()=>{if(!disposed&&state.preparationId===preparationId)tell('sceneReady',{preparationId,round});});
  }
  if (animating) requestRender();
}
function frameCamera() {
  if(!bounds)return;
  const aspect = bounds.width / Math.max(1, bounds.height);
  camera.lookAt(0,.8,0);camera.updateMatrixWorld(true);
  const points=[new T.Vector3(0,2.85,-1.5),new T.Vector3(0,.3,3.4)];
  for(const m of models.values())points.push(new T.Vector3(m.rest.x,m.rest.y+.6,m.rest.z));
  const vertical=points.map(p=>p.applyMatrix4(camera.matrixWorldInverse).y);
  const minY=Math.min(...vertical)-.15,maxY=Math.max(...vertical)+.2;
  const height=Math.max(12.8/Math.max(1.25,aspect),maxY-minY);
  const middle=(maxY+minY)/2;
  camera.left=-height*aspect/2;camera.right=height*aspect/2;
  camera.top=middle+height/2;camera.bottom=middle-height/2;
  camera.updateProjectionMatrix();
  const work=screenPoint(new T.Vector3(0,.8,-.15));
  el('work').style.left=`${work.x}px`;el('work').style.top=`${work.y}px`;
}
function resize() {
  bounds=canvas.getBoundingClientRect();
  frameCamera();
  const ratio=Math.min(devicePixelRatio||1,lowQuality?.8:1,Math.sqrt(1e6/Math.max(1,bounds.width*bounds.height)));
  if(bufferWidth!==bounds.width||bufferHeight!==bounds.height||bufferRatio!==ratio){
    const sizeChanged=bufferWidth!==bounds.width||bufferHeight!==bounds.height;
    if(bufferRatio!==ratio)renderer.setPixelRatio(ratio);
    if(sizeChanged)renderer.setSize(bounds.width,bounds.height,false);
    bufferWidth=bounds.width;bufferHeight=bounds.height;bufferRatio=ratio;bufferResizes++;
  }
  requestRender();
}
function point(e) {
  pointer.set((e.clientX - bounds.left) / bounds.width * 2 - 1, -(e.clientY - bounds.top) / bounds.height * 2 + 1);
  ray.setFromCamera(pointer, camera);
  return ray.ray.intersectPlane(plane, hit);
}
function under(e) {
  point(e);
  scene.updateMatrixWorld(true);
  const hits = ray.intersectObjects([...models.values()].map((m) => m.group), true);
  for (const h of hits) {
    let p = h.object;
    while (p && !p.userData.itemId) p = p.parent;
    if (p) return p.userData.itemId;
  }
  return null;
}
function stationPoint(){return screenPoint(new T.Vector3(0,1.3,-1.5));}
function onStation(e){
  const p=stationPoint();return Math.hypot(e.clientX-bounds.left-p.x,e.clientY-bounds.top-p.y)<Math.max(45,bounds.width*.07);
}

function down(e) {
  if (drag || pending || state.busy || e.button > 0) return;
  if (loaded && onStation(e)) {
    if (state.station === "cuttingBoard") {
      drag = { work: true, pointer: e.pointerId, x:e.clientX, y:e.clientY };
      canvas.setPointerCapture(e.pointerId);
    } else work();
    return;
  }
  const id = under(e);
  if (!id) {
    choose(null);
    return;
  }
  const p = point(e);
  if (!p) return;
  const m = models.get(id);
  m.spawn = null; m.group.rotation.set(0,0,0);
  drag = { id, pointer: e.pointerId, x: e.clientX, y: e.clientY, start: m.group.position.clone(), offset: m.group.position.clone().sub(p), lastX: e.clientX, lastAt: performance.now(), velocity: 0, moved: false };
  if(loaded===id){loaded=null;strokes=0;syncStationVisual();}
  m.group.scale.setScalar(1.25);reflowPile();shadowDirty=true;
  choose(id);
  canvas.setPointerCapture(e.pointerId);
  hint("↑ Nộp món · ↓ Bỏ đồ · ← → Chuyền");
}
function move(e) {
  if (!drag || drag.pointer !== e.pointerId) return;
  e.preventDefault();
  if (drag.work) return;
  const p = point(e), m = models.get(drag.id);
  if (!p || !m) return;
  const now = performance.now();
  if (now - drag.lastAt > 0) drag.velocity = (e.clientX - drag.lastX) / (now - drag.lastAt);
  drag.lastX = e.clientX;
  drag.lastAt = now;
  drag.moved || (drag.moved = Math.hypot(e.clientX - drag.x, e.clientY - drag.y) > 9);
  m.group.position.set(T.MathUtils.clamp(p.x + drag.offset.x, -5.3, 5.3), Math.max(1.25,drag.start.y+.3), T.MathUtils.clamp(p.z + drag.offset.z, -2.7, 2.8));
  el("left").classList.toggle("hot", e.clientX < bounds.left + bounds.width * 0.12);
  el("right").classList.toggle("hot", e.clientX > bounds.right - bounds.width * 0.12);
  requestRender();
}
function inRect(e, node) {
  const r = node.getBoundingClientRect();
  return e.clientX >= r.left && e.clientX <= r.right && e.clientY >= r.top && e.clientY <= r.bottom;
}
function up(e) {
  if (!drag || drag.pointer !== e.pointerId) return;
  if (drag.work) {
    const valid = e.type !== "pointercancel" && Math.abs(e.clientX-drag.x)>35;
    drag = null;
    try { canvas.releasePointerCapture(e.pointerId); } catch {}
    if (valid) work();
    return;
  }
  const current = drag;
  const m = models.get(current.id);
  if (e.type !== "pointercancel") move(e);
  drag = null;
  try {
    canvas.releasePointerCapture(e.pointerId);
  } catch {
  }
  el("left").classList.remove("hot");
  el("right").classList.remove("hot");
  if (m) {
    const p = m.group.position.clone();
    m.group.position.copy(current.start);
    if (e.type !== "pointercancel" && current.moved) {
      if (e.clientY > bounds.top + bounds.height * .86 && e.clientY-current.y > 45) action("trash", current.id);
      else if (e.clientY < bounds.top + bounds.height * .22 && current.y-e.clientY > 45) action("submit", current.id);
      else if (e.clientX < bounds.left + bounds.width * 0.1) action("left", current.id);
      else if (e.clientX > bounds.right - bounds.width * 0.1) action("right", current.id);
      else if (onStation(e)) loadStation(current.id);
      else if (Math.abs(e.clientX - current.x) > 65 && Math.abs(e.clientY - current.y) < 70 && Math.abs(current.velocity) > 0.55) action(e.clientX < current.x ? "left" : "right", current.id);
      else {
        m.rest.set(T.MathUtils.clamp(p.x,-4.65,4.65),.9,T.MathUtils.clamp(p.z,.05,2.55));
        reflowPile();m.group.position.copy(m.rest);
      }
    }
  }
  if(m&&(e.type==='pointercancel'||!current.moved)) {
    m.spawn={at:performance.now(),from:m.group.position.clone(),landing:m.rest.clone(),sign:m.tilt<0?-1:1};
  }
  reflowPile();syncStationVisual();shadowDirty=true;frameCamera();requestRender();
}
window.setBartenderActive = (value) => {
  active = !!value;
  lastFrame = 0;
  if (!active) {
    if (drag) {
      const m = models.get(drag.id);
      if (m) m.group.position.copy(drag.start);
      drag = null;
    }
    cancelAnimationFrame(raf);
    raf = 0;
  } else requestRender();
};
function screenPoint(position) {
  const p = position.clone().project(camera);
  return { x: (p.x + 1) * bounds.width / 2, y: (1 - p.y) * bounds.height / 2 };
}
window.bartenderSnapshot = () => ({ ready: !!renderer, items: [...models].map(([id, m]) => ({ id, kind: m.kind, position: m.group.position.toArray(), screen: screenPoint(m.group.position) })), station: stationPoint(), stationPhase: loaded ? (strokes ? 'pressing' : 'loaded') : 'empty', renders, raf, disposed, bufferResizes, shadowUpdates, layoutPasses, dragging: !!drag, pending, selected, loaded, strokes, spawning:[...models.values()].filter(m=>m.spawn).length, round: state.round, triangles: renderer?.info.render.triangles, drawCalls: renderer?.info.render.calls, resources: resources.size, pixelRatio: renderer?.getPixelRatio(), frameMs: frames.length ? frames.reduce((a, b) => a + b, 0) / frames.length : null });
window.disposeBartender = () => {
  if (disposed) return;
  disposed = true;
  cancelAnimationFrame(raf);
  clearTimeout(pendingTimer);
  clearTimeout(toastTimer);
  listeners.splice(0).forEach((fn) => fn());
  for (const resource of resources) resource.dispose();
  resources.clear();
  models.clear();
  itemShapes.clear();
  scene?.clear();
  renderer?.renderLists.dispose();
  renderer?.dispose();
  renderer?.forceContextLoss();
  canvas?.remove();
  host.remove();
  tell("disposed");
};
async function init() {
  try {
    scene = new T.Scene();
    scene.background = new T.Color(15389871);
    camera = new T.OrthographicCamera(-6, 6, 4, -4, 0.1, 70);
    camera.position.set(0, 7, 14);
    camera.lookAt(0, 0.8, 0);
    renderer = new T.WebGLRenderer({ antialias: false, powerPreference: "low-power", alpha: false, stencil: false });
    renderer.outputColorSpace = T.SRGBColorSpace;
    renderer.toneMapping = T.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.12;
    renderer.setClearColor(15389871);
    canvas = renderer.domElement;
    document.body.prepend(canvas);
    scene.add(new T.HemisphereLight(16774111, 10195580, 1.8));
    const light = new T.DirectionalLight(16772563, 1.6);
    light.position.set(-4, 8, 4);
    scene.add(light);
    environment();
    const ringMaterial=new T.MeshBasicMaterial({color:0xffef9f,transparent:true,opacity:.88,depthWrite:false});resources.add(ringMaterial);
    selectionRing=new T.Mesh(geo('selection',()=>new T.RingGeometry(.52,.56,40)),ringMaterial);
    selectionRing.rotation.x=-Math.PI/2;selectionRing.visible=false;scene.add(selectionRing);
    stationModel = makeStation(null);
    scene.add(stationModel);
    listen(canvas, "pointerdown", down);
    listen(canvas, "pointermove", move, { passive: false });
    listen(canvas, "pointerup", up);
    listen(canvas, "pointercancel", up);
    listen(window, "resize", resize);
    listen(document, "visibilitychange", () => window.setBartenderActive(!document.hidden));
    listen(window, "pagehide", window.disposeBartender);
    listen(canvas, "webglcontextlost", (e) => {
      e.preventDefault();
      if (!disposed) tell("error", { message: "WebGL context lost" });
    });
    listen(el("passL"), "click", () => action("left"));
    listen(el("passR"), "click", () => action("right"));
    listen(el("process"), "click", () => action("process"));
    listen(el("trash"), "click", () => action("trash"));
    listen(el("serve"), "click", () => action("submit"));
    listen(el("quality"), "click", () => {
      lowQuality = !lowQuality;
      el("quality").textContent = lowQuality ? "◇" : "◈";
      resize();
    });
    resize();
    const warm=new T.Group();warm.position.y=-100;
    for(const kind of ['orange','lemon','strawberry','cut_strawberry','milk','ice','sugar','orange_juice','lemon_juice','strawberry_smoothie','citrus_cocktail','strawberry_lemonade_blend','strawberry_lemonade'])warm.add(makeItem(kind));
    for(const station of ['juicer','blender','cuttingBoard','shaker'])warm.add(makeStation(station));
    warm.traverse(o=>{if(o.isMesh)o.frustumCulled=false;});scene.add(warm);
    await renderer.compileAsync(scene,camera);
    if(disposed)return;
    renderer.render(scene,camera);scene.remove(warm);
    choose(null);
    requestRender();
    tell("ready");
  } catch (error) {
    tell("error", { message: String(error) });
  }
}
init();
