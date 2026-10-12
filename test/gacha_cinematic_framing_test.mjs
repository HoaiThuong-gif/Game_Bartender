import test from 'node:test';
import assert from 'node:assert/strict';
import { PerspectiveCamera, Vector3 } from 'three';
import { displayCorners, fitCameraDistance, positionCamera } from '../assets/gacha3d/framing.mjs';

for (const aspect of [.75, 1.1, 1.7]) {
  for (const size of [new Vector3(1.85, .65, 1.85), new Vector3(.5, 1.85, .5)]) {
    test(`item and entire pedestal fit at aspect ${aspect}, height ${size.y}`, () => {
      const camera = new PerspectiveCamera(38, aspect, .01, 100);
      const target = new Vector3(0, .08 + size.y * .40, 0);
      const distance = fitCameraDistance(camera, target, size);
      assert.ok(Number.isFinite(distance) && distance > 0);
      positionCamera(camera, target, distance);
      const extent = Math.max(...displayCorners(size).map(corner => {
        const p = corner.project(camera);
        return Math.max(Math.abs(p.x), Math.abs(p.y));
      }));
      assert.ok(extent > .70 && extent <= .79, 'use the viewport without excessive empty space');
      for (const zoom of [.90, 1, 1.18, 1.30]) {
        positionCamera(camera, target, distance * zoom);
        for (const corner of displayCorners(size)) {
          const projected = corner.project(camera);
          assert.ok(Math.abs(projected.x) < 1 && Math.abs(projected.y) < 1,
            `cropped at zoom ${zoom}: ${projected.x}, ${projected.y}`);
          assert.ok(projected.z > -1 && projected.z < 1);
        }
      }
    });
  }
}
