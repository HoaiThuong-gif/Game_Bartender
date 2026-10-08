import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import rubikGlbBase64 from './rubik.glb'; // inlined as base64 by esbuild

const scene = new THREE.Scene();

const camera = new THREE.PerspectiveCamera(
  40,
  window.innerWidth / window.innerHeight,
  0.1,
  100
);

// Fit the bounding sphere to the narrower viewport dimension.
function fittedDistance() {
  const vertical = THREE.MathUtils.degToRad(camera.fov / 2);
  const horizontal = Math.atan(Math.tan(vertical) * camera.aspect);
  return 2.6 / Math.sin(Math.min(vertical, horizontal)) / 0.78;
}

let baseZoom = fittedDistance();
let zoom = baseZoom;
let targetZoom = zoom;

let minZoom = baseZoom * 0.55;
let maxZoom = baseZoom * 2;

camera.position.set(0, 0, zoom);

const renderer = new THREE.WebGLRenderer({
  antialias: false,
  alpha: false,
  powerPreference: 'high-performance'
});

renderer.setPixelRatio(1);
renderer.setSize(
  window.innerWidth,
  window.innerHeight
);

renderer.domElement.style.display = 'block';
renderer.domElement.style.touchAction = 'none';

document.body.style.margin = '0';
document.body.style.overflow = 'hidden';
document.body.style.background = '#111';

document.body.appendChild(renderer.domElement);

// ---------------------------------------------------------------------------
// Rubik model: loaded from a glTF Binary (GLB) asset made in Blender
// (tools/blender/make_rubik.py -> assets/rubik/rubik.glb).
// The GLB is inlined by esbuild (--loader:.glb=base64), so no network/file
// fetch is needed inside the Flutter WebView.
//
// Node naming contract (see make_rubik.py):
//   cubie_<ix><iy><iz>  (ix,iy,iz in 0..2 = game coordinate + 1)
//     body_<ix><iy><iz>          black plastic
//     sticker_<F>_<ix><iy><iz>   F in U R F D L B (outer faces only)
// Lookups are prefix-based because GLTFLoader may append _1, _2... to names.
// ---------------------------------------------------------------------------
const rubik = new THREE.Group();
scene.add(rubik);

// Lights (Lambert shading so the bevels of the Blender model are visible).
// Tune these two numbers if colors look too dark / too washed out.
const AMBIENT_INTENSITY = 1.9;
const KEY_LIGHT_INTENSITY = 1.2;
scene.add(new THREE.AmbientLight(0xffffff, AMBIENT_INTENSITY));
const keyLight = new THREE.DirectionalLight(0xffffff, KEY_LIGHT_INTENSITY);
keyLight.position.set(3, 5, 6);
scene.add(keyLight);

const bodyMaterial = new THREE.MeshLambertMaterial({ color: 0x111111 });
const stickerMaterials = {
  U: new THREE.MeshLambertMaterial({ color: 0xffffff }),
  R: new THREE.MeshLambertMaterial({ color: 0xe53935 }),
  F: new THREE.MeshLambertMaterial({ color: 0x2eaa4f }),
  D: new THREE.MeshLambertMaterial({ color: 0xffe600 }),
  L: new THREE.MeshLambertMaterial({ color: 0xff8c00 }),
  B: new THREE.MeshLambertMaterial({ color: 0x1565c0 }),
  '?': new THREE.MeshLambertMaterial({ color: 0xcbd3df }),
};

// "x,y,z" (game coords, -1..1) -> { U: Mesh, R: Mesh, ... }
const stickersByPosition = new Map();
// 54 sticker meshes in the facelet order U R F D L B (row-major); filled after load.
let stickerTargets = null;
let pendingState = null;

function base64ToArrayBuffer(base64) {
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

// Same external, row-major facelet net as cuber: U R F D L B.
// Axes: +x=R, +y=U, +z=F. B columns and D rows run opposite to F/U in world space.
const faceletLayout = [
  { face: 'U', position: (r, c) => [c - 1, 1, r - 1] },
  { face: 'R', position: (r, c) => [1, 1 - r, 1 - c] },
  { face: 'F', position: (r, c) => [c - 1, 1 - r, 1] },
  { face: 'D', position: (r, c) => [c - 1, -1, 1 - r] },
  { face: 'L', position: (r, c) => [-1, 1 - r, c - 1] },
  { face: 'B', position: (r, c) => [1 - c, 1 - r, -1] },
];

function onModelLoaded(gltf) {
  gltf.scene.traverse((node) => {
    if (!node.isMesh) return;
    if (/^body(?:_|$)/.test(node.name)) {
      node.material = bodyMaterial;
      return;
    }
    const match = /^sticker_([URFDLB])(?:_|$)/.exec(node.name);
    const cubie = node.parent && /^cubie_(\d)(\d)(\d)$/.exec(node.parent.name);
    if (!match || !cubie) return;
    const key = [cubie[1], cubie[2], cubie[3]].map((n) => Number(n) - 1).join(',');
    node.material = stickerMaterials[match[1]]; // solved colors by default
    if (!stickersByPosition.has(key)) stickersByPosition.set(key, {});
    stickersByPosition.get(key)[match[1]] = node;
  });
  rubik.add(gltf.scene);

  stickerTargets = faceletLayout.flatMap(({ face, position }) =>
    Array.from({ length: 9 }, (_, i) => {
      const key = position(Math.floor(i / 3), i % 3).join(',');
      return stickersByPosition.get(key)[face];
    })
  );

  if (pendingState) applyCubeState(pendingState);
  requestRender();
}

new GLTFLoader().parse(
  base64ToArrayBuffer(rubikGlbBase64),
  '',
  onModelLoaded,
  (error) => console.error('Failed to parse rubik.glb', error)
);

function applyCubeState(definition) {
  if (!stickerTargets) return;
  let changed = false;
  for (let i = 0; i < 54; i++) {
    const material = stickerMaterials[definition[i]];
    if (stickerTargets[i].material !== material) {
      stickerTargets[i].material = material;
      changed = true;
    }
  }
  if (changed) requestRender();
}

// 54 chars per update. '?' represents a sticker not yet entered.
// Reject malformed payload atomically. If the GLB is not parsed yet,
// the latest valid state is kept and applied as soon as it is ready.
window.setCubeState = (definition) => {
  if (typeof definition !== 'string' || !/^[URFDLB?]{54}$/.test(definition)) return false;
  pendingState = definition;
  applyCubeState(definition);
  return true;
};

// Demo helper (used by assets/rubik/demo.html): show the polygon mesh.
window.setRubikWireframe = (on) => {
  bodyMaterial.wireframe = !!on;
  for (const material of Object.values(stickerMaterials)) material.wireframe = !!on;
  requestRender();
};

// Xoay góc nhìn
let rotationX = -0.35;
let rotationY = 0.55;

let targetRotationX = rotationX;
let targetRotationY = rotationY;

rubik.rotation.x = rotationX;
rubik.rotation.y = rotationY;

const sensitivity = 0.008;

let dragging = false;

let lastX = 0;
let lastY = 0;

let frameId = null;
let lastFrameTime = 0;

let suspended = false;

const touches = new Map();
let pinchDistance = null;

function render() {
  renderer.render(scene, camera);
}

function needsAnimation() {
  return (
    Math.abs(
      targetRotationX - rotationX
    ) > 0.001 ||
    Math.abs(
      targetRotationY - rotationY
    ) > 0.001 ||
    Math.abs(
      targetZoom - zoom
    ) > 0.005
  );
}

function requestRender() {
  if (frameId !== null || suspended || document.hidden) {
    return;
  }

  frameId = requestAnimationFrame(update);
}

function update(time) {
  frameId = null;

  const elapsed = lastFrameTime ? Math.min(time - lastFrameTime, 50) : 16.7;
  lastFrameTime = time;
  // Drag tracks the finger directly. Only wheel zoom needs interpolation.
  rotationX = targetRotationX;
  rotationY = targetRotationY;
  zoom += (targetZoom - zoom) * (1 - Math.exp(-elapsed / 45));
  if (Math.abs(targetZoom - zoom) <= 0.005) zoom = targetZoom;

  rubik.rotation.x = rotationX;
  rubik.rotation.y = rotationY;

  camera.position.z = zoom;

  render();

  if (needsAnimation()) {
    requestRender();
  }
}

// Chuột
renderer.domElement.addEventListener(
  'pointerdown',
  (event) => {
    if (event.pointerType === 'touch') {
      return;
    }

    dragging = true;

    lastX = event.clientX;
    lastY = event.clientY;

    renderer.domElement.setPointerCapture(
      event.pointerId
    );

    requestRender();
  }
);

renderer.domElement.addEventListener(
  'pointermove',
  (event) => {
    if (
      event.pointerType === 'touch' ||
      !dragging
    ) {
      return;
    }

    const deltaX =
      event.clientX - lastX;

    const deltaY =
      event.clientY - lastY;

    targetRotationY +=
      deltaX * sensitivity;

    targetRotationX +=
      deltaY * sensitivity;

    lastX = event.clientX;
    lastY = event.clientY;

    requestRender();
  }
);

function stopMouse(event) {
  if (event.pointerType === 'touch') {
    return;
  }

  dragging = false;

  try {
    renderer.domElement.releasePointerCapture(
      event.pointerId
    );
  } catch (_) {}

  requestRender();
}

renderer.domElement.addEventListener(
  'pointerup',
  stopMouse
);

renderer.domElement.addEventListener(
  'pointercancel',
  stopMouse
);

renderer.domElement.addEventListener(
  'lostpointercapture',
  () => {
    dragging = false;
  }
);

// Zoom bằng con lăn
renderer.domElement.addEventListener(
  'wheel',
  (event) => {
    event.preventDefault();

    targetZoom +=
      event.deltaY * 0.005;

    targetZoom =
      THREE.MathUtils.clamp(
        targetZoom,
        minZoom,
        maxZoom
      );

    requestRender();
  },
  {
    passive: false
  }
);

// Touch
function getTouchDistance() {
  const points =
    [...touches.values()];

  if (points.length < 2) {
    return null;
  }

  const dx =
    points[0].x -
    points[1].x;

  const dy =
    points[0].y -
    points[1].y;

  return Math.hypot(dx, dy);
}

renderer.domElement.addEventListener(
  'touchstart',
  (event) => {
    event.preventDefault();

    for (
      const touch of event.changedTouches
    ) {
      touches.set(
        touch.identifier,
        {
          x: touch.clientX,
          y: touch.clientY
        }
      );
    }

    if (touches.size === 1) {
      const point =
        [...touches.values()][0];

      dragging = true;

      lastX = point.x;
      lastY = point.y;

      pinchDistance = null;
    }

    if (touches.size >= 2) {
      dragging = false;

      pinchDistance =
        getTouchDistance();
    }

    requestRender();
  },
  {
    passive: false
  }
);

renderer.domElement.addEventListener(
  'touchmove',
  (event) => {
    event.preventDefault();

    for (
      const touch of event.changedTouches
    ) {
      touches.set(
        touch.identifier,
        {
          x: touch.clientX,
          y: touch.clientY
        }
      );
    }

    if (touches.size === 1) {
      const point =
        [...touches.values()][0];

      const deltaX =
        point.x - lastX;

      const deltaY =
        point.y - lastY;

      targetRotationY +=
        deltaX * sensitivity;

      targetRotationX +=
        deltaY * sensitivity;

      lastX = point.x;
      lastY = point.y;

      dragging = true;
      pinchDistance = null;
    }

    if (touches.size >= 2) {
      dragging = false;

      const newDistance =
        getTouchDistance();

      if (
        pinchDistance !== null &&
        newDistance !== null
      ) {
        const difference =
          newDistance -
          pinchDistance;

        targetZoom -=
          difference * baseZoom * 0.0014;

        targetZoom =
          THREE.MathUtils.clamp(
            targetZoom,
            minZoom,
            maxZoom
          );
      }

      pinchDistance =
        newDistance;
      zoom = targetZoom;
    }

    requestRender();
  },
  {
    passive: false
  }
);

function endTouch(event) {
  event.preventDefault();

  for (
    const touch of event.changedTouches
  ) {
    touches.delete(
      touch.identifier
    );
  }

  if (touches.size === 0) {
    dragging = false;
    pinchDistance = null;
  } else if (touches.size === 1) {
    pinchDistance = null;
    dragging = true;

    const point =
      [...touches.values()][0];

    lastX = point.x;
    lastY = point.y;
  }

  requestRender();
}

renderer.domElement.addEventListener(
  'touchend',
  endTouch,
  {
    passive: false
  }
);

renderer.domElement.addEventListener(
  'touchcancel',
  endTouch,
  {
    passive: false
  }
);

// Khi WebView mất focus thì dừng tương tác
function stopInteraction() {
  dragging = false;
  pinchDistance = null;
  touches.clear();
}

function pauseRendering() {
  stopInteraction();
  if (frameId !== null) cancelAnimationFrame(frameId);
  frameId = null;
  lastFrameTime = 0;
}

// Called by Flutter when the app leaves/returns to the foreground.
window.setRubikActive = (active) => {
  suspended = !active;
  if (suspended) pauseRendering();
  else requestRender();
};

window.addEventListener(
  'blur',
  stopInteraction
);

document.addEventListener(
  'visibilitychange',
  () => {
    if (document.hidden) {
      pauseRendering();
    } else requestRender();
  }
);

// Resize
function resize() {
  camera.aspect =
    window.innerWidth /
    window.innerHeight;

  camera.updateProjectionMatrix();

  const ratio = targetZoom / baseZoom;
  baseZoom = fittedDistance();
  minZoom = baseZoom * 0.55;
  maxZoom = baseZoom * 2;
  zoom = targetZoom = THREE.MathUtils.clamp(baseZoom * ratio, minZoom, maxZoom);
  camera.position.z = zoom;

  renderer.setSize(
    window.innerWidth,
    window.innerHeight
  );

  requestRender();
}

window.addEventListener(
  'resize',
  resize
);

window.addEventListener('pagehide', pauseRendering);
window.addEventListener('pageshow', requestRender);
requestRender();
