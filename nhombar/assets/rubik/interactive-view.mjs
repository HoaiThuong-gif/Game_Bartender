import * as THREE from 'three';

// The two contact points define translation and twist in camera coordinates.
export function rotateView(camera, before, after, target = new THREE.Vector3()) {
  const dx = (after[0].x + after[1].x - before[0].x - before[1].x) / 2;
  const dy = (after[0].y + after[1].y - before[0].y - before[1].y) / 2;
  const oldX = before[1].x - before[0].x, oldY = before[1].y - before[0].y;
  const newX = after[1].x - after[0].x, newY = after[1].y - after[0].y;
  const twist = Math.min(Math.hypot(oldX, oldY), Math.hypot(newX, newY)) > 8
    ? Math.atan2(oldX * newY - oldY * newX, oldX * newX + oldY * newY) : 0;
  const right = new THREE.Vector3(1, 0, 0).applyQuaternion(camera.quaternion);
  const up = new THREE.Vector3(0, 1, 0).applyQuaternion(camera.quaternion);
  const towardsCamera = new THREE.Vector3(0, 0, 1).applyQuaternion(camera.quaternion);
  const rotation = new THREE.Quaternion().setFromAxisAngle(towardsCamera, twist)
    .multiply(new THREE.Quaternion().setFromAxisAngle(up, -dx * .008))
    .multiply(new THREE.Quaternion().setFromAxisAngle(right, -dy * .008)).normalize();
  camera.position.sub(target).applyQuaternion(rotation).add(target);
  // camera.up can be a lookAt reference rather than an orthogonal camera axis
  // (notably in the initial tilted view). Rotate the actual camera up axis.
  camera.up.copy(up).applyQuaternion(rotation).normalize();
  camera.lookAt(target);
  camera.updateMatrixWorld(true);
}
