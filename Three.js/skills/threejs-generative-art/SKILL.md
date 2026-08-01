---
name: threejs-generative-art
description: >
  This skill should be used when the user wants abstract, decorative, or ambient 3D
  visuals with no specific data or technical concept behind them — trigger phrases
  include "make something cool/pretty in 3D", "generative art", "particle effects",
  "ambient background", "procedural pattern", "abstract animation", or open-ended
  creative requests for a 3D visual. Always load `threejs-core` alongside this skill
  before calling `show_threejs_scene`.
metadata:
  version: "0.1.0"
  author: "Nav"
---

# threejs-generative-art — Abstract & Procedural 3D Visuals

Open-ended creative scenes: particle systems, procedural geometry, noise-driven
motion, and post-processing glow. This is the one domain where "looks good" is the
success criterion rather than mapping to external meaning — still, aim for something
that feels intentional (a clear color palette, a coherent motion idea) rather than
random noise. This skill assumes `threejs-core` rules are already being followed.

## Core patterns

### Particle field (points)

Cheap and effective for large counts — always prefer `THREE.Points` over many
individual meshes for particle effects:

```js
const count = 2000;
const positions = new Float32Array(count * 3);
const colors = new Float32Array(count * 3);
const color = new THREE.Color();
for (let i = 0; i < count; i++) {
  const r = 4 + Math.random() * 2;
  const theta = Math.random() * Math.PI * 2;
  const phi = Math.acos(Math.random() * 2 - 1);
  positions[i * 3] = r * Math.sin(phi) * Math.cos(theta);
  positions[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta);
  positions[i * 3 + 2] = r * Math.cos(phi);
  color.setHSL(0.55 + Math.random() * 0.15, 0.8, 0.6);
  colors[i * 3] = color.r; colors[i * 3 + 1] = color.g; colors[i * 3 + 2] = color.b;
}
const geometry = new THREE.BufferGeometry();
geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
const material = new THREE.PointsMaterial({ size: 0.05, vertexColors: true, transparent: true, opacity: 0.9 });
const points = new THREE.Points(geometry, material);
scene.add(points);

function animate() {
  requestAnimationFrame(animate);
  points.rotation.y += 0.0015;
  controls.update();
  renderer.render(scene, camera);
}
animate();
```

### Procedural geometry (noise-displaced mesh)

Reuse the surface-displacement pattern from `threejs-data-viz`, but drive `z` with a
hand-rolled pseudo-noise function of position and time instead of real data — a sum of
a few sine waves at different frequencies/phases reads as organic without needing an
external noise library:
```js
function pseudoNoise(x, y, t) {
  return Math.sin(x * 1.3 + t) * 0.5 + Math.sin(y * 2.1 - t * 0.7) * 0.3 + Math.sin((x + y) * 0.8 + t * 1.3) * 0.2;
}
```

### Instanced repetition (grids, swarms, crystal fields)

For many copies of one shape, use `THREE.InstancedMesh` instead of a loop of
`THREE.Mesh` — far cheaper and just as easy to animate per-instance:
```js
const geometry = new THREE.IcosahedronGeometry(0.15, 0);
const material = new THREE.MeshStandardMaterial({ color: 0x8855ff, roughness: 0.3, metalness: 0.4 });
const count = 300;
const mesh = new THREE.InstancedMesh(geometry, material, count);
const dummy = new THREE.Object3D();
for (let i = 0; i < count; i++) {
  dummy.position.set((Math.random() - 0.5) * 8, (Math.random() - 0.5) * 8, (Math.random() - 0.5) * 8);
  dummy.rotation.set(Math.random() * Math.PI, Math.random() * Math.PI, 0);
  dummy.updateMatrix();
  mesh.setMatrixAt(i, dummy.matrix);
}
scene.add(mesh);
```

### Glow / bloom post-processing

Use the provided `EffectComposer`/`RenderPass`/`UnrealBloomPass` globals for a
neon/glow look — pair with `MeshBasicMaterial` or bright emissive-ish colors on the
objects meant to glow:
```js
const composer = new EffectComposer(renderer);
composer.addPass(new RenderPass(scene, camera));
const bloom = new UnrealBloomPass(new THREE.Vector2(width, height), 0.8, 0.4, 0.1);
composer.addPass(bloom);
// in the animation loop, replace renderer.render(scene, camera) with:
composer.render();
```

## Aesthetic checklist

- Pick a deliberate 2-4 color palette (via `setHSL` with a narrow hue range, or a fixed
  small set of hex colors) rather than fully random hues — restraint reads as
  intentional design.
- Give the scene one clear motion idea (slow rotation, gentle drift, pulsing scale) —
  avoid stacking many unrelated animations that fight for attention.
- Default to a transparent background unless a dark "void" backdrop specifically helps
  the piece (common for particle/glow work — a near-black solid clear color often
  makes bloom and points read much better than transparent).
- Keep instance/particle counts reasonable (hundreds to a couple thousand) — this
  renders in a chat widget, not a dedicated GPU benchmark.
