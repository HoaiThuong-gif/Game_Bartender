import { Vector3 } from 'three';

export function positionCamera(camera, target, distance) {
  camera.position.set(distance * .12, target.y + distance * .35, distance * .94);
  camera.lookAt(target);
  camera.updateMatrixWorld();
}

// Fitting width/height alone misses perspective foreshortening of a wide,
// shallow item or pedestal. Project the whole bounding box, including its depth.
export function displayCorners(size) {
  const x = Math.max(size.x, 2.34) / 2;
  const z = Math.max(size.z, 2.34) / 2;
  return [-x, x].flatMap(a => [-.09, .08 + size.y].flatMap(b =>
    [-z, z].map(c => new Vector3(a, b, c))));
}

export function fitCameraDistance(camera, target, size) {
  const corners = displayCorners(size);
  function extentAt(distance) {
    positionCamera(camera, target, distance);
    let extent = 0;
    for (const corner of corners) {
      const projected = corner.clone().project(camera);
      extent = Math.max(extent, Math.abs(projected.x), Math.abs(projected.y));
    }
    return extent;
  }
  let low = Math.max(size.x, size.y, size.z, 2.34), high = low;
  for (let i = 0; i < 12 && extentAt(high) > .78; i++) {
    low = high; high *= 1.5;
  }
  // A direct multiplication by the projected extent can overshoot badly when
  // the near edge is close to the camera. Search for the nearest safe framing.
  for (let i = 0; i < 18; i++) {
    const middle = (low + high) / 2;
    if (extentAt(middle) > .78) low = middle;
    else high = middle;
  }
  positionCamera(camera, target, high);
  return high;
}
