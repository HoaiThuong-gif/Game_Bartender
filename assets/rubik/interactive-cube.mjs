import * as THREE from 'three';

export const axes = ['x', 'y', 'z'];
const basis = axes.map((_, i) => new THREE.Vector3().setComponent(i, 1));
const orientations = [];
// The cube rotation group contains exactly 24 orientations. Snap to these
// quaternions, rather than rounding Euler angles (which fails at gimbal lock).
for (const x of basis.flatMap(v => [v.clone(), v.clone().negate()])) {
  for (const y of basis.flatMap(v => [v.clone(), v.clone().negate()])) {
    if (x.dot(y) !== 0) continue;
    const z = new THREE.Vector3().crossVectors(x, y);
    orientations.push(new THREE.Quaternion().setFromRotationMatrix(
      new THREE.Matrix4().makeBasis(x, y, z)));
  }
}

export function snapCubie(cubie) {
  for (const axis of axes) cubie.position[axis] = Math.round(cubie.position[axis]) || 0;
  const closest = orientations.reduce((best, q) =>
    Math.abs(q.dot(cubie.quaternion)) > Math.abs(best.dot(cubie.quaternion)) ? q : best);
  cubie.quaternion.copy(closest);
  cubie.updateMatrix();
}

export function beginTurn(root, cubies, axis, layer, sign) {
  if (!axes.includes(axis) || ![-1, 0, 1].includes(layer) || ![-1, 1].includes(sign)) {
    throw new Error('Invalid layer turn');
  }
  const selected = cubies.filter(c => Math.round(c.position[axis]) === layer);
  if (selected.length !== 9) throw new Error('Layer must contain nine cubies');
  const pivot = new THREE.Group(); root.add(pivot);
  root.updateMatrixWorld(true);
  for (const cubie of selected) pivot.attach(cubie);
  return { pivot, selected, axis, layer, sign, root };
}

export function finishTurn(turn) {
  turn.pivot.rotation[turn.axis] = turn.sign * Math.PI / 2;
  turn.pivot.updateMatrixWorld(true);
  for (const cubie of turn.selected) { turn.root.attach(cubie); snapCubie(cubie); }
  turn.root.remove(turn.pivot);
  turn.root.updateMatrixWorld(true);
}

export function pickCube(raycaster, cubies) {
  for (const hit of raycaster.intersectObjects(cubies, true)) {
    const cubie = hit.object.userData.cubie;
    if (!cubie || !hit.face) continue;
    const normal = hit.face.normal.clone().transformDirection(hit.object.matrixWorld);
    const index = axes.findIndex(axis => Math.abs(normal[axis]) > .99);
    if (index < 0 || Math.round(cubie.position[axes[index]]) !== Math.sign(normal[axes[index]])) continue;
    normal.set(0, 0, 0).setComponent(index, Math.sign(
      hit.face.normal.clone().transformDirection(hit.object.matrixWorld).getComponent(index)));
    return { cubie, normal, point: hit.point.clone() };
  }
  // Narrow seams are still part of the toy's touch silhouette. If the ray
  // misses all visible faces, select the nearest grid cell on the outer box.
  const point = raycaster.ray.intersectBox(new THREE.Box3(
    new THREE.Vector3(-1.462, -1.462, -1.462), new THREE.Vector3(1.462, 1.462, 1.462)),
    new THREE.Vector3());
  if (!point) return null;
  let index = 0;
  for (let i=1; i<3; i++) if (Math.abs(point.getComponent(i)) > Math.abs(point.getComponent(index))) index=i;
  const normal = new THREE.Vector3().setComponent(index, Math.sign(point.getComponent(index)));
  const grid = point.clone().clampScalar(-1,1).round();
  const cubie = cubies.find(c => c.position.equals(grid));
  return cubie ? { cubie, normal, point } : null;
}

export function chooseTurn(hit, dx, dy, camera, width, height, threshold = 18) {
  if (Math.hypot(dx, dy) < threshold) return null;
  camera.updateMatrixWorld();
  const start = hit.point.clone().project(camera);
  let best = null;
  for (let i = 0; i < 3; i++) {
    if (Math.abs(hit.normal.getComponent(i)) > .5) continue;
    const tangent = new THREE.Vector3().crossVectors(basis[i], hit.normal);
    const end = hit.point.clone().addScaledVector(tangent, .25).project(camera);
    const sx = (end.x - start.x) * width / 2, sy = -(end.y - start.y) * height / 2;
    const length = Math.hypot(sx, sy);
    if (length < .5) continue;
    const dot = (sx * dx + sy * dy) / (length * Math.hypot(dx, dy));
    if (!best || Math.abs(dot) > best.score) best = {
      axis: axes[i], layer: Math.round(hit.cubie.position[axes[i]]),
      sign: dot > 0 ? 1 : -1, score: Math.abs(dot),
    };
  }
  return best && best.score >= .6 ? best : null;
}

export function createCube() {
  const root = new THREE.Group(), cubies = [];
  const box = new THREE.BoxGeometry(.92, .92, .92);
  const sticker = new THREE.PlaneGeometry(.79, .79);
  const black = new THREE.MeshLambertMaterial({ color: 0x111111 });
  const colors = [0xe53935, 0xff8c00, 0xffffff, 0xffe600, 0x2eaa4f, 0x1565c0];
  const materials = colors.map(color => new THREE.MeshBasicMaterial({ color }));
  const faces = [[0, 1], [0, -1], [1, 1], [1, -1], [2, 1], [2, -1]];
  for (let x = -1; x <= 1; x++) for (let y = -1; y <= 1; y++) for (let z = -1; z <= 1; z++) {
    const cubie = new THREE.Group(); cubie.position.set(x, y, z);
    cubie.userData.id = `${x},${y},${z}`;
    const body = new THREE.Mesh(box, black); body.userData.cubie = cubie; cubie.add(body);
    faces.forEach(([axis, side], i) => {
      if (cubie.position.getComponent(axis) !== side) return;
      const tile = new THREE.Mesh(sticker, materials[i]);
      const normal = new THREE.Vector3().setComponent(axis, side);
      tile.position.copy(normal).multiplyScalar(.462);
      tile.quaternion.setFromUnitVectors(new THREE.Vector3(0, 0, 1), normal);
      tile.userData.cubie = cubie; tile.userData.color = i;
      cubie.add(tile);
    });
    cubies.push(cubie); root.add(cubie);
  }
  return { root, cubies, dispose() {
    box.dispose(); sticker.dispose(); black.dispose(); materials.forEach(m => m.dispose());
    root.clear(); cubies.length = 0;
  } };
}

export function cubeSnapshot(cubies) {
  return cubies.map(c => ({ id: c.userData.id, position: c.position.toArray(),
    quaternion: c.quaternion.toArray(), colors: c.children.slice(1).map(s => s.userData.color) }));
}

export function applyNotation(cube, moves) {
  const faces = { R: ['x', 1, -1], L: ['x', -1, 1], U: ['y', 1, -1],
    D: ['y', -1, 1], F: ['z', 1, -1], B: ['z', -1, 1] };
  for (const move of moves) {
    if (!/^[RLUDFB](2|')?$/.test(move)) throw new Error('Invalid scramble move');
    const [axis, layer, sign] = faces[move[0]];
    for (let i = 0; i < (move.endsWith('2') ? 2 : 1); i++) {
      finishTurn(beginTurn(cube.root, cube.cubies, axis, layer, move.endsWith("'") ? -sign : sign));
    }
  }
}

export function isCubeSolved(cube) {
  const colors = new Map();
  for (const cubie of cube.cubies) for (const tile of cubie.children.slice(1)) {
    const normal = new THREE.Vector3(0, 0, 1).applyQuaternion(tile.quaternion)
      .applyQuaternion(cubie.quaternion).round().toArray().join(',');
    if (colors.has(normal) && colors.get(normal) !== tile.userData.color) return false;
    colors.set(normal, tile.userData.color);
  }
  return colors.size === 6;
}
