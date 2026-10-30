import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import * as THREE from 'three';
import { createCube, beginTurn, finishTurn, cubeSnapshot, chooseTurn, pickCube } from '../assets/rubik/interactive-cube.mjs';
import { rotateView } from '../assets/rubik/interactive-view.mjs';

function verify(cube) {
  assert.equal(cube.cubies.length, 27);
  assert.equal(new Set(cube.cubies.map(c => c.position.toArray().join(','))).size, 27);
  const counts = [0,0,0,0,0,0];
  for (const cubie of cube.cubies) {
    assert.equal(cubie.parent, cube.root);
    for (const coordinate of cubie.position.toArray()) assert.ok([-1,0,1].includes(coordinate));
    const rotation = new THREE.Matrix4().makeRotationFromQuaternion(cubie.quaternion);
    for (const i of [0,1,2,4,5,6,8,9,10]) assert.ok(Math.abs(rotation.elements[i] - Math.round(rotation.elements[i])) < 1e-12);
    assert.ok(Math.abs(rotation.determinant() - 1) < 1e-12);
    for (const tile of cubie.children.slice(1)) {
      counts[tile.userData.color]++;
      assert.equal(tile.userData.cubie, cubie);
    }
  }
  assert.deepEqual(counts, [9,9,9,9,9,9]);
}

for (const axis of ['x','y','z']) for (const layer of [-1,0,1]) {
  test(`four ${axis}/${layer} turns and inverse retain cubies/stickers`, () => {
    const cube = createCube(), original = cubeSnapshot(cube.cubies);
    for (let i=0;i<4;i++) { finishTurn(beginTurn(cube.root,cube.cubies,axis,layer,1)); verify(cube); }
    assert.deepEqual(cubeSnapshot(cube.cubies), original);
    finishTurn(beginTurn(cube.root,cube.cubies,axis,layer,-1));
    finishTurn(beginTurn(cube.root,cube.cubies,axis,layer,1));
    assert.deepEqual(cubeSnapshot(cube.cubies), original);
    cube.dispose();
  });
}

test('100 mixed moves and their reverse have no drift or sticker loss', () => {
  const cube = createCube(), original = cubeSnapshot(cube.cubies), history = [];
  for (let i=0;i<100;i++) {
    const move = {axis:['x','y','z'][i%3],layer:((i*7+Math.floor(i/3))%3)-1,sign:i%2?1:-1};
    history.push(move); finishTurn(beginTurn(cube.root,cube.cubies,move.axis,move.layer,move.sign)); verify(cube);
  }
  assert.notDeepEqual(cubeSnapshot(cube.cubies),original);
  for (const move of history.reverse()) finishTurn(beginTurn(cube.root,cube.cubies,move.axis,move.layer,-move.sign));
  assert.deepEqual(cubeSnapshot(cube.cubies),original); cube.dispose();
});

test('raycast/swipe chooses all axes from both sides and orbited viewpoints', () => {
  const cube = createCube(); cube.root.updateMatrixWorld(true);
  const camera = new THREE.PerspectiveCamera(40,.6,.1,100), ray = new THREE.Raycaster();
  for (const normalAxis of [0,1,2]) for (const faceSign of [-1,1]) for (const orbitOffset of [0,.4,-.4]) {
    const normal = new THREE.Vector3().setComponent(normalAxis,faceSign);
    camera.position.copy(normal.clone().multiplyScalar(10));
    camera.position.setComponent((normalAxis+1)%3,orbitOffset*5);
    camera.up.set(0,1,0);
    if (normalAxis===1) camera.up.set(0,0,-faceSign);
    camera.lookAt(0,0,0); camera.updateMatrixWorld(true);
    ray.setFromCamera(new THREE.Vector2(0,0),camera);
    const hit = pickCube(ray,cube.cubies); assert.ok(hit); assert.ok(hit.normal.equals(normal));
    for (const axis of [0,1,2].filter(i=>i!==normalAxis)) {
      const tangent = new THREE.Vector3().crossVectors(new THREE.Vector3().setComponent(axis,1),normal);
      const start = hit.point.clone().project(camera), end = hit.point.clone().add(tangent).project(camera);
      const dx=(end.x-start.x)*360/2, dy=-(end.y-start.y)*600/2;
      for (const direction of [-1,1]) {
        const move = chooseTurn(hit,dx*direction,dy*direction,camera,360,600);
        assert.ok(move); assert.equal(move.axis,['x','y','z'][axis]); assert.equal(move.sign,direction);
      }
    }
    assert.equal(chooseTurn(hit,3,2,camera,360,600),null);
  }
  cube.dispose();
});

test('a narrow seam selects a cubie, but a drag outside the cube stays outside', () => {
  const cube = createCube(); cube.root.updateMatrixWorld(true);
  const ray = new THREE.Raycaster(new THREE.Vector3(.5,0,10), new THREE.Vector3(0,0,-1));
  const seam = pickCube(ray,cube.cubies);
  assert.ok(seam); assert.deepEqual(seam.cubie.position.toArray(),[1,0,1]);
  assert.ok(seam.normal.equals(new THREE.Vector3(0,0,1)));
  ray.ray.origin.x=2; assert.equal(pickCube(ray,cube.cubies),null);
  cube.dispose();
});

function harness() {
  function events() {
    const handlers = new Map();
    return { handlers,
      addEventListener(type,handler) { if(!handlers.has(type))handlers.set(type,new Set());handlers.get(type).add(handler); },
      removeEventListener(type,handler) { handlers.get(type)?.delete(handler); },
      fire(type,event={}) { const e={type,preventDefault(){},stopImmediatePropagation(){},...event}; for(const h of handlers.get(type)??[])h(e); },
    };
  }
  const canvas={...events(),setPointerCapture(){},releasePointerCapture(){},remove(){},
    getBoundingClientRect(){return {left:0,top:0,width:360,height:720};}};
  const window={...events()}, document={...events(),hidden:false,body:{appendChild(){}}};
  const frames=new Map(); let next=0,time=0,disposed=0;
  class Controls extends THREE.EventDispatcher { constructor(camera){super();this.camera=camera;this.target=new THREE.Vector3();this.enabled=true;}update(){this.camera.lookAt(this.target);this.camera.updateMatrixWorld();}dispose(){disposed++;} }
  const context=vm.createContext({THREE:{...THREE,WebGLRenderer:class {
    domElement=canvas;renderLists={dispose(){}};setPixelRatio(){}setSize(){}render(){}dispose(){disposed++;}forceContextLoss(){disposed++;}
  }},OrbitControls:Controls,createCube,pickCube,chooseTurn,beginTurn,finishTurn,cubeSnapshot,rotateView,
    window,document,innerWidth:360,innerHeight:720,devicePixelRatio:2,
    requestAnimationFrame(cb){frames.set(++next,cb);return next;},cancelAnimationFrame(id){frames.delete(id);}});
  const source=fs.readFileSync('assets/rubik/interactive-src.js','utf8').replace(/^import .*;\r?\n/gm,'');
  vm.runInContext(source,context);
  window.restoreRubikToy(null);
  function frame(){time+=16.7;const batch=[...frames.values()];frames.clear();batch.forEach(cb=>cb(time));}
  return {canvas,window,document,frames,frame,
    settle(){for(let i=0;i<100&&frames.size;i++)frame();assert.equal(frames.size,0);},
    snapshot(){return window.rubikToySnapshot();},get disposed(){return disposed;}};
}

test('one finger orbits in view mode without turning a layer',()=>{
  const h=harness();h.settle();h.window.setRubikOneFingerOrbit(true);
  const before=h.snapshot(),finger={pointerId:1,clientX:180,clientY:350};
  h.canvas.fire('pointerdown',finger);
  h.canvas.fire('pointermove',{...finger,clientX:240,clientY:390});
  h.canvas.fire('pointerup',{...finger,clientX:240,clientY:390});h.settle();
  const after=h.snapshot();assert.notDeepEqual(after.camera,before.camera);
  assert.deepEqual(after.cube,before.cube);assert.equal(after.moves,before.moves);
  h.window.setRubikOneFingerOrbit(false);assert.equal(h.snapshot().oneFingerOrbit,false);
  h.window.disposeRubikToy();
});

test('two fingers orbit through the poles without moving any stickers or zooming',()=>{
  const h=harness();h.settle();const before=h.snapshot();
  const a={pointerId:1,clientX:160,clientY:340},b={pointerId:2,clientX:200,clientY:380};
  h.canvas.fire('pointerdown',a);h.canvas.fire('pointerdown',b);
  for(let i=1;i<=20;i++){
    h.canvas.fire('pointermove',{...a,clientX:a.clientX+i*8,clientY:a.clientY+i*20});
    h.canvas.fire('pointermove',{...b,clientX:b.clientX+i*8,clientY:b.clientY+i*20});
    h.frame();
  }
  h.canvas.fire('pointerup',b);
  h.canvas.fire('pointermove',{...a,clientX:300,clientY:600});
  h.canvas.fire('pointerup',a);h.settle();
  const after=h.snapshot();
  assert.deepEqual(after.cube,before.cube);assert.equal(after.moves,0);
  assert.equal(after.zoom,before.zoom);assert.notDeepEqual(after.camera,before.camera);
  h.frame();assert.deepEqual(h.snapshot().camera,after.camera);h.window.disposeRubikToy();
});

test('pointer ownership, tap/cancel, one turn per swipe, then idle and dispose', () => {
  const h=harness();h.settle();
  const pointer={pointerId:1,clientX:180,clientY:360};
  h.canvas.fire('pointerdown',pointer);h.canvas.fire('pointermove',{...pointer,clientX:186});
  h.canvas.fire('pointercancel',pointer);h.settle();assert.equal(h.snapshot().moves,0);
  h.canvas.fire('pointerdown',pointer);
  for(let i=0;i<10;i++)h.canvas.fire('pointermove',{...pointer,clientX:180+30+i*4});
  h.canvas.fire('pointerup',pointer);h.settle();assert.equal(h.snapshot().moves,1);
  assert.equal(h.snapshot().gesture,null);assert.equal(h.snapshot().busy,false);
  const renders=h.snapshot().renders;h.frame();assert.equal(h.snapshot().renders,renders);
  h.canvas.fire('pointerdown',{...pointer,clientX:5});
  assert.equal(h.snapshot().gesture,null);h.canvas.fire('pointermove',{...pointer,clientX:70});
  h.canvas.fire('pointerup',{...pointer,clientX:70});assert.equal(h.snapshot().moves,1);
  h.window.disposeRubikToy();h.window.disposeRubikToy();
  assert.equal(h.frames.size,0);assert.equal(h.disposed,2);
  assert.ok([...h.canvas.handlers.values()].every(list=>list.size===0));
});

test('pause while animating snaps atomically and resume has no pending gesture',()=>{
  const h=harness();h.settle();const pointer={pointerId:1,clientX:180,clientY:360};
  h.canvas.fire('pointerdown',pointer);h.canvas.fire('pointermove',{...pointer,clientY:420});
  h.canvas.fire('pointerup',{...pointer,clientY:420});
  h.frame();h.window.setRubikToyActive(false);assert.equal(h.frames.size,0);
  assert.equal(h.snapshot().moves,1);assert.equal(h.snapshot().busy,false);assert.equal(h.snapshot().gesture,null);
  h.window.setRubikToyActive(true);h.settle();assert.equal(h.snapshot().moves,1);h.window.disposeRubikToy();
});

test('camera-relative yaw/pitch and twist allow 45, 90, 180 degrees with no snap', () => {
  const camera = new THREE.PerspectiveCamera(40, .6, .1, 100);
  camera.position.set(0, 0, 12); camera.lookAt(0, 0, 0); camera.updateMatrixWorld(true);
  const pair = angle => [{x:180-80*Math.cos(angle),y:360-80*Math.sin(angle)},
    {x:180+80*Math.cos(angle),y:360+80*Math.sin(angle)}];
  for (const [from, to] of [[0,Math.PI/4],[Math.PI/4,Math.PI/2],[Math.PI/2,Math.PI]]) {
    rotateView(camera, pair(from), pair(to));
    const expected = new THREE.Vector3(-Math.sin(to),Math.cos(to),0);
    assert.ok(camera.up.distanceTo(expected) < 1e-10);
    assert.ok(camera.position.distanceTo(new THREE.Vector3(0,0,12)) < 1e-10);
  }
  rotateView(camera, pair(Math.PI), pair(0));
  assert.ok(camera.up.distanceTo(new THREE.Vector3(0,1,0)) < 1e-10);
  for (let i=0; i<100; i++) {
    const before = pair(i*.07), after = pair((i+1)*.07).map(p=>({x:p.x+12,y:p.y-9}));
    rotateView(camera,before,after);
    assert.ok(Math.abs(camera.position.length()-12)<1e-10);
    assert.ok(Math.abs(camera.up.dot(camera.position))<1e-10);
    assert.ok(Math.abs(camera.quaternion.length()-1)<1e-10);
  }
});

test('swipe velocity follows the finger after arbitrary yaw, pitch and inverted roll', () => {
  const cube = createCube();cube.root.updateMatrixWorld(true);
  const camera = new THREE.PerspectiveCamera(40,.6,.1,100), ray = new THREE.Raycaster();
  let cases=0;
  for (const yaw of [0,.8,Math.PI]) for (const pitch of [0,.7,Math.PI])
    for (const roll of [0,Math.PI/4,Math.PI/2,Math.PI]) {
      const q = new THREE.Quaternion().setFromEuler(new THREE.Euler(pitch,yaw,roll));
      camera.position.set(0,0,12).applyQuaternion(q);
      camera.up.set(0,1,0).applyQuaternion(q);camera.lookAt(0,0,0);camera.updateMatrixWorld(true);
      for(const x of [-.18,0,.18]) for(const y of [-.18,0,.18]) {
        ray.setFromCamera(new THREE.Vector2(x,y),camera);const hit=pickCube(ray,cube.cubies);
        if(!hit)continue;
        for(const [dx,dy] of [[50,0],[-50,0],[0,50],[0,-50]]) {
          const spec=chooseTurn(hit,dx,dy,camera,360,600);if(!spec)continue;
          const axis = new THREE.Vector3().setComponent(['x','y','z'].indexOf(spec.axis),1);
          const start=hit.point.clone().project(camera);
          const end=hit.point.clone().applyAxisAngle(axis,spec.sign*.001).project(camera);
          const vx=(end.x-start.x)*180,vy=-(end.y-start.y)*300;
          assert.ok((vx*dx+vy*dy)/(Math.hypot(vx,vy)*50)>.59);
          cases++;
        }
      }
    }
  assert.ok(cases>500);cube.dispose();
});

test('second finger cancels a pending layer; remaining finger stays blocked until all lift', () => {
  const h=harness();h.settle();const initial=h.snapshot();
  const a={pointerId:1,clientX:180,clientY:360},b={pointerId:2,clientX:240,clientY:360};
  for(let i=0;i<10;i++) {
    h.canvas.fire('pointerdown',a);h.canvas.fire('pointermove',{...a,clientX:220});
    h.frame();assert.equal(h.snapshot().moves,0);assert.equal(h.snapshot().busy,false);
    h.canvas.fire('pointerdown',b);
    h.canvas.fire('pointermove',{...b,clientY:410});h.canvas.fire('pointerup',b);
    h.canvas.fire('pointermove',{...a,clientY:460});h.canvas.fire('pointerup',a);h.settle();
    assert.deepEqual(h.snapshot().cube,initial.cube);assert.equal(h.snapshot().moves,0);
  }
  h.canvas.fire('pointerdown',a);h.canvas.fire('pointermove',{...a,clientY:430});
  h.canvas.fire('pointercancel',a);h.settle();assert.equal(h.snapshot().moves,0);
  h.window.disposeRubikToy();
});

test('separately delivered touch updates produce a pure roll from the initially tilted view', () => {
  const h=harness();h.settle();const initial=h.snapshot();
  const camera=new THREE.PerspectiveCamera();
  camera.position.fromArray(initial.camera);camera.up.fromArray(initial.up);camera.lookAt(0,0,0);
  const initialUp=new THREE.Vector3(0,1,0).applyQuaternion(camera.quaternion);
  const a={pointerId:1,clientX:100,clientY:360},b={pointerId:2,clientX:260,clientY:360};
  h.canvas.fire('pointerdown',a);h.canvas.fire('pointerdown',b);
  for(let step=1;step<=36;step++){
    const angle=Math.PI*step/36,dx=80*Math.cos(angle),dy=80*Math.sin(angle);
    h.canvas.fire('pointermove',{...a,clientX:180-dx,clientY:360-dy});h.frame();
    h.canvas.fire('pointermove',{...b,clientX:180+dx,clientY:360+dy});h.frame();
  }
  h.canvas.fire('pointerup',a);h.canvas.fire('pointerup',b);h.settle();
  const after=h.snapshot();
  assert.ok(new THREE.Vector3(...after.camera).distanceTo(new THREE.Vector3(...initial.camera))<1e-10);
  assert.ok(new THREE.Vector3(...after.up).distanceTo(initialUp.negate())<1e-10);
  assert.deepEqual(after.cube,initial.cube);assert.equal(after.moves,initial.moves);
  h.window.disposeRubikToy();
});

test('undo reverses successive swipes; reset restores solved cube and camera', () => {
  const h = harness(); h.settle();
  const original = h.snapshot();
  const pointer = { pointerId: 1, clientX: 180, clientY: 360 };
  const snapshots = [original.cube];
  assert.equal(h.window.undoRubikToy(), false);
  for (const delta of [{clientX:240}, {clientY:420}, {clientX:120}]) {
    h.canvas.fire('pointerdown', pointer);
    assert.equal(h.window.resetRubikToy(), false);
    h.canvas.fire('pointermove', {...pointer, ...delta});
    assert.equal(h.window.undoRubikToy(), false);
    h.canvas.fire('pointerup', pointer); h.settle();
    snapshots.push(h.snapshot().cube);
  }
  assert.equal(h.snapshot().historyDepth, 3);
  for (let i = 2; i >= 0; i--) {
    assert.equal(h.window.undoRubikToy(), true);
    assert.equal(h.window.undoRubikToy(), false);
    assert.equal(h.window.resetRubikToy(), false);
    h.settle();
    assert.deepEqual(h.snapshot().cube, snapshots[i]);
    assert.equal(h.snapshot().historyDepth, i);
    assert.deepEqual(h.snapshot().camera, original.camera);
  }
  assert.equal(h.window.undoRubikToy(), false);
  h.canvas.fire('pointerdown', pointer);
  h.canvas.fire('pointermove', {...pointer, clientY:420});
  h.canvas.fire('pointerup', pointer); h.settle();
  assert.equal(h.window.resetRubikToy(), true); h.settle();
  assert.deepEqual(h.snapshot().cube, original.cube);
  assert.deepEqual(h.snapshot().camera, original.camera);
  assert.equal(h.snapshot().historyDepth, 0);
  assert.equal(h.snapshot().moves, 0);
  assert.equal(h.window.undoRubikToy(), false);
  h.window.disposeRubikToy();
});
