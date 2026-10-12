import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { fitCameraDistance, positionCamera as placeCamera } from './framing.mjs';

// A single short reveal, then render only when orbit/resize changes the view.
THREE.Cache.enabled = false;
let scene, camera, renderer, controls, item, mixer, particles;
let raf = 0, disposed = false, active = true, running = false;
let started = 0, previous = 0, clipElapsed = 0, clipDuration = 0;
let frames = 0, gaps = [], rendered = 0, orbitReported = false;
let distance = 4, size = new THREE.Vector3(), target = new THREE.Vector3();
const abort = new AbortController();
const reduced = new URLSearchParams(location.search).get('motion') === 'reduced';
const report = (type, data = {}) => window.GachaCinematic?.postMessage(JSON.stringify({ type, ...data }));
const ease = t => 1 - (1 - t) ** 3;

function disposeTree(root) {
  const geometries = new Set(), materials = new Set(), textures = new Set(), images = new Set();
  root?.traverse(object => {
    if (object.geometry) geometries.add(object.geometry);
    for (const material of (Array.isArray(object.material) ? object.material : [object.material])) {
      if (!material) continue;
      materials.add(material);
      for (const value of Object.values(material)) if (value?.isTexture) textures.add(value);
    }
  });
  for (const texture of textures) {
    const data = texture.source?.data;
    if (data?.close) images.add(data);
    texture.dispose();
  }
  for (const data of images) data.close();
  for (const geometry of geometries) geometry.dispose();
  for (const material of materials) material.dispose();
}

function render() {
  if (disposed || !active || !renderer || !item) return;
  renderer.render(scene, camera);
  rendered++;
}

function resize() {
  if (!renderer || disposed) return;
  const width = Math.max(1, innerWidth), height = Math.max(1, innerHeight);
  renderer.setSize(width, height, false);
  camera.aspect = width / height;
  camera.updateProjectionMatrix();
  distance = fitCameraDistance(camera, target, size);
  controls.minDistance = distance * .90;
  controls.maxDistance = distance * 1.30;
  if (!running && item) positionCamera(distance);
  render();
}

function positionCamera(d) {
  placeCamera(camera, target, d);
}

function animate(now) {
  raf = 0;
  if (disposed || !active || !running) return;
  if (!started) { started = now; previous = now; }
  const gap = now - previous;
  const delta = Math.min(.05, gap / 1000);
  if (gap > 0) gaps.push(gap);
  previous = now;
  frames++;
  const t = reduced ? 1 : Math.min(1, (now - started) / 760);
  item.scale.setScalar(.7 + .3 * ease(t));
  item.position.y = .08 + Math.sin(t * Math.PI) * .18;
  item.rotation.y = THREE.MathUtils.degToRad(-25 * (1 - ease(t)));
  positionCamera(distance * (1.18 - .18 * ease(t)));
  if (particles) {
    for (let i = 0; i < particles.children.length; i++) {
      const p = particles.children[i], angle = i * Math.PI / 3;
      p.position.set(Math.cos(angle) * (.65 + t * .5), .25 + Math.sin(t * Math.PI) * .4, Math.sin(angle) * (.65 + t * .5));
      p.rotation.z = t * (i % 2 ? 2 : -2);
    }
    particles.children[0].material.opacity = (1 - t) * .65;
  }
  if (mixer && clipElapsed < clipDuration) { mixer.update(delta); clipElapsed += delta; }
  render();
  if (t < 1 || (mixer && clipElapsed < clipDuration)) {
    raf = requestAnimationFrame(animate);
  } else {
    running = false;
    if (particles) { scene.remove(particles); disposeTree(particles); particles = null; }
    controls.enabled = true;
    controls.update();
    render();
    gaps.sort((a, b) => a - b);
    report('settled', { frames, fps: gaps.length ? 1000 * gaps.length / gaps.reduce((a,b) => a+b,0) : null,
      p95FrameMs: gaps[Math.floor(gaps.length * .95)] ?? null,
      geometries: renderer.info.memory.geometries, textures: renderer.info.memory.textures });
    gaps = [];
  }
}

function onOrbit() {
  render();
  if (!running && controls?.enabled && !orbitReported && controls.userDataInteracting) {
    orbitReported = true;
    report('orbit', { rendered });
  }
}
const orbitStart = () => { controls.userDataInteracting = true; };
const orbitEnd = () => { controls.userDataInteracting = false; };
window.gachaSnapshot = () => ({ running, raf, rendered, orbitReported, disposed });

window.setGachaActive = value => {
  if (disposed) return;
  active = value;
  if (!active) { cancelAnimationFrame(raf); raf = 0; previous = 0; }
  else if (running && !raf) { started = 0; raf = requestAnimationFrame(animate); }
  else render();
};

window.disposeGacha = () => {
  if (disposed) return;
  disposed = true;
  abort.abort();
  cancelAnimationFrame(raf); raf = 0;
  removeEventListener('resize', resize);
  removeEventListener('pagehide', window.disposeGacha);
  renderer?.domElement.removeEventListener('webglcontextlost', contextLost);
  controls?.removeEventListener('change', onOrbit);
  controls?.removeEventListener('start', orbitStart);
  controls?.removeEventListener('end', orbitEnd);
  controls?.dispose();
  if (mixer) { mixer.stopAllAction(); mixer.uncacheRoot(item.children[0]); }
  disposeTree(scene);
  scene?.clear();
  renderer?.renderLists.dispose();
  renderer?.dispose();
  renderer?.forceContextLoss();
  renderer?.domElement.remove();
  scene = camera = renderer = controls = item = mixer = particles = null;
  gaps = [];
  report('disposed', { rendered });
};

function contextLost(event) {
  event.preventDefault();
  if (!disposed) { report('error', { message: 'WebGL context lost' }); window.disposeGacha(); }
}

async function init() {
  try {
    scene = new THREE.Scene();
    scene.background = new THREE.Color('#e8ddc7');
    renderer = new THREE.WebGLRenderer({ antialias: false, alpha: false, powerPreference: 'low-power' });
    renderer.setPixelRatio(Math.min(devicePixelRatio || 1, 1.25));
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    document.body.appendChild(renderer.domElement);
    renderer.domElement.addEventListener('webglcontextlost', contextLost);
    camera = new THREE.PerspectiveCamera(38, 1, .01, 100);
    controls = new OrbitControls(camera, renderer.domElement);
    controls.enabled = false;
    controls.enablePan = false;
    controls.enableDamping = false;
    controls.autoRotate = false;
    controls.minPolarAngle = Math.PI * .18;
    controls.maxPolarAngle = Math.PI * .47;
    controls.minAzimuthAngle = -Math.PI * .85;
    controls.maxAzimuthAngle = Math.PI * .85;
    controls.addEventListener('change', onOrbit);
    controls.addEventListener('start', orbitStart);
    controls.addEventListener('end', orbitEnd);
    scene.add(new THREE.HemisphereLight(0xfff4dd, 0x72553a, 2.4));
    const light = new THREE.DirectionalLight(0xffead1, 2.5);
    light.position.set(3, 5, 4); scene.add(light);
    const pedestal = new THREE.Mesh(new THREE.CylinderGeometry(1.12, 1.17, .16, 32),
      new THREE.MeshStandardMaterial({ color: 0x986039, roughness: .95 }));
    pedestal.position.y = -.01; scene.add(pedestal);
    const canvas = document.createElement('canvas'); canvas.width = canvas.height = 64;
    const ctx = canvas.getContext('2d');
    const gradient = ctx.createRadialGradient(32,32,2,32,32,32);
    gradient.addColorStop(0, 'rgba(35,20,8,.38)'); gradient.addColorStop(1, 'rgba(35,20,8,0)');
    ctx.fillStyle = gradient; ctx.fillRect(0,0,64,64);
    const shadow = new THREE.Mesh(new THREE.PlaneGeometry(2.1, 2.1),
      new THREE.MeshBasicMaterial({ map: new THREE.CanvasTexture(canvas), transparent: true, depthWrite: false }));
    shadow.rotation.x = -Math.PI / 2; shadow.position.y = .073; scene.add(shadow);
    const loadStart = performance.now();
    const response = await fetch('model.glb', { signal: abort.signal });
    if (!response.ok) throw new Error('GLB HTTP ' + response.status);
    const gltf = await new GLTFLoader().parseAsync(await response.arrayBuffer(), location.href);
    if (disposed) { for (const root of gltf.scenes) disposeTree(root); return; }
    item = new THREE.Group(); item.add(gltf.scene); scene.add(item);
    const bounds = new THREE.Box3().setFromObject(gltf.scene);
    bounds.getSize(size);
    if (!Number.isFinite(size.length()) || size.length() === 0) throw new Error('Empty GLB');
    const factor = 1.85 / Math.max(size.x, size.y, size.z);
    gltf.scene.scale.setScalar(factor);
    gltf.scene.position.set(-(bounds.min.x + bounds.max.x) / 2 * factor,
      -bounds.min.y * factor, -(bounds.min.z + bounds.max.z) / 2 * factor);
    size.multiplyScalar(factor);
    // Retain unused roots only for deduplicated cleanup, never for rendering.
    for (const root of gltf.scenes) if (root !== gltf.scene) { root.visible = false; scene.add(root); }
    target.set(0, .08 + size.y * .40, 0); controls.target.copy(target);
    if (gltf.animations.length && !reduced) {
      mixer = new THREE.AnimationMixer(gltf.scene);
      const clip = gltf.animations[0]; clipDuration = clip.duration;
      const action = mixer.clipAction(clip); action.setLoop(THREE.LoopOnce, 1); action.clampWhenFinished = true; action.play();
    }
    if (!reduced) {
      particles = new THREE.Group();
      const geometry = new THREE.PlaneGeometry(.045, .075);
      const material = new THREE.MeshBasicMaterial({ color: 0xffe8a3, transparent: true, side: THREE.DoubleSide, depthWrite: false });
      for (let i=0; i<6; i++) particles.add(new THREE.Mesh(geometry, material));
      scene.add(particles);
    }
    // Compile shaders and upload textures behind Flutter's loading cover.
    // Measuring the actual reveal excludes this one-time warmup cost.
    const shaderStart = performance.now();
    resize(); item.scale.setScalar(.7); item.position.y = .08;
    item.rotation.y = THREE.MathUtils.degToRad(-25); positionCamera(distance * 1.18);
    await renderer.compileAsync(scene, camera);
    if (disposed) return;
    render();
    const shaderMs = performance.now() - shaderStart;
    running = true;
    addEventListener('resize', resize);
    addEventListener('pagehide', window.disposeGacha);
    raf = requestAnimationFrame(animate);
    report('ready', { loadMs: performance.now() - loadStart, shaderMs, modelMeshes: gltf.scene.children.length });
  } catch (error) {
    if (!disposed) { report('error', { message: String(error) }); window.disposeGacha(); }
  }
}
init();
