import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { createCube, pickCube, chooseTurn, beginTurn, finishTurn, cubeSnapshot, applyNotation, isCubeSolved } from './interactive-cube.mjs';

const scene = new THREE.Scene(); scene.background = new THREE.Color(0xdceffc);
const camera = new THREE.PerspectiveCamera(40, innerWidth / innerHeight, .1, 100);
const renderer = new THREE.WebGLRenderer({ antialias: false, powerPreference: 'low-power' });
renderer.setPixelRatio(Math.min(devicePixelRatio || 1, 1.25));
renderer.setSize(innerWidth, innerHeight);
const canvas = renderer.domElement; document.body.appendChild(canvas);
const cube = createCube(); scene.add(cube.root);
scene.add(new THREE.HemisphereLight(0xffffff, 0x444444, 2));
const light = new THREE.DirectionalLight(0xffffff, 1); light.position.set(3, 5, 4); scene.add(light);
const controls = new OrbitControls(camera, canvas);
controls.enablePan = false; controls.enableZoom = false;
controls.enableDamping = false; controls.autoRotate = false;
controls.target.set(0, 0, 0);
const raycaster = new THREE.Raycaster();
let active = true, disposed = false, raf = 0, dirty = true, gesture = null, animation = null;
let moves = 0, renders = 0, orbits = 0, lastMove = null;
let interaction = true, challenge = false;
const history = [];
const report = type => window.RubikToy?.postMessage(JSON.stringify({ type, moves,
  busy: !!animation || !!gesture, historyDepth: history.length, solved: isCubeSolved(cube) }));
const duration = 240;

function startTurn(spec, undo = false) {
  animation = { turn: beginTurn(cube.root, cube.cubies, spec.axis, spec.layer, spec.sign), spec, undo, start: null };
  controls.enabled = false;
  report('state'); requestRender();
}

function commitTurn() {
  finishTurn(animation.turn);
  if (animation.undo) history.pop(); else history.push(animation.spec);
  moves++; lastMove = animation.spec;
  const type = animation.undo ? 'undo' : 'move';
  animation = null;
  controls.enabled = active && (!gesture || gesture.mode === 'orbit');
  report(type);
}

window.undoRubikToy = () => {
  if (challenge || !active || disposed || animation || gesture || !history.length) { report('state'); return false; }
  const previous = history[history.length - 1];
  startTurn({ ...previous, sign: -previous.sign }, true);
  return true;
};

window.resetRubikToy = () => {
  if (challenge || !active || disposed || animation || gesture) { report('state'); return false; }
  for (const cubie of cube.cubies) {
    cubie.position.fromArray(cubie.userData.id.split(',').map(Number));
    cubie.quaternion.identity(); cubie.updateMatrix();
  }
  cube.root.updateMatrixWorld(true);
  history.length = 0; moves = 0; lastMove = null;
  controls.target.set(0, 0, 0); camera.position.set(0, 0, 0); fit();
  report('reset'); return true;
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
  challenge = true; interaction = false; controls.enabled = false;
  requestRender(); report('prepared');
};
window.enableRubikChallenge = value => {
  interaction = !!value; controls.enabled = active && interaction && !animation;
  if (!interaction) gesture = null;
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
  camera.position.copy(direction.multiplyScalar(distance)); controls.update();
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
  if (!active || disposed || !interaction) { event.stopImmediatePropagation(); return; }
  // Capture-phase runs before OrbitControls; a hit gesture never reaches orbit.
  if (animation || gesture) { controls.enabled = false; event.stopImmediatePropagation(); return; }
  const hit = hitAt(event.clientX, event.clientY);
  gesture = { id: event.pointerId, x: event.clientX, y: event.clientY,
    hit, mode: hit ? 'layer' : 'orbit', committed: false };
  if (hit) {
    controls.enabled = false;
    canvas.setPointerCapture(event.pointerId); event.stopImmediatePropagation();
  } else controls.enabled = true;
  report('state');
}

function pointerMove(event) {
  if (!gesture || event.pointerId !== gesture.id || gesture.mode === 'orbit') return;
  event.stopImmediatePropagation();
  if (gesture.committed || animation) return;
  const spec = chooseTurn(gesture.hit, event.clientX - gesture.x, event.clientY - gesture.y,
    camera, innerWidth, innerHeight, Math.max(18, Math.min(30, innerWidth * .045)));
  if (!spec) return;
  gesture.committed = true;
  startTurn(spec);
}

function pointerEnd(event) {
  if (!gesture || event.pointerId !== gesture.id) return;
  if (gesture.mode === 'layer') {
    event.stopImmediatePropagation();
    try { canvas.releasePointerCapture(event.pointerId); } catch (_) {}
    gesture = null; controls.enabled = !animation;
  } else {
    // Allow OrbitControls' pointerup to release its own capture/listeners.
    gesture = null;
  }
  report('state');
}

function orbitChanged() { orbits++; requestRender(); }
const listeners = [];
function listen(target, type, handler, options) {
  target.addEventListener(type, handler, options); listeners.push(() => target.removeEventListener(type, handler, options));
}
listen(canvas, 'pointerdown', pointerDown, true);
listen(canvas, 'pointermove', pointerMove, true);
listen(canvas, 'pointerup', pointerEnd, true);
listen(canvas, 'pointercancel', pointerEnd, true);
listen(canvas, 'lostpointercapture', event => {
  if (gesture?.id === event.pointerId) { gesture = null; controls.enabled = !animation; report('state'); }
});
controls.addEventListener('change', orbitChanged);

window.setRubikToyActive = value => {
  active = !!value; gesture = null;
  if (!active) {
    cancelAnimationFrame(raf); raf = 0; controls.enabled = false;
    // Commit the one selected move atomically before pausing mid-animation.
    if (animation) commitTurn();
  } else { controls.enabled = interaction; requestRender(); }
};
listen(window, 'blur', () => window.setRubikToyActive(false));
listen(document, 'visibilitychange', () => window.setRubikToyActive(!document.hidden));
listen(window, 'resize', fit);
window.disposeRubikToy = () => {
  if (disposed) return;
  window.setRubikToyActive(false); disposed = true;
  listeners.splice(0).forEach(remove => remove());
  controls.removeEventListener('change', orbitChanged); controls.dispose();
  cube.dispose(); scene.clear(); renderer.renderLists.dispose(); renderer.dispose();
  renderer.forceContextLoss(); canvas.remove(); report('disposed');
};
listen(window, 'pagehide', window.disposeRubikToy);
// Read-only diagnostics for native tests.
window.rubikToySnapshot = () => ({ moves, renders, orbits, raf, active, disposed,
  busy: !!animation, historyDepth: history.length, gesture: gesture?.mode ?? null, lastMove,
  cube: cubeSnapshot(cube.cubies), camera: camera.position.toArray() });
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
