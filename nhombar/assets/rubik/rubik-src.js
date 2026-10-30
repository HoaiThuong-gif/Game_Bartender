import * as THREE from 'three';

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

// Tạo Rubik
const rubik = new THREE.Group();
scene.add(rubik);

const geometry = new THREE.BoxGeometry(
  0.92,
  0.92,
  0.92
);

const black = new THREE.MeshBasicMaterial({
  color: 0x111111
});

const white = new THREE.MeshBasicMaterial({
  color: 0xffffff
});

const yellow = new THREE.MeshBasicMaterial({
  color: 0xffe600
});

const red = new THREE.MeshBasicMaterial({
  color: 0xe53935
});

const orange = new THREE.MeshBasicMaterial({
  color: 0xff8c00
});

const blue = new THREE.MeshBasicMaterial({
  color: 0x1565c0
});

const green = new THREE.MeshBasicMaterial({
  color: 0x2eaa4f
});

const unknown = new THREE.MeshBasicMaterial({ color: 0xcbd3df });
const stickerMaterials = { U: white, R: red, F: green, D: yellow, L: orange, B: blue, '?': unknown };
const cubiesByPosition = new Map();

function createCubie(x, y, z) {
  const materials = [
    x === 1 ? red : black,
    x === -1 ? orange : black,
    y === 1 ? white : black,
    y === -1 ? yellow : black,
    z === 1 ? green : black,
    z === -1 ? blue : black
  ];

  const cubie = new THREE.Mesh(
    geometry,
    materials
  );

  cubie.position.set(x, y, z);

  cubie.userData.x = x;
  cubie.userData.y = y;
  cubie.userData.z = z;

  rubik.add(cubie);
  cubiesByPosition.set(`${x},${y},${z}`, cubie);
}

for (let x = -1; x <= 1; x++) {
  for (let y = -1; y <= 1; y++) {
    for (let z = -1; z <= 1; z++) {
      createCubie(x, y, z);
    }
  }
}

// Same external, row-major facelet net as cuber: U R F D L B.
// Axes: +x=R, +y=U, +z=F. BoxGeometry materials: +x,-x,+y,-y,+z,-z.
// In particular B columns and D rows run opposite to F/U in world space.
const faceletLayout = [
  { face: 'U', material: 2, position: (r, c) => [c - 1, 1, r - 1] },
  { face: 'R', material: 0, position: (r, c) => [1, 1 - r, 1 - c] },
  { face: 'F', material: 4, position: (r, c) => [c - 1, 1 - r, 1] },
  { face: 'D', material: 3, position: (r, c) => [c - 1, -1, 1 - r] },
  { face: 'L', material: 1, position: (r, c) => [-1, 1 - r, c - 1] },
  { face: 'B', material: 5, position: (r, c) => [1 - c, 1 - r, -1] },
];
const stickerTargets = faceletLayout.flatMap(({ material, position }) =>
  Array.from({ length: 9 }, (_, i) => ({
    cubie: cubiesByPosition.get(position(Math.floor(i / 3), i % 3).join(',')),
    material,
  }))
);

// 54 bytes per update. Reuse all meshes/materials and coalesce to one RAF.
// '?' represents a sticker not yet entered. Reject malformed payload atomically.
window.setCubeState = (definition) => {
  if (typeof definition !== 'string' || !/^[URFDLB?]{54}$/.test(definition)) return false;
  let changed = false;
  for (let i = 0; i < 54; i++) {
    const target = stickerTargets[i];
    const material = stickerMaterials[definition[i]];
    if (target.cubie.material[target.material] !== material) {
      target.cubie.material[target.material] = material;
      changed = true;
    }
  }
  if (changed) requestRender();
  return true;
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
