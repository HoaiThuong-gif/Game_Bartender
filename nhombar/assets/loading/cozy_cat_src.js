import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

let renderer, mixer, scene, camera, frame;
const clock = new THREE.Clock();
function draw() {
  frame = requestAnimationFrame(draw);
  mixer?.update(Math.min(clock.getDelta(), .05));
  renderer.render(scene, camera);
}
window.setCatActive = active => {
  cancelAnimationFrame(frame);
  if (active && renderer) { clock.start(); draw(); }
};
window.loadCozyCat = (encoded, animate) => {
  try {
    const bytes = Uint8Array.from(atob(encoded), c => c.charCodeAt(0));
    new GLTFLoader().parse(bytes.buffer, '', gltf => {
      try {
        scene = new THREE.Scene();
        scene.add(gltf.scene, new THREE.HemisphereLight(0xfff8ef, 0x8b6b56, 2.5));
        const light = new THREE.DirectionalLight(0xffecd2, 3);
        light.position.set(-3, 6, -5); scene.add(light);
        const bounds = new THREE.Box3().setFromObject(gltf.scene);
        const center = bounds.getCenter(new THREE.Vector3());
        const radius = bounds.getSize(new THREE.Vector3()).length() * .5;
        camera = new THREE.PerspectiveCamera(38, innerWidth / innerHeight, .01, radius * 30);
        camera.position.copy(center).add(new THREE.Vector3(radius * .15, radius * .3, radius * 1.9));
        camera.lookAt(center);
        renderer = new THREE.WebGLRenderer({alpha: true, antialias: true});
        renderer.setPixelRatio(Math.min(devicePixelRatio, 1.4));
        renderer.setSize(innerWidth, innerHeight);
        document.body.appendChild(renderer.domElement);
        const idle = gltf.animations.find(a => a.name === 'Idle') ?? gltf.animations[0];
        if (idle && animate) { mixer = new THREE.AnimationMixer(gltf.scene); mixer.clipAction(idle).play(); }
        renderer.render(scene, camera);
        if (animate) draw();
        window.addEventListener('resize', () => {
          camera.aspect = innerWidth / innerHeight; camera.updateProjectionMatrix();
          renderer.setSize(innerWidth, innerHeight);
        });
      } catch (_) { CatStatus.postMessage('error'); }
    }, () => CatStatus.postMessage('error'));
  } catch (_) { CatStatus.postMessage('error'); }
};
