import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import * as THREE from 'three';
import { createCube, beginTurn, finishTurn, cubeSnapshot, chooseTurn, pickCube } from '../assets/rubik/interactive-cube.mjs';

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
      fire(type,event={}) { const e={preventDefault(){},stopImmediatePropagation(){},...event}; for(const h of handlers.get(type)??[])h(e); },
    };
  }
  const canvas={...events(),setPointerCapture(){},releasePointerCapture(){},remove(){},
    getBoundingClientRect(){return {left:0,top:0,width:360,height:720};}};
  const window={...events()}, document={...events(),hidden:false,body:{appendChild(){}}};
  const frames=new Map(); let next=0,time=0,disposed=0;
  class Controls extends THREE.EventDispatcher { constructor(camera){super();this.camera=camera;this.target=new THREE.Vector3();this.enabled=true;}update(){this.camera.lookAt(this.target);this.camera.updateMatrixWorld();}dispose(){disposed++;} }
  const context=vm.createContext({THREE:{...THREE,WebGLRenderer:class {
    domElement=canvas;renderLists={dispose(){}};setPixelRatio(){}setSize(){}render(){}dispose(){disposed++;}forceContextLoss(){disposed++;}
  }},OrbitControls:Controls,createCube,pickCube,chooseTurn,beginTurn,finishTurn,cubeSnapshot,
    window,document,innerWidth:360,innerHeight:720,devicePixelRatio:2,
    requestAnimationFrame(cb){frames.set(++next,cb);return next;},cancelAnimationFrame(id){frames.delete(id);}});
  const source=fs.readFileSync('assets/rubik/interactive-src.js','utf8').replace(/^import .*;\r?\n/gm,'');
  vm.runInContext(source,context);
  function frame(){time+=16.7;const batch=[...frames.values()];frames.clear();batch.forEach(cb=>cb(time));}
  return {canvas,window,document,frames,frame,
    settle(){for(let i=0;i<100&&frames.size;i++)frame();assert.equal(frames.size,0);},
    snapshot(){return window.rubikToySnapshot();},get disposed(){return disposed;}};
}

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
  assert.equal(h.snapshot().gesture,'orbit');h.canvas.fire('pointerup',{...pointer,clientX:5});
  h.window.disposeRubikToy();h.window.disposeRubikToy();
  assert.equal(h.frames.size,0);assert.equal(h.disposed,3);
  assert.ok([...h.canvas.handlers.values()].every(list=>list.size===0));
});

test('pause while animating snaps atomically and resume has no pending gesture',()=>{
  const h=harness();h.settle();const pointer={pointerId:1,clientX:180,clientY:360};
  h.canvas.fire('pointerdown',pointer);h.canvas.fire('pointermove',{...pointer,clientY:420});
  h.frame();h.window.setRubikToyActive(false);assert.equal(h.frames.size,0);
  assert.equal(h.snapshot().moves,1);assert.equal(h.snapshot().busy,false);assert.equal(h.snapshot().gesture,null);
  h.window.setRubikToyActive(true);h.settle();assert.equal(h.snapshot().moves,1);h.window.disposeRubikToy();
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
