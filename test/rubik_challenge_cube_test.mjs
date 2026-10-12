import test from 'node:test';
import assert from 'node:assert/strict';
import {createCube, applyNotation, isCubeSolved, cubeSnapshot} from '../assets/rubik/interactive-cube.mjs';
test('shared notation gives identical cubes and inverse solves them', () => {
  const a = createCube(), b = createCube();
  const moves = ['R','U',"F'",'L2','D','B2',"R'",'U2'];
  assert.equal(isCubeSolved(a), true);
  applyNotation(a,moves); applyNotation(b,moves);
  assert.deepEqual(cubeSnapshot(a.cubies),cubeSnapshot(b.cubies));
  assert.equal(isCubeSolved(a),false);
  applyNotation(a,moves.toReversed().map(m => m.endsWith('2') ? m : m.endsWith("'") ? m[0] : `${m}'`));
  assert.equal(isCubeSolved(a),true);
  assert.throws(() => applyNotation(b,['invalid']));
  a.dispose(); b.dispose();
});
