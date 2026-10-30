const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const three = require('three');

// Exercise the production gesture/scheduler code without requiring a GPU.
function harness() {
  const events = () => ({
    handlers: {},
    addEventListener(name, handler) { this.handlers[name] = handler; },
    fire(name, event = {}) { this.handlers[name]?.({ preventDefault() {}, ...event }); },
  });
  const canvas = { ...events(), style: {}, setPointerCapture() {}, releasePointerCapture() {} };
  const window = { ...events(), innerWidth: 360, innerHeight: 720 };
  const document = { ...events(), hidden: false, body: { style: {}, appendChild() {} } };
  const frames = new Map();
  let nextId = 0;
  let time = 0;
  let renders = 0;
  const context = vm.createContext({
    THREE: { ...three, WebGLRenderer: class {
      domElement = canvas;
      setPixelRatio() {}
      setSize() {}
      render() { renders++; }
    } },
    window, document,
    requestAnimationFrame(callback) { frames.set(++nextId, callback); return nextId; },
    cancelAnimationFrame(id) { frames.delete(id); },
  });
  const source = fs.readFileSync('assets/rubik/rubik-src.js', 'utf8')
    .replace("import * as THREE from 'three';", '');
  vm.runInContext(source, context);
  return {
    canvas, window, document, frames,
    get renders() { return renders; },
    read(expression) { return vm.runInContext(expression, context); },
    frame() {
      time += 16.7;
      const callbacks = [...frames.values()];
      frames.clear();
      callbacks.forEach(callback => callback(time));
    },
  };
}

test('stationary drag is idle; drag follows next display frame', () => {
  const h = harness();
  h.frame();
  assert.equal(h.frames.size, 0);
  h.canvas.fire('pointerdown', { pointerType: 'mouse', pointerId: 1, clientX: 0, clientY: 0 });
  h.frame();
  assert.equal(h.frames.size, 0);
  for (let i = 1; i <= 100; i++) {
    h.canvas.fire('pointermove', { pointerType: 'mouse', clientX: i, clientY: i });
    h.frame();
    assert.equal(h.read('rotationY'), h.read('targetRotationY'));
    assert.equal(h.frames.size, 0);
  }
  assert.equal(h.renders, 102);
});

test('pinch held still is idle; wheel converges; lifecycle cancels frames', () => {
  const h = harness();
  const touch = (identifier, x) => ({ identifier, clientX: x, clientY: 10 });
  h.canvas.fire('touchstart', { changedTouches: [touch(1, 10), touch(2, 100)] });
  h.frame();
  assert.equal(h.frames.size, 0);
  const oldZoom = h.read('zoom');
  h.canvas.fire('touchmove', { changedTouches: [touch(2, 130)] });
  h.frame();
  assert.ok(h.read('zoom') < oldZoom);
  assert.equal(h.frames.size, 0);
  h.canvas.fire('wheel', { deltaY: 100 });
  for (let i = 0; i < 100 && h.frames.size; i++) h.frame();
  assert.equal(h.frames.size, 0);
  h.canvas.fire('wheel', { deltaY: 100 });
  h.window.setRubikActive(false);
  assert.equal(h.frames.size, 0);
  h.window.setRubikActive(true);
  assert.equal(h.frames.size, 1);
});

test('resize fits the narrow dimension and preserves relative zoom', () => {
  const h = harness();
  h.frame();
  const portraitDistance = h.read('zoom');
  h.window.innerWidth = 720;
  h.window.innerHeight = 360;
  h.window.fire('resize');
  h.frame();
  assert.ok(h.read('zoom') < portraitDistance);
  assert.equal(h.read('zoom / baseZoom'), 1);
});

test('54 unique targets agree with cuber corner/edge net, including B and D', () => {
  const h = harness();
  const position = (facelet) => {
    const index = 'URFDLB'.indexOf(facelet[0]) * 9 + Number(facelet.slice(1)) - 1;
    return h.read(`stickerTargets[${index}].cubie.position.toArray().join(',')`);
  };
  const corners = [
    ['U9','R1','F3'], ['U7','F1','L3'], ['U1','L1','B3'], ['U3','B1','R3'],
    ['D3','F9','R7'], ['D1','L9','F7'], ['D7','B9','L7'], ['D9','R9','B7'],
  ];
  const edges = [
    ['U6','R2'], ['U8','F2'], ['U4','L2'], ['U2','B2'],
    ['D6','R8'], ['D2','F8'], ['D4','L8'], ['D8','B8'],
    ['F6','R4'], ['F4','L6'], ['B6','L4'], ['B4','R6'],
  ];
  for (const group of [...corners, ...edges]) {
    assert.equal(new Set(group.map(position)).size, 1, group.join('-'));
  }
  assert.equal(position('U1'), '-1,1,-1');
  assert.equal(position('F1'), '-1,1,1');
  assert.equal(position('D1'), '-1,-1,1');
  assert.equal(position('B1'), '1,1,-1');
  assert.equal(h.read('new Set(stickerTargets.map(t => t.cubie.id + ":" + t.material)).size'), 54);
});

test('partial cube, single sticker, reset: reuse scene and render only on changes', () => {
  const h = harness();
  const empty = [...'URFDLB'].map(f => '????' + f + '????').join('');
  h.window.setCubeState(empty);
  h.frame();
  assert.equal(h.read('stickerTargets.filter(t => t.cubie.material[t.material] === unknown).length'), 48);
  const ids = h.read('rubik.children.map(c => c.id).join()');
  for (let index = 0; index < 54; index++) {
    const next = [...empty];
    next[index] = 'R';
    const before = h.renders;
    h.window.setCubeState(next.join(''));
    assert.ok(h.frames.size <= 1);
    h.frame();
    assert.equal(h.read(`stickerTargets[${index}].cubie.material[stickerTargets[${index}].material] === red`), true);
    assert.equal(h.frames.size, 0);
    assert.ok(h.renders <= before + 1);
    h.window.setCubeState(next.join(''));
    assert.equal(h.frames.size, 0);
    h.window.setCubeState(empty);
    h.frame();
  }
  assert.equal(h.read('rubik.children.map(c => c.id).join()'), ids);
  assert.equal(h.window.setCubeState('bad input'), false);
  assert.equal(h.frames.size, 0);
});
