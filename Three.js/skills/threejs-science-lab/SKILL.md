---
name: threejs-science-lab
description: >
  This skill should be used when the user wants a science or physics concept rendered
  as an interactive 3D simulation via the Three.js 3D Viewer — trigger phrases include
  "show me how X works in 3D", "simulate", "orbital mechanics", "molecule/molecular
  structure", "solar system", "waves/fields/forces", "visualize this physics concept",
  or general science-education requests where a live 3D model would teach the mechanism
  better than a diagram. Always load `threejs-core` alongside this skill before calling
  `show_threejs_scene`.
metadata:
  version: "0.1.0"
  author: "Nav"
---

# threejs-science-lab — Physics & Science Simulations

Build small, honest simulations: the motion and structure shown should reflect real
physics/chemistry (even if simplified), not just look scientific. This skill assumes
`threejs-core` rules are already being followed.

## Core patterns

### Orbital mechanics / solar system

Model each body as a sphere on a circular (or elliptical) path, animate angle over
time rather than hand-authoring keyframes:

```js
const bodies = [
  { name: "Sun", radius: 0.6, color: 0xffcc33, orbitRadius: 0, speed: 0, emissive: true },
  { name: "Planet A", radius: 0.15, color: 0x4f8ef7, orbitRadius: 2, speed: 0.6 },
  { name: "Planet B", radius: 0.22, color: 0xe0664f, orbitRadius: 3.4, speed: 0.35 },
];

const meshes = bodies.map(b => {
  const geometry = new THREE.SphereGeometry(b.radius, 32, 32);
  const material = b.emissive
    ? new THREE.MeshBasicMaterial({ color: b.color })
    : new THREE.MeshStandardMaterial({ color: b.color, roughness: 0.6 });
  const mesh = new THREE.Mesh(geometry, material);
  scene.add(mesh);
  if (b.orbitRadius > 0) {
    const ring = new THREE.Mesh(
      new THREE.RingGeometry(b.orbitRadius - 0.01, b.orbitRadius + 0.01, 64),
      new THREE.MeshBasicMaterial({ color: 0x444444, side: THREE.DoubleSide })
    );
    ring.rotation.x = -Math.PI / 2;
    scene.add(ring);
  }
  return mesh;
});
if (bodies.some(b => b.emissive)) scene.add(new THREE.PointLight(0xffffff, 1.2, 50));
scene.add(new THREE.AmbientLight(0x404040));

let t = 0;
function animate() {
  requestAnimationFrame(animate);
  t += 0.01;
  bodies.forEach((b, i) => {
    if (b.orbitRadius > 0) {
      meshes[i].position.set(Math.cos(t * b.speed) * b.orbitRadius, 0, Math.sin(t * b.speed) * b.orbitRadius);
    }
  });
  controls.update();
  renderer.render(scene, camera);
}
animate();
```
Use real relative proportions where feasible (or state clearly in your reply that
scale/speed are exaggerated for visibility — real orbital scales are never legible
in one scene).

### Molecular structure (ball-and-stick)

```js
const atoms = [
  { pos: [0, 0, 0], element: "C", color: 0x444444, radius: 0.35 },
  { pos: [1.1, 0.6, 0], element: "H", color: 0xffffff, radius: 0.2 },
  // ...
];
const bonds = [[0, 1], [0, 2], [0, 3]]; // index pairs into atoms

atoms.forEach(a => {
  const mesh = new THREE.Mesh(
    new THREE.SphereGeometry(a.radius, 24, 24),
    new THREE.MeshStandardMaterial({ color: a.color, roughness: 0.3 })
  );
  mesh.position.set(...a.pos);
  scene.add(mesh);
});

bonds.forEach(([i, j]) => {
  const a = new THREE.Vector3(...atoms[i].pos);
  const b = new THREE.Vector3(...atoms[j].pos);
  const mid = a.clone().add(b).multiplyScalar(0.5);
  const dir = b.clone().sub(a);
  const bond = new THREE.Mesh(
    new THREE.CylinderGeometry(0.06, 0.06, dir.length(), 8),
    new THREE.MeshStandardMaterial({ color: 0xaaaaaa })
  );
  bond.position.copy(mid);
  bond.quaternion.setFromUnitVectors(new THREE.Vector3(0, 1, 0), dir.clone().normalize());
  scene.add(bond);
});
```
Use standard CPK-ish colors when the user doesn't specify: C=0x444444, H=0xffffff,
O=0xdd2222, N=0x2244dd.

### Waves / fields

Displace a plane or line of points sinusoidally over time (reuse the surface-plot
pattern from `threejs-data-viz` but drive `z` by `t` inside the animation loop instead
of computing it once), or draw vector fields as small arrows (`THREE.ArrowHelper`) on a
grid of sample points.

### Forces / trajectories

Integrate motion with a simple Euler/Verlet step inside the animation loop rather than
pre-baking a path, so the physics genuinely runs:
```js
let velocity = new THREE.Vector3(0.05, 0.08, 0);
const gravity = new THREE.Vector3(0, -0.002, 0);
function animate() {
  requestAnimationFrame(animate);
  velocity.add(gravity);
  ball.position.add(velocity);
  if (ball.position.y < 0) { ball.position.y = 0; velocity.y *= -0.8; } // bounce/damp
  controls.update();
  renderer.render(scene, camera);
}
```

## Teaching checklist

- Simplify honestly: state in your reply what's exaggerated (speeds, scales, distances)
  so the user doesn't walk away with a wrong intuition about real proportions.
- Prefer a slightly pulled-back camera and a slow default animation speed — science
  concepts are usually easier to parse slow.
- If the concept has a "before/after" or cause/effect (e.g. a collision, a phase
  change), consider letting `sendPrompt(...)`-style follow-up be implied by good visual
  staging rather than requiring the user to ask twice.
