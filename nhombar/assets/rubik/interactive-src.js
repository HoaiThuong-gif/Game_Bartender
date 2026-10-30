import * as THREE from 'three';
import { createCube, pickCube, chooseTurn, beginTurn, finishTurn, cubeSnapshot, applyNotation, isCubeSolved } from './interactive-cube.mjs';
import { rotateView } from './interactive-view.mjs';

const scene = new THREE.Scene(); scene.background = new THREE.Color(0xdceffc);
const camera = new THREE.PerspectiveCamera(40, innerWidth / innerHeight, .1, 100);
const renderer = new THREE.WebGLRenderer({ antialias: false, powerPreference: 'low-power' });
renderer.setPixelRatio(Math.min(devicePixelRatio || 1, 1.25));
renderer.setSize(innerWidth, innerHeight);
const canvas = renderer.domElement; document.body.appendChild(canvas);
const cube = createCube(); scene.add(cube.root);
scene.add(new THREE.HemisphereLight(0xffffff, 0x444444, 2));
const light = new THREE.DirectionalLight(0xffffff, 1); light.position.set(3, 5, 4); scene.add(light);
// Rotate the camera frame without spherical pole limits; puzzle coordinates stay fixed.
const viewTarget = new THREE.Vector3();
let fitDistance = 1, zoomRatio = 1;
const pointers = new Map();
let multiTouch = false;
let viewGesture = null;
const raycaster = new THREE.Raycaster();
let active = true, disposed = false, raf = 0, dirty = true, gesture = null, animation = null;
let moves = 0, renders = 0, orbits = 0, lastMove = null;
let interaction = false, challenge = false;
let oneFingerOrbit = false;
window.setRubikOneFingerOrbit = value => {
  oneFingerOrbit = !!value && !challenge;
  gesture = null; pointers.clear(); multiTouch = false; viewGesture = null;
};
const history = [];
const report = type => window.RubikToy?.postMessage(JSON.stringify({ type, moves,
  busy: !!animation, historyDepth: history.length, solved: isCubeSolved(cube) }));
const duration = 240;
function saveSession() {
  if (challenge || !interaction || disposed || animation) return;
  window.RubikToy?.postMessage(JSON.stringify({ type: 'save', session: {
    version: 1, history, cube: cubeSnapshot(cube.cubies),
    view: { position: camera.position.toArray(), up: camera.up.toArray(), zoom: zoomRatio }
  } }));
}
function resetCube() {
  for (const cubie of cube.cubies) {
    cubie.position.fromArray(cubie.userData.id.split(',').map(Number));
    cubie.quaternion.identity(); cubie.updateMatrix();
  }
  cube.root.updateMatrixWorld(true);
}
function settle() {
  gesture = null; pointers.clear(); multiTouch = false;
  if (animation) commitTurn();
}
window.restoreRubikToy = session => {
  let valid = true;
  try {
    if (session !== null) {
      if (session.version !== 1 || !Array.isArray(session.history) || session.history.length > 100000 ||
          !session.history.every(m => m && ['x','y','z'].includes(m.axis) && [-1,0,1].includes(m.layer) && [-1,1].includes(m.sign))) throw Error('Invalid history');
      const v = session.view;
      if (!v || ![v.position, v.up].every(a => Array.isArray(a) && a.length === 3 && a.every(Number.isFinite)) ||
          !Number.isFinite(v.zoom) || v.zoom < .8 || v.zoom > 1.8 ||
          new THREE.Vector3(...v.position).length() < .1 || Math.abs(new THREE.Vector3(...v.up).length() - 1) > .001 ||
          new THREE.Vector3(...v.position).cross(new THREE.Vector3(...v.up)).length() < .01) throw Error('Invalid view');
      resetCube();
      for (const m of session.history) finishTurn(beginTurn(cube.root, cube.cubies, m.axis, m.layer, m.sign));
      if (JSON.stringify(cubeSnapshot(cube.cubies)) !== JSON.stringify(session.cube)) throw Error('Invalid cube');
      for (const move of session.history) history.push(move);
      moves = history.length;
      camera.position.fromArray(v.position); camera.up.fromArray(v.up); zoomRatio = v.zoom; fit();
    }
  } catch (_) {
    valid = false; resetCube(); history.length = 0; moves = 0;
    camera.position.set(0,0,0); camera.up.set(0,1,0); zoomRatio = 1; fit();
  }
  interaction = true;
  report(valid ? 'restored' : 'invalidSession'); saveSession();
};
window.rubikToyNeedsScrambleConfirmation = () => !!animation || !isCubeSolved(cube);
window.scrambleRubikToy = () => {
  if (challenge || !active || disposed || !interaction) return false;
  settle();
  let previousAxis = null;
  for (let i = 0; i < 25; i++) {
    const available = ['x','y','z'].filter(axis => axis !== previousAxis);
    const spec = { axis: available[Math.floor(Math.random() * available.length)],
      layer: Math.random() < .5 ? -1 : 1, sign: Math.random() < .5 ? -1 : 1 };
    finishTurn(beginTurn(cube.root, cube.cubies, spec.axis, spec.layer, spec.sign));
    history.push(spec); moves++; previousAxis = spec.axis; lastMove = spec;
  }
  report('scramble'); saveSession(); requestRender(); return true;
};

function startTurn(spec, undo = false) {
  animation = { turn: beginTurn(cube.root, cube.cubies, spec.axis, spec.layer, spec.sign), spec, undo, start: null };
  report('state'); requestRender();
}

function commitTurn() {
  finishTurn(animation.turn);
  if (animation.undo) history.pop(); else history.push(animation.spec);
  moves++; lastMove = animation.spec;
  const type = animation.undo ? 'undo' : 'move';
  animation = null;
  report(type); saveSession();
}

window.undoRubikToy = () => {
  if (gesture || animation || pointers.size) return false;
  if (challenge || !active || disposed || !interaction || !history.length) { report('state'); return false; }
  settle();
  if (!history.length) { report('state'); return false; }
  const previous = history[history.length - 1];
  startTurn({ ...previous, sign: -previous.sign }, true);
  return true;
};

window.resetRubikToy = () => {
  if (gesture || animation || pointers.size) return false;
  if (challenge || !active || disposed || !interaction) { report('state'); return false; }
  settle(); resetCube();
  history.length = 0; moves = 0; lastMove = null;
  camera.position.set(0, 0, 0); camera.up.set(0, 1, 0); zoomRatio = 1; fit();
  report('reset'); saveSession(); return true;
};

window.prepareRubikChallenge = moves => {
  if (animation) { finishTurn(animation.turn); animation = null; }
  gesture = null;
  for (const cubie of cube.cubies) {
    cubie.position.fromArray(cubie.userData.id.split(',').map(Number));
    cubie.quaternion.identity(); cubie.updateMatrix();
  }
  applyNotation(cube, moves);
  history.length = 0;
  challenge = true; interaction = false;
  requestRender(); report('prepared');
};
window.enableRubikChallenge = value => {
  interaction = !!value;
  if (!interaction) { gesture = null; pointers.clear(); multiTouch = false; }
};

function fit() {
  camera.aspect = innerWidth / innerHeight; camera.updateProjectionMatrix();
  // Same FOV, cube bounds and fitting formula as the old large main preview.
  const vertical = THREE.MathUtils.degToRad(20);
  const horizontal = Math.atan(Math.tan(vertical) * camera.aspect);
  const distance = 2.6 / Math.sin(Math.min(vertical, horizontal)) / .78;
  const direction = camera.position.length() ? camera.position.clone().normalize()
    : new THREE.Vector3(0, 0, 1).applyQuaternion(
      new THREE.Quaternion().setFromEuler(new THREE.Euler(-.35, .55, 0)).invert());
  fitDistance = distance;
  camera.position.copy(direction.multiplyScalar(distance * zoomRatio)); camera.lookAt(viewTarget);
  renderer.setSize(innerWidth, innerHeight); requestRender();
}

function requestRender() {
  dirty = true;
  if (!raf && active && !disposed && !document.hidden) raf = requestAnimationFrame(frame);
}

function frame(now) {
  raf = 0;
  if (!active || disposed || document.hidden) return;
  if (animation) {
    if (animation.start === null) animation.start = now;
    const t = Math.min(1, (now - animation.start) / duration);
    const eased = t * t * (3 - 2 * t);
    animation.turn.pivot.rotation[animation.turn.axis] = animation.turn.sign * Math.PI / 2 * eased;
    if (t === 1) {
      commitTurn();
    }
    dirty = true;
  }
  if (dirty) { renderer.render(scene, camera); renders++; dirty = false; }
  if (animation) requestRender();
}

function hitAt(x, y) {
  scene.updateMatrixWorld(true); camera.updateMatrixWorld(true);
  const bounds = canvas.getBoundingClientRect();
  raycaster.setFromCamera(new THREE.Vector2((x - bounds.left) / bounds.width * 2 - 1,
    -(y - bounds.top) / bounds.height * 2 + 1), camera);
  return pickCube(raycaster, cube.cubies);
}

function pointerDown(event) {
  event.stopImmediatePropagation();
  if (!active || disposed || !interaction || animation) return;
  pointers.set(event.pointerId, { x: event.clientX, y: event.clientY });
  canvas.setPointerCapture(event.pointerId);
  if (pointers.size > 1) {
    gesture = null; multiTouch = true; captureViewGesture(); return;
  }
  const hit = hitAt(event.clientX, event.clientY);
  gesture = oneFingerOrbit ? { id: event.pointerId, mode: 'view' }
    : hit ? { id: event.pointerId, x: event.clientX, y: event.clientY,
    hit, mode: 'layer', pending: null } : null;
}
function captureViewGesture() {
  viewGesture = pointers.size === 2 ? {
    points: [...pointers.values()], position: camera.position.clone(),
    up: camera.up.clone(), quaternion: camera.quaternion.clone(),
  } : null;
}
function changeZoom(ratio) {
  zoomRatio = THREE.MathUtils.clamp(ratio, .8, 1.8);
  camera.position.setLength(fitDistance * zoomRatio); camera.lookAt(viewTarget); requestRender();
}
function pointerMove(event) {
  const previous = pointers.get(event.pointerId);
  if (!previous) return;
  event.stopImmediatePropagation();
  pointers.set(event.pointerId, { x: event.clientX, y: event.clientY });
  if (multiTouch) {
    if (pointers.size === 2 && viewGesture) {
      // Resolve the pair from its shared baseline. Android delivers the two
      // pointer updates separately; incremental rotations would accumulate
      // false yaw/pitch during an otherwise pure twist.
      camera.position.copy(viewGesture.position); camera.up.copy(viewGesture.up);
      camera.quaternion.copy(viewGesture.quaternion);
      rotateView(camera, viewGesture.points, [...pointers.values()], viewTarget);
      orbits++; requestRender();
    }
    return;
  }
  if (!gesture || gesture.id !== event.pointerId || animation) return;
  if (gesture.mode === 'view') {
    const next = pointers.get(event.pointerId);
    rotateView(camera, [previous, previous], [next, next], viewTarget);
    orbits++; requestRender(); return;
  }
  const spec = chooseTurn(gesture.hit, event.clientX - gesture.x, event.clientY - gesture.y,
    camera, innerWidth, innerHeight, Math.max(18, Math.min(30, innerWidth * .045)));
  gesture.pending = spec;
}
function pointerEnd(event) {
  if (!pointers.has(event.pointerId)) return;
  event.stopImmediatePropagation();
  pointers.delete(event.pointerId);
  if (multiTouch) captureViewGesture();
  if (gesture?.id === event.pointerId) {
    if (event.type === 'pointerup' && !multiTouch && gesture.pending) startTurn(gesture.pending);
    gesture = null;
  }
  try { canvas.releasePointerCapture(event.pointerId); } catch (_) {}
  if (!pointers.size) { multiTouch = false; saveSession(); }
}
const listeners = [];
function listen(target, type, handler, options) {
  target.addEventListener(type, handler, options); listeners.push(() => target.removeEventListener(type, handler, options));
}
listen(canvas, 'pointerdown', pointerDown, true);
listen(canvas, 'pointermove', pointerMove, true);
listen(canvas, 'pointerup', pointerEnd, true);
listen(canvas, 'pointercancel', pointerEnd, true);
listen(canvas, 'lostpointercapture', pointerEnd);
listen(canvas, 'wheel', event => {
  event.preventDefault();
  if (active && interaction && !animation && !pointers.size) {
    changeZoom(zoomRatio * Math.exp(event.deltaY * .001)); saveSession();
  }
}, { passive: false });

window.setRubikToyActive = value => {
  active = !!value; gesture = null; pointers.clear(); multiTouch = false;
  if (!active) {
    cancelAnimationFrame(raf); raf = 0;
    // Commit the one selected move atomically before pausing mid-animation.
    if (animation) commitTurn();
    saveSession();
  } else requestRender();
};
listen(window, 'blur', () => window.setRubikToyActive(false));
listen(document, 'visibilitychange', () => window.setRubikToyActive(!document.hidden));
listen(window, 'resize', fit);
window.disposeRubikToy = () => {
  if (disposed) return;
  window.setRubikToyActive(false); disposed = true;
  listeners.splice(0).forEach(remove => remove());
  cube.dispose(); scene.clear(); renderer.renderLists.dispose(); renderer.dispose();
  renderer.forceContextLoss(); canvas.remove(); report('disposed');
};
listen(window, 'pagehide', window.disposeRubikToy);
// Read-only diagnostics for native tests.
window.rubikToySnapshot = () => ({ moves, renders, orbits, raf, active, disposed, oneFingerOrbit,
  busy: !!animation, historyDepth: history.length, gesture: gesture?.mode ?? null, lastMove,
  cube: cubeSnapshot(cube.cubies), camera: camera.position.toArray(), up: camera.up.toArray(), zoom: zoomRatio });
// Find a visible touch target by raycasting screen samples. Native tests still
// inject real touch gestures; this endpoint never mutates the cube.
window.rubikToyTouchTargets = () => {
  const result = [];
  for (let y = .25; y <= .75; y += .08) for (let x = .20; x <= .80; x += .08) {
    const hit = hitAt(x * innerWidth, y * innerHeight);
    if (hit && [[-4,0],[4,0],[0,-4],[0,4]].every(([dx,dy]) => {
      const neighbor = hitAt(x * innerWidth + dx, y * innerHeight + dy);
      return neighbor && neighbor.cubie === hit.cubie && neighbor.normal.equals(hit.normal);
    })) result.push({ x, y, normal: hit.normal.toArray(), cubie: hit.cubie.position.toArray() });
  }
  return result;
};
fit(); report('ready');
