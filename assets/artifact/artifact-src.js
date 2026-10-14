import * as THREE from 'three';

const bridge = (type, extra = {}) => window.ArtifactGame?.postMessage(JSON.stringify({
  type, epoch: snapshot?.epoch, revision: snapshot?.revision, ...extra,
}));
let snapshot = null;
let disposed = false, active = true, waiting = false, raf = 0;
let motion = null, openReported = false, feedback = null;
let yaw = .24, pitch = .18, distance = 7, fitDistance = 7;
let userZoomed = false;
let gesture = null, pinch = null, multiTouch = false;
const pointers = new Map();
const listeners = [];
const geometries = new Set(), materials = new Set(), textures = new Set();
let pieces = [], clues = [], lid = null, core = null;
let coreLight = null, selected = null;
let camFollower = null;
const isMongSen = () => snapshot?.assembly === 'mong-sen';
const isCraft = () => snapshot?.assembly?.startsWith('craft-');

window.addEventListener('error', () => bridge('error'));
window.addEventListener('unhandledrejection', () => bridge('error'));

const scene = new THREE.Scene();
scene.background = new THREE.Color(0xece0c9);
const camera = new THREE.PerspectiveCamera(38, 1, .1, 60);
const renderer = new THREE.WebGLRenderer({ antialias: false, powerPreference: 'low-power' });
renderer.setPixelRatio(Math.min(devicePixelRatio || 1, 1.5));
renderer.outputColorSpace = THREE.SRGBColorSpace;
const canvas = renderer.domElement;
document.body.appendChild(canvas);
const root = new THREE.Group();
scene.add(root);
scene.add(new THREE.HemisphereLight(0xfff5dd, 0x5a4932, 2.6));
const sunlight = new THREE.DirectionalLight(0xffe7be, 3.2);
sunlight.position.set(-3, 6, 5);
scene.add(sunlight);
const fill = new THREE.DirectionalLight(0xf1e8d4, 1.1);
fill.position.set(4, 1, -4);
scene.add(fill);
const raycaster = new THREE.Raycaster();

function listen(target, type, callback, options) {
  target.addEventListener(type, callback, options);
  listeners.push(() => target.removeEventListener(type, callback, options));
}

function material(color, metalness = .2, roughness = .75) {
  const value = new THREE.MeshStandardMaterial({ color, metalness, roughness });
  materials.add(value);
  return value;
}

function mesh(parent, geometry, mat, position = [0, 0, 0]) {
  geometries.add(geometry);
  materials.add(mat);
  const value = new THREE.Mesh(geometry, mat);
  value.position.set(...position);
  parent.add(value);
  return value;
}

function texture(width, height, draw) {
  const image = document.createElement('canvas');
  image.width = width; image.height = height;
  draw(image.getContext('2d'), width, height);
  const value = new THREE.CanvasTexture(image);
  value.colorSpace = THREE.SRGBColorSpace;
  value.anisotropy = 1;
  textures.add(value);
  return value;
}

function painted(parent, width, height, map, position) {
  const mat = new THREE.MeshBasicMaterial({ map, transparent: true, depthWrite: false });
  return mesh(parent, new THREE.PlaneGeometry(width, height), mat, position);
}

function symbol(context, index, x, y, radius, color = '#f9df9a') {
  context.save(); context.translate(x, y);
  context.strokeStyle = color; context.fillStyle = color;
  context.lineWidth = Math.max(2, radius * .12);
  context.lineCap = 'round'; context.lineJoin = 'round';
  context.beginPath();
  if (index === 0) {
    context.arc(0, 0, radius * .36, 0, Math.PI * 2); context.stroke();
    for (let i = 0; i < 8; i++) {
      const a = i * Math.PI / 4;
      context.beginPath();
      context.moveTo(Math.cos(a) * radius * .58, Math.sin(a) * radius * .58);
      context.lineTo(Math.cos(a) * radius * .88, Math.sin(a) * radius * .88);
      context.stroke();
    }
  } else if (index === 1) {
    context.moveTo(0, radius * .85); context.lineTo(0, -radius * .85);
    context.moveTo(-radius * .15, 0); context.lineTo(radius * .15, 0);
    context.moveTo(-radius * .15, radius * .5); context.lineTo(radius * .15, radius * .5);
    context.stroke();
    context.beginPath(); context.ellipse(radius * .36, -radius * .45, radius * .4, radius * .15, -.6, 0, Math.PI * 2); context.fill();
    context.beginPath(); context.ellipse(-radius * .36, radius * .1, radius * .4, radius * .15, .6, 0, Math.PI * 2); context.fill();
  } else if (index === 2) {
    for (let row = -1; row <= 1; row++) {
      context.beginPath();
      for (let i = 0; i <= 20; i++) {
        const u = i / 20;
        const px = (u * 2 - 1) * radius * .9;
        const py = Math.sin(u * Math.PI * 2) * radius * .17 + row * radius * .45;
        if (!i) context.moveTo(px, py); else context.lineTo(px, py);
      }
      context.stroke();
    }
  } else {
    context.moveTo(-radius * .9, radius * .65);
    context.lineTo(-radius * .25, -radius * .65);
    context.lineTo(radius * .12, radius * .05);
    context.lineTo(radius * .45, -radius * .4);
    context.lineTo(radius * .9, radius * .65);
    context.closePath(); context.stroke();
  }
  context.restore();
}

function textMap(text, color = '#f2dba4', size = 40) {
  return texture(256, 128, (ctx, w, h) => {
    ctx.fillStyle = color; ctx.font = `bold ${size}px sans-serif`;
    ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
    ctx.fillText(text, w / 2, h / 2);
  });
}

function releaseArtifact() {
  root.clear();
  geometries.forEach(value => value.dispose()); geometries.clear();
  materials.forEach(value => value.dispose()); materials.clear();
  textures.forEach(value => value.dispose()); textures.clear();
  pieces = []; clues = [];
  coreLight = null; lid = null; core = null;
  camFollower = null;
}

function addPattern(parent, radius, y, bronze, segments) {
  const band = mesh(parent, new THREE.TorusGeometry(radius, .035, 4, segments), bronze, [0, y, 0]);
  band.rotation.x = Math.PI / 2;
  for (let i = 0; i < 12; i++) {
    const angle = i * Math.PI / 6;
    const mark = mesh(parent, new THREE.BoxGeometry(.08, .13, .035), bronze,
      [Math.sin(angle) * radius, y - .1, Math.cos(angle) * radius]);
    mark.rotation.y = angle;
  }
}

// Each moving piece has its own local axis and a bounded, reversible path.
function register(kind, index, object, mode, highlight) {
  const definition = snapshot.parts.find(part => part.kind === kind && part.index === index);
  const piece = { kind, index, object, mode, axis: definition.axis, travel: definition.travel, highlight, value: 0,
    origin: object.position.clone(), baseColor: highlight.color.getHex() };
  object.userData = { kind, index };
  pieces.push(piece);
  return piece;
}

function engraving(parent, target, number, position, rotation = 0) {
  const map = texture(192, 96, (ctx, w, h) => {
    ctx.fillStyle = '#38291e'; ctx.textAlign = 'left'; ctx.font = 'bold 34px serif';
    ctx.fillText(`${number}`, 8, 60);
    symbol(ctx, target, 120, 48, 32, '#d5b274');
  });
  const mark = painted(parent, .48, .24, map, position);
  mark.rotation.y = rotation;
  return mark;
}

function makeArtifact(data) {
  releaseArtifact();
  renderer.shadowMap.enabled = data.assembly === 'mong-sen';
  sunlight.castShadow = renderer.shadowMap.enabled;
  if (data.assembly === 'mong-sen') { makeMongSen(data); return; }
  if (isCraft()) { makeCraft(data); return; }
  const cube = data.shape === 'cube', cylinder = data.shape === 'cylinder';
  const radius = cylinder ? 1.48 : 1.65, segments = cylinder ? 32 : 6;
  const wood = material(0x75462c, .05, .9);
  const woodEnd = material(0x9a633a, .05, .85);
  const bronze = material(0xa87b3f, .65, .55);
  const dark = material(0x3d3326, .5, .7);
  if (cube) {
    mesh(root, new THREE.BoxGeometry(3, .18, 3), wood, [0, -1.43, 0]);
    for (const sign of [-1, 1]) {
      mesh(root, new THREE.BoxGeometry(3, 2.7, .14), wood, [0, -.05, sign * 1.43]);
      mesh(root, new THREE.BoxGeometry(.14, 2.7, 2.7), wood, [sign * 1.43, -.05, 0]);
      for (const y of [-1.35, 1.22]) {
        mesh(root, new THREE.BoxGeometry(3.05, .07, .06), bronze, [0, y, sign * 1.51]);
      }
    }
  } else {
    const wall = mesh(root, new THREE.CylinderGeometry(radius, radius, 2.7,
      segments, 1, true), wood, [0, -.05, 0]);
    wall.material.side = THREE.DoubleSide;
    mesh(root, new THREE.CylinderGeometry(radius, radius, .18, segments), wood, [0, -1.43, 0]);
    addPattern(root, radius + .015, -1.28, bronze, segments);
  }
  const symbols = [0, 1, 2, 3].map(i => texture(128, 128,
    (ctx, w, h) => symbol(ctx, i, w / 2, h / 2, 48)));
  const count = data.targets.length;
  const positions = count === 2 ? [[-.7, .35], [.7, .35]]
    : [[-.73, .57], [.73, .57], [0, -.55]];
  for (let i = 0; i < count; i++) {
    const anchor = new THREE.Group(); root.add(anchor);
    const rimMat = material(0xb28c4d, .65, .5);
    let disc;
    const y = count === 2 ? .65 - i * 1.1 : .75 - i * .73;
    const sideAngle = [-Math.PI / 6, Math.PI / 6, Math.PI / 2][i];
    if (cylinder) {
      anchor.position.y = y;
      disc = new THREE.Group(); anchor.add(disc);
      const band = mesh(disc, new THREE.CylinderGeometry(1.54, 1.54, .23, 32, 1, true), rimMat);
      band.material.side = THREE.DoubleSide;
      for (let k = 0; k < 4; k++) {
        const angle = k * Math.PI / 2;
        const glyph = painted(disc, .24, .24, symbols[k],
          [Math.sin(angle) * 1.555, 0, Math.cos(angle) * 1.555]);
        glyph.rotation.y = angle;
      }
      const pointer = mesh(anchor, new THREE.ConeGeometry(.06, .12, 3), bronze, [0, .22, 1.57]);
      pointer.rotation.z = Math.PI;
      painted(anchor, .25, .13, textMap(`${i + 1}`), [.29, .19, 1.55]);
    } else {
      if (cube) anchor.position.set(positions[i][0], positions[i][1], 1.515);
      else {
        anchor.position.set(Math.sin(sideAngle) * 1.443, .4, Math.cos(sideAngle) * 1.443);
        anchor.rotation.y = sideAngle;
      }
      mesh(anchor, new THREE.TorusGeometry(.345, .025, 6, 32), bronze, [0, 0, .06]);
      disc = new THREE.Group(); anchor.add(disc);
      const plate = mesh(disc, new THREE.CylinderGeometry(.32, .32, .08, 24), rimMat, [0, 0, .05]);
      plate.rotation.x = Math.PI / 2;
      for (let k = 0; k < 4; k++) {
        const angle = k * Math.PI / 2;
        const glyph = painted(disc, .155, .155, symbols[k],
          [-Math.sin(angle) * .215, Math.cos(angle) * .215, .097]);
        glyph.rotation.z = angle;
      }
      const pointer = mesh(anchor, new THREE.ConeGeometry(.05, .1, 3), bronze, [0, .39, .08]);
      pointer.rotation.z = Math.PI;
      painted(anchor, .27, .14, textMap(`${i + 1}`), [0, .53, .09]);
    }
    // The fixed rim and pointer also select this ring without moving the shell.
    anchor.userData = { kind: 'ring', index: i };
    register('ring', i, disc, 'rotation', rimMat);

    const rail = new THREE.Group(); root.add(rail);
    if (cylinder) rail.position.set(0, y - .33, 1.51);
    else if (cube) rail.position.set(positions[i][0], positions[i][1] - .48, 1.52);
    else {
      rail.position.set(Math.sin(sideAngle) * 1.447, -.22, Math.cos(sideAngle) * 1.447);
      rail.rotation.y = sideAngle;
    }
    rail.userData = { kind: 'slider', index: i };
    mesh(rail, new THREE.BoxGeometry(.61, .23, .055), dark);
    const bolt = new THREE.Group(); rail.add(bolt);
    const boltMat = material(0xb69153, .65, .5);
    mesh(bolt, new THREE.BoxGeometry(.59, .21, .09), boltMat, [0, 0, .08]);
    mesh(bolt, new THREE.BoxGeometry(.09, .27, .13), bronze, [.12, 0, .15]);
    painted(bolt, .38, .16, textMap(`${i + 1} ${cylinder ? '↗' : '→'}`), [-.06, 0, .132]);
    if (cylinder) {
      const shaft = mesh(bolt, new THREE.CylinderGeometry(.045, .045, .65, 8), bronze, [0, 0, -.25]);
      shaft.rotation.x = Math.PI / 2;
    } else {
      mesh(rail, new THREE.BoxGeometry(1.38, .025, .05), bronze, [.37, -.15, .05]);
    }
    register('slider', i, bolt, 'translation', boltMat);
    if (i + 1 < count) {
      const clue = engraving(rail, data.targets[i + 1], i + 2, [0, 0, .04]);
      clues.push({ mark: clue, requires: i });
    }
  }
  // Only the first clue is exposed on the assembled object. Later engravings
  // sit in recesses under their own moving covers, rather than on an answer board.
  engraving(root, data.targets[0], 1, cube ? [-.95, -1.17, 1.515]
    : cylinder ? [-.902, -1.15, 1.186] : [-.725, -1.17, 1.256],
    cube ? 0 : cylinder ? -.65 : -Math.PI / 6);

  const joint = new THREE.Group(); root.add(joint);
  const latchMat = material(0xa2834e, .65, .5);
  let latch;
  if (cube) {
    joint.position.set(1.54, .98, .55); joint.rotation.y = Math.PI / 2;
    latch = new THREE.Group(); joint.add(latch);
    const axle = mesh(joint, new THREE.CylinderGeometry(.12, .12, .12, 12), dark, [0, 0, .04]);
    axle.rotation.x = Math.PI / 2;
    mesh(latch, new THREE.BoxGeometry(.18, .57, .13), latchMat, [0, .2, .1]);
    painted(latch, .23, .2, textMap('↻'), [0, .29, .175]);
  } else {
    joint.position.y = 1.17;
    latch = new THREE.Group(); joint.add(latch);
    const band = mesh(latch, new THREE.CylinderGeometry(radius + .07, radius + .07, .15, 32, 1, true), latchMat);
    band.material.side = THREE.DoubleSide;
    for (const angle of [0, Math.PI / 2, Math.PI, -Math.PI / 2]) {
      const handle = mesh(latch, new THREE.BoxGeometry(.24, .23, .18), bronze,
        [Math.sin(angle) * (radius + .07), 0, Math.cos(angle) * (radius + .07)]);
      handle.rotation.y = angle;
    }
    painted(latch, .28, .16, textMap('↻'), [0, 0, radius + .18]);
  }
  joint.userData = { kind: 'joint', index: 0 };
  register('joint', 0, latch, 'rotation', latchMat);

  lid = new THREE.Group(); root.add(lid);
  const capMat = material(0x9a633a, .1, .85);
  if (cube) mesh(lid, new THREE.BoxGeometry(3.12, .18, 3.12), capMat, [0, 1.4, 0]);
  else mesh(lid, new THREE.CylinderGeometry(radius + .04, radius + .04, .18, segments), capMat, [0, 1.4, 0]);
  const seal = painted(lid, .7, .7, textMap(cube || cylinder ? '↑' : '→', '#e4c591', 74), [0, 1.498, 0]);
  seal.rotation.x = -Math.PI / 2;
  const handle = mesh(lid, new THREE.TorusGeometry(.2, .045, 6, 20), bronze, [0, 1.58, 0]);
  register('lid', 0, lid, 'lid', capMat);

  core = new THREE.Group(); root.add(core);
  const jade = material(0x76b79a, .3, .25);
  jade.emissive.setHex(0x377b60); jade.emissiveIntensity = .35;
  mesh(core, new THREE.IcosahedronGeometry(.48, 0), jade, [0, .45, 0]);
  mesh(core, new THREE.CylinderGeometry(.055, .055, .55, 8), bronze, [0, .94, 0]);
  mesh(core, new THREE.TorusGeometry(.12, .03, 6, 16), jade, [0, 1.18, 0]);
  register('core', 0, core, 'translation', jade);
  coreLight = new THREE.PointLight(0xb7edb8, .5, 4); core.add(coreLight);
  coreLight.position.y = .7;
  const ground = mesh(root, new THREE.CircleGeometry(2.1, 32),
    new THREE.MeshBasicMaterial({ color: 0x6c5136, transparent: true, opacity: .12, depthWrite: false }), [0, -1.54, 0]);
  ground.rotation.x = -Math.PI / 2;
  pieces.forEach(piece => setPiece(piece, stateValue(piece, data)));
  updateReveals();
}

// Thick extruded arcs provide inner walls and actual windows, including the
// bayonet exits. The moving hardware lives in open channels outside the cavity.
function craftKit() {
  const grain = texture(128, 128, (ctx, w, h) => {
    ctx.fillStyle = '#bd9669'; ctx.fillRect(0, 0, w, h);
    for (let i = 0; i < 48; i++) {
      ctx.strokeStyle = i % 3 ? '#99704433' : '#edd1a344';
      ctx.beginPath(); ctx.moveTo(0, i * 3);
      ctx.bezierCurveTo(40, i * 3 + 4, 90, i * 3 - 3, w, i * 3); ctx.stroke();
    }
  });
  const timber = color => { const m = material(color, .03, .8); m.map = grain; return m; };
  const wood = timber(0xc19a66), end = timber(0x795331);
  const bronze = material(0xb18a4c, .72, .42), dark = material(0x454638, .4, .7);
  const unit = new THREE.BoxGeometry(1, 1, 1);
  const box = (p, size, mat, pos = [0, 0, 0]) => {
    const b = mesh(p, unit, mat, pos); b.scale.set(...size); return b;
  };
  const group = (pos = [0, 0, 0], parent = root) => {
    const g = new THREE.Group(); g.position.set(...pos); parent.add(g); return g;
  };
  const arc = (p, outer, inner, height, y, mat, start = 0, length = Math.PI * 2, sides = 32) => {
    const shape = new THREE.Shape(), n = Math.max(2, Math.ceil(sides * length / (Math.PI * 2)));
    for (let i = 0; i <= n; i++) {
      const a = start + length * i / n;
      if (i) shape.lineTo(outer * Math.cos(a), outer * Math.sin(a));
      else shape.moveTo(outer * Math.cos(a), outer * Math.sin(a));
    }
    for (let i = n; i >= 0; i--) {
      const a = start + length * i / n;
      shape.lineTo(inner * Math.cos(a), inner * Math.sin(a));
    }
    shape.closePath();
    const geo = new THREE.ExtrudeGeometry(shape, {depth: height, bevelEnabled: false, steps: 1});
    geo.rotateX(Math.PI / 2); geo.translate(0, height / 2, 0);
    return mesh(p, geo, mat, [0, y, 0]);
  };
  const disk = (p, radius, height, y, mat, sides = 32) =>
    mesh(p, new THREE.CylinderGeometry(radius, radius, height, sides), mat, [0, y, 0]);
  const plate = (p, w, h, depth, mat, pos, holes = []) => {
    const s = new THREE.Shape();
    s.moveTo(-w/2, -h/2); s.lineTo(w/2, -h/2); s.lineTo(w/2, h/2); s.lineTo(-w/2, h/2); s.closePath();
    for (const points of holes) {
      const hole = new THREE.Path();
      points.forEach(([x, y], i) => i ? hole.lineTo(x, y) : hole.moveTo(x, y));
      hole.closePath(); s.holes.push(hole);
    }
    const geo = new THREE.ExtrudeGeometry(s, {depth, bevelEnabled: true, bevelSize: .008, bevelThickness: .008, bevelSegments: 1, steps: 1});
    geo.translate(0, 0, -depth/2); return mesh(p, geo, mat, pos);
  };
  const part = (i, pos = [0, 0, 0], parent = root) => {
    const g = group(pos, parent), mat = timber(i % 2 ? 0xbd955e : 0xd5b480);
    const d = snapshot.parts[i]; register('piece', i, g, d.rotation ? 'rotation' : 'translation', mat);
    return {g, mat};
  };
  const tag = (p, text, pos, turn = 0) => {
    const mark = painted(p, .36, .19, textMap(text, '#3d2c1a', 52), pos);
    mark.rotation.y = turn; return mark;
  };
  const rail = (pos, length, axis = 'x', clearance = .16) => {
    for (const side of [-1, 1]) {
      const size = axis === 'x' ? [length, .045, .16] : [.045, length, .16];
      const offset = axis === 'x' ? [0, side * clearance, 0] : [side * clearance, 0, 0];
      box(root, size, bronze, pos.map((v, i) => v + offset[i]));
    }
  };
  const gem = (i, y, shuttle = false) => {
    const {g, mat} = part(i, [0, y, 0]); mat.color.setHex(0x529779); mat.map = null;
    const stone = mesh(g, new THREE.IcosahedronGeometry(.27, 1), mat);
    if (shuttle) stone.scale.set(1.9, .7, .7);
    disk(root, .40, .09, y - .28, end, 16);
    core = g;
  };
  // A recessed pivot and a narrow bar, with a separate shaft and stop studs.
  const lever = (i, pos, length = .56) => {
    mesh(root, new THREE.TorusGeometry(.14, .035, 6, 16), dark, pos);
    const {g, mat} = part(i, pos);
    const shaft = mesh(g, new THREE.CylinderGeometry(.075, .075, .18, 12), bronze);
    shaft.rotation.x = Math.PI / 2;
    box(g, [.15, length, .13], mat, [0, length / 2 - .06, .07]);
    tag(g, '↻', [0, length - .10, .145]);
    return g;
  };
  return {wood, end, bronze, dark, box, group, arc, disk, plate, part, tag, rail, gem, lever};
}

function makeCraft(data) {
  const k = craftKit();
  if (data.level === 2) makeTrucTang(k);
  if (data.level === 3) makeSongNem(k);
  if (data.level === 4) makeAmVang(k);
  if (data.level === 5) makeDetBiMat(k);
  pieces.sort((a, b) => a.index - b.index);
  pieces.forEach(piece => setPiece(piece, stateValue(piece, data)));
}

function makeTrucTang(k) {
  const {wood, end, bronze, dark, box, arc, disk, part, tag, gem} = k;
  disk(root, 1.05, .18, -1.16, end);
  arc(root, 1.0, .84, 1.76, -.18, wood);
  // Top collar is separated from the wall and has two real exit windows.
  arc(root, 1.04, .83, .18, -.98, bronze);
  const collar = part(1);
  for (const start of [-Math.PI / 2 + .17, Math.PI / 2 + .17])
    arc(collar.g, 1.15, 1.015, .16, .87, collar.mat, start, Math.PI - .34);
  for (const x of [-1.14, 1.14]) box(collar.g, [.18, .20, .18], collar.mat, [x, .87, 0]);
  for (const x of [-.11, .11]) box(collar.g, [.08, .24, .15], bronze, [x, .87, 1.30]);
  for (const y of [.77, .97]) box(collar.g, [.14, .04, .15], bronze, [0, y, 1.30]);
  // A pin travels in a gap between the two fixed cheeks, into the collar lug.
  for (const x of [-.13, .13]) box(root, [.075, .24, .52], bronze, [x, .87, 1.12]);
  const pin = part(0);
  box(pin.g, [.12, .12, .65], pin.mat, [0, .87, 1.22]);
  box(pin.g, [.32, .22, .12], pin.mat, [0, .87, 1.58]); tag(pin.g, '↓', [0, .87, 1.65]);
  const lift = part(2), slide = part(3, [0, 0, 0], lift.g);
  disk(slide.g, .99, .16, 1.02, slide.mat);
  for (const x of [-1.065, 1.065]) box(slide.g, [.23, .09, .15], bronze, [x, .73, 0]);
  const handle = mesh(slide.g, new THREE.TorusGeometry(.20, .045, 6, 24), lift.mat, [0, 1.20, 0]);
  handle.userData = {kind: 'piece', index: 2};
  const mark = tag(slide.g, '⇥', [0, 1.108, .45]); mark.rotation.x = -Math.PI / 2;
  // Alignment marks on a fixed cheek and the rotating ring teach the bayonet.
  tag(root, '│', [.44, .88, 1.05]); tag(collar.g, '│', [1.16, .87, 0], Math.PI / 2);
  gem(4, -.67);
}

function makeSongNem(k) {
  const {wood, end, bronze, box, arc, disk, part, tag, rail, gem, lever} = k;
  // The hexagon is a closed thick-walled cavity; all lockwork sits outside it.
  disk(root, 1.42, .17, -.91, end, 6);
  arc(root, 1.40, 1.20, 1.13, -.28, wood, 0, Math.PI * 2, 6);
  for (const x of [-1.12, 1.12]) {
    box(root, [.18, 1.38, .20], end, [x, -.10, 1.45]);
    box(root, [.24, .12, .24], bronze, [x, -.72, 1.45]);
  }
  // Bridge behind two wedge shoulders: outward travel clears the end stops.
  const bridge = part(2);
  box(bridge.g, [2.28, .18, .22], bridge.mat, [0, .04, 1.48]);
  box(bridge.g, [.42, .28, .16], bridge.mat, [0, .04, 1.66]);
  tag(bridge.g, '↓', [0, .04, 1.75]);
  for (let i = 0; i < 2; i++) {
    const sign = i ? 1 : -1, wedge = part(i);
    box(wedge.g, [.55, .22, .16], wedge.mat, [sign * 1.10, .04, 1.70]);
    box(wedge.g, [.10, .33, .24], bronze, [sign * 1.31, .04, 1.70]);
    rail([sign * 1.16, .04, 1.55], 1.06);
    tag(wedge.g, sign < 0 ? '←' : '→', [sign * 1.08, .04, 1.79]);
  }
  lever(3, [0, .05, 1.26], .60);
  const slider = part(4);
  for (const x of [-.515, .515]) box(slider.g, [.81, .17, .16], slider.mat, [x, .63, 1.46]);
  box(slider.g, [.24, .07, .16], bronze, [0, .745, 1.46]);
  box(slider.g, [.18, .32, .25], bronze, [.82, .63, 1.46]);
  // This upright tongue occupies the front cap socket until pulled sideways.
  box(slider.g, [.12, .20, .35], bronze, [.64, .72, 1.24]);
  rail([0, .63, 1.38], 3.2); tag(slider.g, '→', [.78, .63, 1.60]);
  const cap = part(5);
  disk(cap.g, 1.42, .17, .53, cap.mat, 6);
  // A socket of four separate walls rather than a shaft through a solid lid.
  for (const z of [1.07, 1.40]) box(cap.g, [.31, .20, .045], end, [.64, .72, z]);
  for (const x of [.48, .80]) box(cap.g, [.045, .20, .36], end, [x, .72, 1.235]);
  for (const x of [-.85, .85]) {
    box(root, [.10, .10, 3.3], bronze, [x, .34, -.8]);
    box(cap.g, [.16, .10, .70], bronze, [x, .45, 0]);
  }
  const seal = tag(cap.g, '⇧', [0, .62, 0]); seal.rotation.x = -Math.PI / 2;
  gem(6, -.47);
}

function makeAmVang(k) {
  const {wood, end, bronze, dark, box, arc, disk, plate, part, tag, rail, gem, lever} = k;
  disk(root, 1.17, .15, -.84, end);
  disk(root, .32, .18, -1.0, bronze, 16);
  // Three fixed feet carry the rotating collar; their paths leave both the
  // rear pin and the front descending shoulder unobstructed.
  for (const angle of [-Math.PI / 3, Math.PI / 3, Math.PI]) {
    const footSupport = box(root, [1.70, .08, .12], bronze,
      [Math.cos(angle) * .85, -1.11, Math.sin(angle) * .85]);
    footSupport.rotation.y = -angle;
  }
  arc(root, 1.22, 1.05, .42, -.56, wood);
  arc(root, 1.38, 1.20, .55, -.07, bronze);
  arc(root, 1.48, 1.30, .28, .38, bronze);
  addPattern(root, 1.49, .48, bronze, 32);
  // Underside pin and collar are below the storage floor. No ground plane
  // hides them: the player can orbit beneath the drum to find the rear notch.
  const bottom = part(0);
  box(bottom.g, [.14, .13, .65], bottom.mat, [0, -1.06, -1.34]);
  box(bottom.g, [.34, .20, .13], bronze, [0, -1.06, -1.67]);
  tag(bottom.g, '↓', [0, -1.06, -1.745], Math.PI);
  for (const x of [-.14, .14]) box(root, [.09, .25, .47], bronze, [x, -1.06, -1.31]);
  const foot = part(1);
  // A window initially at the side rotates to the front rod's shoulder.
  arc(foot.g, 1.80, 1.50, .14, -.99, foot.mat, Math.PI + .50, Math.PI * 2 - 1.0);
  // A real bore in the rear lug accepts the pin without crossing solid wood.
  for (const x of [-.12, .12]) box(foot.g, [.08, .22, .12], foot.mat, [x, -1.06, -1.49]);
  for (const y of [-1.16, -.96]) box(foot.g, [.16, .04, .12], foot.mat, [0, y, -1.49]);
  const rod = part(2);
  box(rod.g, [.12, 1.42, .13], rod.mat, [.55, -.18, 1.71]);
  box(rod.g, [.30, .13, .30], bronze, [.55, -.86, 1.60]);
  box(rod.g, [.30, .20, .17], rod.mat, [.55, -.64, 1.75]);
  // Guide cheeks stop short of the shoulder and the movable panel.
  for (const x of [.40, .70]) box(root, [.07, .65, .15], dark, [x, -.43, 1.71]);
  const cover = part(3);
  plate(cover.g, 1.65, .66, .13, cover.mat, [0, .25, 1.68],
    [[[.45,-.31],[.65,-.31],[.65,.31],[.45,.31]]]);
  tag(cover.g, '←', [-.35, .25, 1.76]); rail([0, .25, 1.56], 2.9, 'x', .38);
  lever(4, [0, .20, 1.48], .50);
  const upper = part(5);
  box(upper.g, [1.55, .13, .13], upper.mat, [.25, .78, 1.54]);
  box(upper.g, [.16, .28, .23], bronze, [.97, .78, 1.54]);
  // Vertical tooth on the cam blocks the upper pin's notch until rotated.
  for (const x of [-.11, .11]) box(upper.g, [.06, .19, .16], bronze, [x, .66, 1.54]);
  rail([.35, .78, 1.44], 2.4); tag(upper.g, '→', [.95, .78, 1.67]);
  const latch = part(6);
  box(latch.g, [.26, .14, .40], latch.mat, [0, .84, 1.28]);
  for (const y of [.68, .92]) box(latch.g, [.28, .06, .30], bronze, [0, y, 1.54]);
  box(latch.g, [.28, .30, .07], bronze, [0, .80, 1.72]);
  // Latch slides inside its own top socket; side pin crosses its rear lug.
  for (const x of [-.18, .18]) box(root, [.06, .18, .75], bronze, [x, .82, 1.29]);
  const cap = part(7);
  disk(cap.g, 1.50, .16, .67, cap.mat);
  arc(cap.g, .73, .69, .025, .765, bronze);
  arc(cap.g, 1.21, 1.18, .025, .765, bronze);
  const star = texture(128,128,(ctx,w,h) => symbol(ctx,0,w/2,h/2,50,'#77522e'));
  const sun = painted(cap.g, .65, .65, star, [0,.758,0]); sun.rotation.x = -Math.PI/2;
  for (const x of [-.88, .88]) {
    box(root, [.10, .10, 3.6], bronze, [x, .53, -.9]);
    box(cap.g, [.16, .08, .70], end, [x, .61, 0]);
  }
  // Cap's front socket is open toward the latch, with solid side walls.
  for (const x of [-.20, .20]) box(cap.g, [.06, .18, .44], end, [x, .82, 1.26]);
  box(cap.g, [.46, .18, .06], end, [0, .82, 1.02]);
  gem(8, -.45);
}

function makeDetBiMat(k) {
  const {wood, end, bronze, dark, box, plate, part, tag, rail, gem, lever} = k;
  // Open loom frame surrounds a separate inner storage well. The lockwork
  // has its own front channel, so rails never pass through the chamber walls.
  box(root, [3.3, .18, 2.65], end, [0, -1.03, 0]);
  for (const x of [-1.48, 1.48]) for (const z of [-1.16, .52]) {
    box(root, [.18, 2.35, .18], wood, [x, .04, z]);
    box(root, [.23, .12, .23], bronze, [x, -.86, z]);
  }
  box(root, [2.94, .18, .18], end, [0, 1.12, -1.16]);
  box(root, [2.0, .12, 1.8], end, [0, -.84, -.12]);
  for (const x of [-.96, .96]) box(root, [.12, 1.32, 1.75], wood, [x, -.12, -.12]);
  for (const z of [-.94, .60]) box(root, [1.85, 1.32, .12], wood, [0, -.12, z]);
  const key = part(0);
  // Wide window at home, narrow horizontal slot at the right stop: the
  // longitudinal bar's shoulder can exit only after this key is returned.
  plate(key.g, 2.70, .52, .15, key.mat, [0, -.43, 1.50],
    [[[-.50,-.075],[.12,-.075],[.12,-.20],[.44,-.20],[.44,.20],[.12,.20],[.12,.075],[-.50,.075]]]);
  tag(key.g, '↔', [-.77, -.43, 1.59]); rail([0, -.43, 1.39], 3.4, 'x', .30);
  const cover = part(1);
  plate(cover.g, .72, .69, .12, cover.mat, [-.86, .05, 1.30]);
  // Its bottom foot is caught behind the key's left shoulder at home.
  box(cover.g, [.16, .14, .22], bronze, [-1.14, -.34, 1.34]);
  rail([-.86, -.08, 1.18], 1.50, 'y', .42); tag(cover.g, '↓', [-.86, .05, 1.37]);
  const cam = lever(2, [-.86, .03, 1.08], .43);
  // A separate follower moves vertically with the cam eccentric.
  const follower = new THREE.Group(); root.add(follower);
  for (const y of [-.04, .10]) box(follower, [.65, .04, .10], bronze, [-.62, y, 1.22]);
  box(follower, [.44, .05, .10], bronze, [-.10, .10, 1.22]);
  box(follower, [.075, .35, .10], bronze, [.10, -.065, 1.22]);
  mesh(cam, new THREE.SphereGeometry(.035, 8, 6), dark, [.28, 0, .14]);
  cam.userData.follower = follower;
  const longitudinal = part(3);
  box(longitudinal.g, [.12, .12, .92], longitudinal.mat, [.28, -.43, 1.45]);
  box(longitudinal.g, [.12, .12, .30], longitudinal.mat, [.28, -.43, 1.00]);
  box(longitudinal.g, [.27, .34, .14], bronze, [.28, -.43, 1.35]);
  box(longitudinal.g, [.27, .23, .14], longitudinal.mat, [.28, -.43, 1.97]);
  // Follower tip enters this open fork, then lifts clear on cam rotation.
  for (const z of [1.07, 1.36]) box(longitudinal.g, [.30, .42, .045], end, [.19, -.23, z]);
  tag(longitudinal.g, '↓', [.28, -.43, 2.045]);
  const cross = part(4);
  // Crossbar lies immediately behind the key, in a distinct transverse lane.
  // Its fork embraces D's shaft without filling the same volume.
  // Remove the central shaft interval by using two separated lengths instead.
  box(cross.g, [1.41, .15, .16], cross.mat, [-.505, -.43, .84]);
  box(cross.g, [.98, .15, .16], cross.mat, [.85, -.43, .84]);
  box(cross.g, [.38, .15, .06], bronze, [.28, -.43, .72]);
  box(cross.g, [.15, .30, .18], bronze, [1.44, -.43, .84]);
  for (const x of [-1.30, 1.30]) {
    box(cross.g, [.10, 1.16, .12], end, [x, .20, .84]);
    box(cross.g, [.18, .08, .10], bronze, [x, .76, .84]);
  }
  tag(cross.g, '→', [1.44, -.43, .94]);
  for (let i = 5; i <= 6; i++) {
    const sign = i === 5 ? -1 : 1, wedge = part(i);
    plate(wedge.g, .55, .28, .23, wedge.mat, [sign * 1.25, .82, .84],
      [[[sign*.05-.12,-.12],[sign*.05+.12,-.12],[sign*.05+.12,.03],[sign*.05-.12,.03]]]);
    box(wedge.g, [.12, .30, .28], bronze, [sign * 1.53, .82, .84]);
    rail([sign * 1.27, .82, .68], 1.0, 'x', .19);
    tag(wedge.g, sign < 0 ? '←' : '→', [sign * 1.26, .92, .97]);
  }
  const bridge = part(7);
  box(bridge.g, [2.68, .16, .18], bridge.mat, [0, .82, .60]);
  for (const x of [-1.14, 1.14]) {
    for (const z of [.46, .74]) box(bridge.g, [.12, .38, .06], bronze, [x, .66, z]);
    box(bridge.g, [.15, .12, .28], bronze, [x, .61, .84]);
  }
  tag(bridge.g, '↑', [0, .82, .70]);
  const cap = part(8);
  plate(cap.g, 2.12, 1.95, .14, cap.mat, [0, .62, -.12]).rotation.x = -Math.PI / 2;
  // Two ears catch bridge feet; once lifted, cap translates behind the loom.
  for (const x of [-1.14, 1.14]) {
    box(cap.g, [.24, .14, .18], bronze, [x, .53, .60]);
    box(root, [.09, .08, 3.5], bronze, [x * .78, .48, -.9]);
    box(cap.g, [.15, .12, .66], end, [x * .78, .54, -.1]);
  }
  const seal = tag(cap.g, '⇧', [0, .70, -.12]); seal.rotation.x = -Math.PI / 2;
  gem(9, -.44, true);
}

function makeMongSen(data) {
  sunlight.shadow.mapSize.set(512, 512);
  Object.assign(sunlight.shadow.camera, { left: -5, right: 5, top: 5, bottom: -5, near: .5, far: 18 });
  sunlight.shadow.bias = -.0006;
  sunlight.shadow.normalBias = .025;
  const grain = texture(256, 256, (ctx, w, h) => {
    ctx.fillStyle = '#b99870'; ctx.fillRect(0, 0, w, h);
    for (let i = 0; i < 105; i++) {
      const y = i * h / 105;
      ctx.strokeStyle = `rgba(${i % 4 ? '73,39,16' : '242,216,171'},${.05 + (i % 7) * .012})`;
      ctx.lineWidth = i % 5 === 0 ? 1.7 : .65;
      ctx.beginPath();
      for (let x = 0; x <= w; x += 4) {
        const py = y + Math.sin(x * .025 + i * .67) * (1.3 + i % 4);
        if (x === 0) ctx.moveTo(x, py); else ctx.lineTo(x, py);
      }
      ctx.stroke();
    }
  });
  grain.wrapS = grain.wrapT = THREE.RepeatWrapping;
  function wood(color) {
    const mat = material(color, .02, .78); mat.map = grain; return mat;
  }
  const frame = wood(0x88633f), shell = wood(0xc2a079), end = wood(0x8e6946);
  const bronze = material(0xb48c50, .72, .4), iron = material(0x4e4c3b, .55, .58);
  const cavity = wood(0x73553b);
  const boxGeometry = new THREE.BoxGeometry(1, 1, 1);
  function box(parent, size, mat, position) {
    const item = mesh(parent, boxGeometry, mat, position);
    item.scale.set(...size); item.castShadow = true; item.receiveShadow = true;
    return item;
  }
  // Extruded outlines give boards real bevels and keyholes real inner walls.
  function board(parent, w, h, depth, mat, position, hole = null) {
    const s = new THREE.Shape();
    s.moveTo(-w / 2, -h / 2); s.lineTo(w / 2, -h / 2);
    s.lineTo(w / 2, h / 2); s.lineTo(-w / 2, h / 2); s.closePath();
    if (hole) {
      const path = new THREE.Path();
      hole.forEach(([x, y], i) => i ? path.lineTo(x, y) : path.moveTo(x, y));
      path.closePath(); s.holes.push(path);
    }
    const geo = new THREE.ExtrudeGeometry(s, { depth, bevelEnabled: true,
      bevelThickness: .012, bevelSize: .012, bevelSegments: 1, curveSegments: 1, steps: 1 });
    geo.translate(0, 0, -depth / 2);
    const item = mesh(parent, geo, mat, position);
    item.castShadow = true; item.receiveShadow = true; return item;
  }
  function group(position = [0, 0, 0], parent = root) {
    const item = new THREE.Group(); item.position.set(...position); parent.add(item); return item;
  }
  function axle(parent, radius, length, mat, position, axis = 'x') {
    const item = mesh(parent, new THREE.CylinderGeometry(radius, radius, length, 16), mat, position);
    if (axis === 'x') item.rotation.z = Math.PI / 2;
    if (axis === 'z') item.rotation.x = Math.PI / 2;
    item.castShadow = true; return item;
  }
  function tag(parent, letter, position, side = false) {
    const mark = painted(parent, .13, .13, textMap(letter, '#503a26', 55), position);
    if (side) mark.rotation.y = Math.PI / 2;
  }
  // A rigid open frame and a smaller, thick-walled storage cavity.
  box(root, [3.4, .18, 2.7], frame, [0, -1.13, 0]);
  for (const x of [-1.59, 1.59]) for (const z of [-1.24, 1.24]) {
    if (x > 0 && z > 0) {
      board(root, .19, 1.40, .19, frame, [x, -.41, z]);
      board(root, .19, .09, .19, frame, [x, 1.06, z]);
    } else board(root, .19, 2.19, .19, frame, [x, -.01, z]);
    box(root, [.22, .11, .22], bronze, [x, -.99, z]);
  }
  board(root, 3.0, 1.99, .14, shell, [0, -.02, -1.25]);
  const left = board(root, 2.27, 1.99, .14, shell, [-1.59, -.02, 0]);
  left.rotation.y = Math.PI / 2;
  board(root, 2.94, .77, .17, shell, [0, -.65, 1.28]);
  board(root, 2.94, .46, .17, shell, [0, .80, 1.28]);
  box(root, [2.12, .09, 1.86], cavity, [-.30, -.99, -.13]);
  box(root, [.12, 1.85, 1.21], cavity, [.60, -.02, -.455]);
  box(root, [.12, 1.85, .27], cavity, [.60, -.02, .665]);
  box(root, [.12, 1.18, .38], cavity, [.60, -.36, .34]);
  box(root, [.12, .32, .38], cavity, [.60, .78, .34]);
  // Front inner wall ends before the longitudinal mortise channel.
  box(root, [1.84, 1.85, .12], cavity, [-.43, -.02, .77]);
  // The D channel lives outside this cavity, at x=.82. The opening in
  // its side wall admits E without intersecting the storage walls.
  // Side cladding leaves a separate opening for E, forward of the B cover.
  for (const [y, height] of [[-.43, 1.2], [.85, .33]]) {
    const plank = board(root, 1.57, height, .14, shell, [1.59, y, -.45]);
    plank.rotation.y = Math.PI / 2;
  }
  box(root, [.14, 2.0, .07], frame, [1.59, -.02, .52]);
  box(root, [.13, .38, .89], end, [1.59, -.84, .93]);

  // A: a keyhole, not a painted slot. The low, long opening admits the shaft
  // at both stops. Only the tall window admits D's shoulder at A=0.
  const aMat = wood(0xd4ad76), a = group();
  const keyhole = [[.28,.06],[1.12,.06],[1.12,.24],[1.10,.24],
    [1.10,.44],[.54,.44],[.54,.24],[.28,.24]].map(([x,y]) => [x, y - .23]);
  board(a, 2.48, .54, .14, aMat, [0, .23, 1.53], keyhole);
  // The connecting arm passes in front of B's foot; only its short return
  // projects behind it. Shifting .4 right completely clears the foot.
  box(a, [.55, .12, .08], aMat, [1.43, .20, 1.64]);
  box(a, [.28, .12, .22], aMat, [1.70, .20, 1.53]);
  board(a, .38, .13, .045, end, [-.65, .23, 1.62]);
  tag(a, 'A', [-1.05, .23, 1.613]);
  register('belt', 0, a, 'translation', aMat);
  for (const y of [-.085, .55]) {
    box(root, [2.94, .045, .12], end, [0, y, 1.49]);
    box(root, [2.94, .025, .04], bronze, [0, y, 1.57]);
  }
  // B: captive side panel on two rails; its foot goes below A's return hook.
  const bMat = wood(0xc5a37b), b = group();
  const side = board(b, .76, .90, .12, bMat, [1.80, .73, .93]);
  side.rotation.y = Math.PI / 2;
  box(b, [.12, .06, .24], bMat, [1.85, .32, 1.40]);
  box(b, [.06, .25, .10], end, [1.89, .70, .92]);
  tag(b, 'B', [1.868, 1.02, .93], true);
  register('panel', 0, b, 'translation', bMat);
  for (const z of [.49, 1.37]) {
    box(root, [.18, 1.90, .05], frame, [1.67, .25, z]);
    box(root, [.04, 1.90, .035], bronze, [1.75, .25, z]);
  }
  box(root, [.20, .07, .96], end, [1.77, -.69, .93]);

  // D: split at the pin pocket, with a lower continuous web. Its high
  // shoulder starts behind A, leaving room for A to move across the shaft.
  const dMat = wood(0xd0b185), d = group();
  box(d, [.12, .12, .83], dMat, [.82, .16, .565]);
  box(d, [.12, .12, .74], dMat, [.82, .16, 1.47]);
  box(d, [.12, .025, .12], dMat, [.82, .1125, 1.04]);
  box(d, [.44, .12, .14], dMat, [.82, .33, 1.29]);
  box(d, [.12, .11, .14], dMat, [.82, .235, 1.29]);
  box(d, [.08, .22, .08], dMat, [.82, .28, .36]);
  board(d, .28, .12, .07, end, [.82, .16, 1.86]);
  tag(d, 'D', [.82, .16, 1.902]);
  register('longTenon', 0, d, 'translation', dMat);
  // Rails are below/beside the shaft and never occupy the shoulder's path.
  for (const x of [.68, .96]) box(root, [.06, .06, 1.20], end, [x, .065, .75]);

  // E: the open-front notch receives D's upright tongue. Its rear web stays
  // intact, so pulling D forward clears E without intersecting the web.
  const eMat = wood(0xbe965f), e = group();
  box(e, [1.78, .16, .05], eMat, [1.07, .35, .265]);
  box(e, [.47, .16, .15], eMat, [.415, .35, .365]);
  box(e, [.97, .16, .15], eMat, [1.475, .35, .365]);
  box(e, [.14, .16, .10], eMat, [1.20, .50, .35]);
  box(e, [.10, .22, .30], end, [1.99, .35, .34]);
  tag(e, 'E', [2.046, .35, .34], true);
  register('crossTenon', 0, e, 'translation', eMat);
  for (const z of [.185, .49]) {
    box(root, [.52, .07, .045], end, [.44, .22, z]);
    box(root, [.94, .07, .045], end, [1.41, .22, z]);
  }

  // C and its driven bolt. A slotted yoke constrains the eccentric pin;
  // the bolt rises .26 as the cam turns through a quarter revolution.
  const cMat = material(0xc69a55, .75, .35), c = group([1.57, .70, .98]);
  axle(root, .065, .11, iron, [1.495, .70, .98]);
  const camShape = new THREE.Shape(); camShape.absarc(0, 0, .29, 0, Math.PI * 2, false);
  const bearingHole = new THREE.Path(); bearingHole.absarc(0, 0, .073, 0, Math.PI * 2, true);
  camShape.holes.push(bearingHole);
  const camGeometry = new THREE.ExtrudeGeometry(camShape,
    { depth: .07, bevelEnabled: false, curveSegments: 16, steps: 1 });
  camGeometry.translate(0, 0, -.035); camGeometry.rotateY(Math.PI / 2);
  const wheel = mesh(c, camGeometry, cMat); wheel.castShadow = true;
  axle(c, .075, .09, bronze, [.025, 0, 0]);
  box(c, [.09, .40, .085], cMat, [.07, .04, 0]);
  axle(c, .034, .10, bronze, [.08, -.26, 0]);
  const camLetter = painted(c, .12, .12, textMap('C', '#4e3825', 55), [.047, .17, .10]);
  camLetter.rotation.y = Math.PI / 2;
  register('cam', 0, c, 'rotation', cMat);
  camFollower = group();
  for (const y of [.385, .50]) box(camFollower, [.055, .04, .40], bronze, [1.68, y, .85]);
  for (const z of [.63, 1.07]) box(camFollower, [.055, .15, .04], bronze, [1.68, .44, z]);
  box(camFollower, [.86, .055, .065], bronze, [1.25, .44, 1.12]);
  box(camFollower, [.06, .055, .15], bronze, [.82, .44, 1.08]);
  box(camFollower, [.07, .30, .07], bronze, [.82, .29, 1.04]);
  // A fixed open guide makes the bolt's sliding axis visible.
  for (const x of [.755, .885]) box(root, [.035, .13, .14], iron, [x, .34, 1.04]);

  // F: nested translation/lift groups. Four solid tabs slide below segmented
  // retaining lips, then align with the two exit windows on each side.
  const slide = group(), lift = group([0, 0, 0], slide);
  const lidMat = wood(0xcba77b), handleMat = material(0xa77d43, .7, .43);
  const top = board(lift, 3.08, 2.40, .17, lidMat, [0, 1.27, 0]);
  top.rotation.x = -Math.PI / 2;
  for (const x of [-1.43, 1.43]) {
    for (const z of [-.66, .66]) {
      box(lift, [.24, .065, .10], handleMat, [Math.sign(x) * 1.40, 1.06, z]);
      box(lift, [.055, .14, .10], end, [Math.sign(x) * 1.295, 1.13, z]);
    }
    for (const [z, length] of [[-1.245,.09],[-.42,1.08],[.825,.93]]) {
      box(root, [.20, .06, length], bronze, [x, 1.13, z]);
    }
    box(root, [.08, .08, 2.60], end, [x + Math.sign(x) * .13, 1.035, 0]);
  }
  for (const z of [.245, .455]) box(lift, [.18, .74, .045], end, [1.20, .83, z]);
  const handle = mesh(lift, new THREE.TorusGeometry(.17, .035, 6, 20), handleMat, [0, 1.42, .55]);
  handle.rotation.x = Math.PI / 2;
  const lotus = texture(256, 256, (ctx, w, h) => {
    ctx.translate(w / 2, h / 2); ctx.strokeStyle = '#74502c'; ctx.lineWidth = 3;
    for (const angle of [-.65, 0, .65]) {
      ctx.save(); ctx.rotate(angle); ctx.beginPath(); ctx.moveTo(0, 55);
      ctx.bezierCurveTo(-53, 15, -24, -50, 0, -75);
      ctx.bezierCurveTo(24, -50, 53, 15, 0, 55); ctx.stroke(); ctx.restore();
    }
    ctx.beginPath(); ctx.moveTo(-75, 62); ctx.quadraticCurveTo(0, 90, 75, 62); ctx.stroke();
  });
  const flower = painted(lift, .82, .82, lotus, [0, 1.368, -.10]);
  flower.rotation.x = -Math.PI / 2;
  register('capSlide', 0, slide, 'translation', handleMat);
  register('capLift', 0, lift, 'translation', lidMat);
  lid = lift;
  const jade = material(0x498d75, .2, .28);
  const treasure = mesh(root, new THREE.IcosahedronGeometry(.28, 1), jade, [-.30, -.65, -.10]);
  treasure.castShadow = true;
  box(root, [.64, .11, .64], end, [-.30, -.89, -.10]);
  const ground = mesh(root, new THREE.PlaneGeometry(14, 14),
    material(0xe4d7bf, 0, 1), [0, -1.235, 0]);
  ground.rotation.x = -Math.PI / 2; ground.receiveShadow = true;
  pieces.forEach(piece => setPiece(piece, stateValue(piece, data)));
}

function stateValue(piece, data) {
  if (isCraft()) return data.state.mechanical[piece.index] ? 1 : 0;
  if (data.assembly === 'mong-sen') {
    return data.state.mechanical[['belt', 'panel', 'cam', 'longTenon', 'crossTenon', 'capSlide', 'capLift'].indexOf(piece.kind)] ? 1 : 0;
  }
  if (piece.kind === 'ring') return -data.state.rings[piece.index] * Math.PI / 2;
  if (piece.kind === 'slider') return data.state.sliders[piece.index] ? 1 : 0;
  return data.state.parts[{ joint: 0, lid: 1, core: 2 }[piece.kind]] ? 1 : 0;
}

function setPiece(piece, value) {
  piece.value = value;
  if (isCraft()) {
    if (piece.mode === 'rotation') {
      piece.object.rotation[piece.axis] = value * piece.travel;
      if (piece.object.userData.follower) piece.object.userData.follower.position.y = .28 * Math.sin(value * piece.travel);
    }
    else {
      piece.object.position.copy(piece.origin);
      piece.object.position[piece.axis] += value * piece.travel;
    }
    return;
  }
  if (isMongSen()) {
    if (piece.kind === 'cam') {
      piece.object.rotation.x = value * piece.travel;
      // Scotch yoke: the eccentric pin runs along the horizontal slot.
      camFollower.position.y = .26 * (1 - Math.cos(value * Math.PI / 2));
    } else {
      piece.object.position.copy(piece.origin);
      piece.object.position[piece.axis] += value * piece.travel;
    }
    return;
  }
  if (piece.mode === 'rotation') {
    piece.object.rotation[piece.axis] = piece.kind === 'ring' ? value : value * piece.travel;
  } else if (piece.mode === 'lid') {
    if (piece.axis === 'x') piece.object.position.x = value * 3.6;
    else {
      // Lift clear of the rim first, then park on the rear guide; the core's
      // vertical extraction path stays clear of the detached lid.
      piece.object.position.y = Math.min(1, value / .35) * .95;
      piece.object.position.z = -Math.max(0, (value - .35) / .65) * 3.5;
    }
  } else {
    piece.object.position.copy(piece.origin);
    piece.object.position[piece.axis] += value * piece.travel;
  }
}

function updateReveals() {
  // Mộng Sen is revealed by moving solid covers, never by toggling visibility.
  if (isMongSen() || isCraft()) return;
  clues.forEach(clue => { clue.mark.visible = snapshot.state.sliders[clue.requires]; });
  const cap = pieces.find(piece => piece.kind === 'lid');
  core.visible = cap.value > .4;
}

function canMove(piece, direction) {
  return snapshot.legalActions.some(action => action.kind === piece.kind &&
    action.index === piece.index && action.direction === direction);
}

function updateSelection() {
  pieces.forEach(piece => {
    const chosen = selected?.kind === piece.kind && selected.index === piece.index;
    const released = canMove(piece, 1) || canMove(piece, -1);
    piece.highlight.color.setHex(feedback?.piece === piece ? 0xbe5741 : chosen ? 0xe7bc68 : piece.baseColor);
    piece.highlight.emissive.setHex(chosen ? (released ? 0x5a622b : 0x683824) : 0x000000);
    piece.highlight.emissiveIntensity = chosen ? .22 : 0;
  });
  requestRender();
}

function settle() {
  waiting = false;
  bridge('settled');
  if (snapshot.phase === 'opening' && (isCraft() ? snapshot.state.mechanical.at(-1) : isMongSen() ? snapshot.state.mechanical[6] : snapshot.state.parts[2]) && !openReported) {
    openReported = true;
    bridge('complete');
  }
}

window.applyArtifactSnapshot = data => {
  if (disposed) return;
  if (!snapshot || data.epoch !== snapshot.epoch) {
    clearGesture(); motion = null; waiting = false; openReported = false; feedback = null;
    snapshot = data; selected = data.selected;
    makeArtifact(data);
    yaw = isMongSen() ? .55 : .24; pitch = isMongSen() ? .40 : .24; userZoomed = false; distance = fitDistance;
    resize();
    updateCamera(); updateSelection(); bridge('settled');
    return;
  }
  const previous = snapshot;
  snapshot = data; selected = data.selected;
  if (data.revision !== previous.revision) {
    gesture = null; waiting = false;
    const from = pieces.map(piece => piece.value);
    const to = pieces.map((piece, i) => {
      if (piece.kind !== 'ring') return stateValue(piece, data);
      const delta = (data.state.rings[piece.index] - previous.state.rings[piece.index] + 4) % 4;
      // Use the previous authoritative angle, not a possibly previewed drag.
      const prior = -previous.state.rings[piece.index] * Math.PI / 2;
      const base = from[i] - THREE.MathUtils.euclideanModulo(from[i] - prior + Math.PI, Math.PI * 2) + Math.PI;
      return base - (delta === 3 ? -1 : delta) * Math.PI / 2;
    });
    motion = { elapsed: 0, last: null, duration: 380, from, to };
    bridge('busy'); requestRender();
  }
  if (data.rejection !== previous.rejection) window.rejectArtifactAction();
  updateSelection();
};

function reject(piece) {
  feedback = { piece, until: performance.now() + 280 };
  updateSelection();
}
window.rejectArtifactAction = () => {
  waiting = false;
  const piece = pieces.find(p => p.kind === selected?.kind && p.index === selected?.index);
  if (piece) reject(piece);
  if (!motion) bridge('settled');
};

function requestRender() {
  if (!raf && active && !disposed && !document.hidden) raf = requestAnimationFrame(frame);
}
function frame(now) {
  raf = 0;
  if (!active || disposed || document.hidden) return;
  if (motion) {
    const current = motion;
    if (current.last !== null) current.elapsed += Math.min(50, now - current.last);
    current.last = now;
    const t = Math.min(1, current.elapsed / current.duration);
    const eased = t * t * (3 - 2 * t);
    pieces.forEach((piece, i) => setPiece(piece, THREE.MathUtils.lerp(current.from[i], current.to[i], eased)));
    updateReveals();
    updateCamera();
    if (t === 1) { motion = null; settle(); }
  }
  if (feedback && now >= feedback.until) { feedback = null; updateSelection(); }
  renderer.render(scene, camera);
  if (motion || feedback) requestRender();
}
function updateCamera() {
  if (isCraft()) {
    const cap = snapshot.level === 2 ? (pieces[3]?.value || 0) : (pieces.at(-2)?.value || 0);
    const extracted = pieces.at(-1)?.value || 0;
    const cross = snapshot.level === 5 ? (pieces[4]?.value || 0) : 0;
    const focus = new THREE.Vector3(snapshot.level === 2 ? cap * .7 : .2 + cross * .7, extracted * .35, snapshot.level === 2 ? 0 : -cap * .75);
    if (!userZoomed) distance = fitDistance * (1 + cap * .23 + cross * .20);
    camera.position.set(focus.x + Math.sin(yaw) * Math.cos(pitch) * distance,
      focus.y + Math.sin(pitch) * distance, focus.z + Math.cos(yaw) * Math.cos(pitch) * distance);
    camera.lookAt(focus); requestRender(); return;
  }
  if (isMongSen()) {
    const value = kind => pieces.find(piece => piece.kind === kind)?.value || 0;
    const d = value('longTenon'), e = value('crossTenon'), lifted = value('capLift');
    const focus = new THREE.Vector3(e * .50, .12 + lifted * .30, d * .65);
    if (!userZoomed) distance = fitDistance * (1 + Math.max(d, e) * .27 + lifted * .08);
    camera.position.set(focus.x + Math.sin(yaw) * Math.cos(pitch) * distance,
      focus.y + Math.sin(pitch) * distance, focus.z + Math.cos(yaw) * Math.cos(pitch) * distance);
    camera.lookAt(focus); requestRender(); return;
  }
  const cap = pieces.find(piece => piece.kind === 'lid')?.value || 0;
  const extracted = pieces.find(piece => piece.kind === 'core')?.value || 0;
  const hex = snapshot?.shape === 'hexagonalPrism';
  const focus = new THREE.Vector3(hex ? cap * 1.6 : 0, .35 + extracted * .4, hex ? 0 : cap * -1.4);
  if (!userZoomed) distance = fitDistance * (1 + cap * .65);
  camera.position.set(focus.x + Math.sin(yaw) * Math.cos(pitch) * distance,
    focus.y + Math.sin(pitch) * distance, focus.z + Math.cos(yaw) * Math.cos(pitch) * distance);
  camera.lookAt(focus);
  requestRender();
}
function resize() {
  const width = Math.max(1, innerWidth), height = Math.max(1, innerHeight);
  camera.aspect = width / height; camera.updateProjectionMatrix();
  const vertical = THREE.MathUtils.degToRad(19);
  const horizontal = Math.atan(Math.tan(vertical) * camera.aspect);
  const nextFit = (isMongSen() ? 1.95 : 2.4) / Math.tan(Math.min(vertical, horizontal)) + 1.7;
  distance = THREE.MathUtils.clamp(userZoomed ? distance * nextFit / fitDistance : nextFit, 4.4, 18);
  fitDistance = nextFit;
  renderer.setSize(width, height); updateCamera();
}
function hitAt(x, y) {
  if (!snapshot) return null;
  scene.updateMatrixWorld(true); camera.updateMatrixWorld(true);
  const rect = canvas.getBoundingClientRect();
  raycaster.setFromCamera(new THREE.Vector2((x - rect.left) / rect.width * 2 - 1,
    -(y - rect.top) / rect.height * 2 + 1), camera);
  const hit = raycaster.intersectObject(root, true).find(item => {
    for (let ancestor = item.object; ancestor; ancestor = ancestor.parent) {
      if (!ancestor.visible) return false;
    }
    return true;
  });
  if (!hit) return null;
  let object = hit.object;
  while (object && !object.userData.kind) object = object.parent;
  if (isCraft() && snapshot.level === 2 && object?.userData.index === 3 && !snapshot.state.mechanical[2]) {
    return pieces.find(piece => piece.index === 2);
  }
  if (isMongSen() && (object?.userData.kind === 'capLift' || object?.userData.kind === 'capSlide')) {
    const kind = snapshot.state.mechanical[5] ? 'capLift' : 'capSlide';
    return pieces.find(piece => piece.kind === kind);
  }
  return object?.userData.kind ? pieces.find(piece => piece.kind === object.userData.kind &&
    piece.index === object.userData.index) : null;
}
function restorePreview() {
  if (gesture?.hit && gesture.startValue !== undefined) {
    setPiece(gesture.hit, gesture.startValue); updateReveals(); updateCamera();
  }
}
function clearGesture() {
  restorePreview();
  gesture = null;
  for (const id of pointers.keys()) {
    try { canvas.releasePointerCapture(id); } catch (_) {}
  }
  pointers.clear(); pinch = null; multiTouch = false;
}

function screenAxis(piece) {
  // Project the part's local movement axis into screen space. Rotation uses
  // the tangent at the touched point, so side locks retain their own axes.
  scene.updateMatrixWorld(true); camera.updateMatrixWorld(true);
  const axis = new THREE.Vector3(); axis[piece.axis] = 1;
  const parent = piece.object.parent;
  const origin = piece.object.getWorldPosition(new THREE.Vector3());
  let vector;
  if (piece.mode === 'rotation') {
    const worldAxis = axis.transformDirection(parent.matrixWorld);
    const radial = raycaster.ray.at(raycaster.ray.origin.distanceTo(origin), new THREE.Vector3()).sub(origin);
    vector = new THREE.Vector3().crossVectors(worldAxis, radial).normalize();
    // Increasing ring state rotates by a negative quarter turn.
    if (piece.kind === 'ring') vector.negate();
  } else {
    vector = axis.transformDirection(parent.matrixWorld);
    if ((isMongSen() || isCraft()) && piece.travel < 0) vector.negate();
  }
  const a = origin.clone().project(camera), b = origin.clone().add(vector).project(camera);
  const direction = new THREE.Vector2((b.x - a.x) * innerWidth / 2, -(b.y - a.y) * innerHeight / 2);
  if (direction.length() < 8) direction.set(0, -1);
  return direction.normalize();
}
function camAngle(piece, x, y) {
  const origin = piece.object.getWorldPosition(new THREE.Vector3());
  const normal = new THREE.Vector3(1, 0, 0).transformDirection(piece.object.parent.matrixWorld);
  const rect = canvas.getBoundingClientRect();
  raycaster.setFromCamera(new THREE.Vector2((x - rect.left) / rect.width * 2 - 1,
    -(y - rect.top) / rect.height * 2 + 1), camera);
  const point = raycaster.ray.intersectPlane(new THREE.Plane().setFromNormalAndCoplanarPoint(normal, origin), new THREE.Vector3());
  if (!point) return null;
  const radial = point.sub(origin).applyQuaternion(piece.object.parent.getWorldQuaternion(new THREE.Quaternion()).invert());
  if (Math.hypot(radial.y, radial.z) < .07) return null;
  return Math.atan2(radial.z, radial.y);
}
function pointerDown(event) {
  if (!active || disposed || !snapshot || pointers.size >= 2) return;
  event.preventDefault();
  pointers.set(event.pointerId, { x: event.clientX, y: event.clientY });
  canvas.setPointerCapture(event.pointerId);
  if (pointers.size === 2) {
    restorePreview(); multiTouch = true; gesture = null;
    const [a, b] = [...pointers.values()];
    pinch = { span: Math.max(1, Math.hypot(a.x - b.x, a.y - b.y)), distance };
    return;
  }
  const hit = hitAt(event.clientX, event.clientY);
  // A hit remains a part gesture even when busy or locked: never orbit too.
  gesture = { id: event.pointerId, x: event.clientX, y: event.clientY,
    lastX: event.clientX, lastY: event.clientY, hit,
    enabled: !motion && !waiting && snapshot.phase === 'playing',
    startValue: hit?.value, direction: 0, amount: 0, rejected: false,
    screenAxis: hit ? screenAxis(hit) : null,
    camStart: isMongSen() && hit?.kind === 'cam' ? camAngle(hit, event.clientX, event.clientY) : null };
  if (hit && gesture.enabled) {
    selected = { kind: hit.kind, index: hit.index };
    updateSelection(); bridge('select', selected);
  }
}
function pointerMove(event) {
  if (!pointers.has(event.pointerId) || !active) return;
  event.preventDefault();
  pointers.set(event.pointerId, { x: event.clientX, y: event.clientY });
  if (pointers.size === 2 && pinch) {
    userZoomed = true;
    const [a, b] = [...pointers.values()];
    distance = THREE.MathUtils.clamp(pinch.distance * pinch.span /
      Math.max(1, Math.hypot(a.x - b.x, a.y - b.y)), 4.4, 18);
    updateCamera(); return;
  }
  if (multiTouch || !gesture || gesture.id !== event.pointerId) return;
  if (!gesture.hit) {
    yaw -= (event.clientX - gesture.lastX) * .009;
    pitch = THREE.MathUtils.clamp(pitch + (event.clientY - gesture.lastY) * .007, isMongSen() ? .06 : -.9, 1.15);
    gesture.lastX = event.clientX; gesture.lastY = event.clientY;
    updateCamera(); return;
  }
  if (!gesture.enabled || motion || waiting) return;
  const dx = event.clientX - gesture.x, dy = event.clientY - gesture.y;
  let projected = dx * gesture.screenAxis.x + dy * gesture.screenAxis.y;
  if (isMongSen() && gesture.hit.kind === 'cam' && gesture.camStart !== null) {
    const angle = camAngle(gesture.hit, event.clientX, event.clientY);
    if (angle === null) return;
    const delta = THREE.MathUtils.euclideanModulo(angle - gesture.camStart + Math.PI, Math.PI * 2) - Math.PI;
    projected = delta / (Math.PI / 2) * 70;
  }
  if (Math.abs(projected) < 6) { restorePreview(); gesture.amount = 0; return; }
  const direction = projected > 0 ? 1 : -1;
  const piece = gesture.hit;
  if (!canMove(piece, direction)) {
    restorePreview(); gesture.amount = 0;
    if (!gesture.rejected) {
      gesture.rejected = true; reject(piece);
      // Let Dart provide the precise dependency message, with no state change.
      bridge('action', { kind: piece.kind, index: piece.index, direction });
    }
    return;
  }
  gesture.direction = direction;
  gesture.amount = Math.min(1, Math.abs(projected) / 70);
  const span = piece.kind === 'ring' ? -Math.PI / 2 : 1;
  setPiece(piece, gesture.startValue + direction * span * gesture.amount);
  updateReveals(); updateCamera();
}
function pointerEnd(event) {
  if (!pointers.has(event.pointerId)) return;
  const current = gesture?.id === event.pointerId ? gesture : null;
  if (current) {
    // Canceled captures and sub-threshold drags never mutate authoritative state.
    const commit = event.type === 'pointerup' && current.enabled && current.hit && current.amount >= .35 && !motion && !waiting;
    if (!commit) restorePreview();
    gesture = null;
    if (commit) {
      waiting = true;
      bridge('action', { kind: current.hit.kind, index: current.hit.index, direction: current.direction });
    }
  }
  pointers.delete(event.pointerId);
  try { canvas.releasePointerCapture(event.pointerId); } catch (_) {}
  if (!pointers.size) { multiTouch = false; pinch = null; }
}
window.setArtifactActive = value => {
  active = !!value; clearGesture();
  if (!active) { cancelAnimationFrame(raf); raf = 0; if (motion) motion.last = null; }
  else requestRender();
};
window.disposeArtifact = () => {
  if (disposed) return;
  window.setArtifactActive(false); disposed = true;
  listeners.splice(0).forEach(remove => remove());
  releaseArtifact(); scene.clear();
  renderer.renderLists.dispose(); renderer.dispose(); renderer.forceContextLoss(); canvas.remove();
};
listen(canvas, 'pointerdown', pointerDown, { passive: false });
listen(canvas, 'pointermove', pointerMove, { passive: false });
listen(canvas, 'pointerup', pointerEnd);
listen(canvas, 'pointercancel', pointerEnd);
listen(canvas, 'lostpointercapture', pointerEnd);
listen(canvas, 'wheel', event => {
  event.preventDefault(); userZoomed = true;
  distance = THREE.MathUtils.clamp(distance * Math.exp(event.deltaY * .001), 4.4, 18);
  updateCamera();
}, { passive: false });
listen(canvas, 'webglcontextlost', event => {
  event.preventDefault();
  if (!disposed) { window.setArtifactActive(false); bridge('error'); }
});
listen(window, 'resize', resize);
listen(window, 'blur', () => window.setArtifactActive(false));
listen(window, 'focus', () => window.setArtifactActive(!document.hidden));
listen(document, 'visibilitychange', () => window.setArtifactActive(!document.hidden));
listen(window, 'pagehide', window.disposeArtifact);
resize(); bridge('ready');
