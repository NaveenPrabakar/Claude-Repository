---
name: threejs-product-showcase
description: >
  This skill should be used when the user wants a specific real-world object,
  product mockup, room/interior layout, or architectural massing rendered as an
  interactive 3D model via the Three.js 3D Viewer — trigger phrases include
  "show me a 3D model of X", "product mockup", "floor plan in 3D", "room layout",
  "furniture arrangement", "building massing", or "what would X look like in 3D".
  Always load `threejs-core` alongside this skill before calling `show_threejs_scene`.
metadata:
  version: "0.1.0"
  author: "Nav"
---

# threejs-product-showcase — Objects, Rooms & Architectural Massing

Build recognizable, well-composed representations of concrete things out of primitive
geometry — a product on a pedestal, a furnished room, a building's basic massing.
Since there's no model/texture importing (see threejs-core rule 10), the craft here is
decomposing a real object into a small set of primitives that still reads clearly.
This skill assumes `threejs-core` rules are already being followed.

## Core patterns

### Product on a pedestal (single hero object)

Compose the object from a handful of primitives (boxes, cylinders, spheres,
`ExtrudeGeometry` for custom profiles), group them, then add a simple pedestal/backdrop
so it reads as a "product shot" rather than a floating shape:

```js
const product = new THREE.Group();
const body = new THREE.Mesh(
  new THREE.CylinderGeometry(0.5, 0.6, 1.2, 32),
  new THREE.MeshStandardMaterial({ color: 0xdddddd, roughness: 0.25, metalness: 0.6 })
);
product.add(body);
const cap = new THREE.Mesh(
  new THREE.CylinderGeometry(0.35, 0.35, 0.15, 32),
  new THREE.MeshStandardMaterial({ color: 0x222222, roughness: 0.4 })
);
cap.position.y = 0.68;
product.add(cap);
product.position.y = 0.9; // sits on pedestal top
scene.add(product);

const pedestal = new THREE.Mesh(
  new THREE.CylinderGeometry(0.9, 1.1, 0.3, 32),
  new THREE.MeshStandardMaterial({ color: 0x333333, roughness: 0.6 })
);
pedestal.position.y = 0.15;
scene.add(pedestal);
```
Use a solid, slightly dark `setClearColor` (studio-backdrop feel) instead of
transparent for hero-product shots — it reads much more like a real product render.
Favor `metalness`/`roughness` combinations deliberately: matte plastic ≈
`{roughness: 0.6, metalness: 0}`, brushed metal ≈ `{roughness: 0.35, metalness: 0.8}`,
glossy ≈ `{roughness: 0.1, metalness: 0.2}`.

### Room / interior layout (top-down-friendly)

Build walls as thin boxes and furniture as grouped primitives, positioned from a simple
floor-plan coordinate list so layout logic stays readable:

```js
const floor = new THREE.Mesh(
  new THREE.PlaneGeometry(8, 6),
  new THREE.MeshStandardMaterial({ color: 0xcbb994, roughness: 0.9 })
);
floor.rotation.x = -Math.PI / 2;
scene.add(floor);

function wall(x, z, w, d, h = 2.4) {
  const mesh = new THREE.Mesh(
    new THREE.BoxGeometry(w, h, d),
    new THREE.MeshStandardMaterial({ color: 0xf2f0ec, roughness: 0.95 })
  );
  mesh.position.set(x, h / 2, z);
  scene.add(mesh);
}
wall(0, -3, 8, 0.15);   // back wall
wall(-4, 0, 0.15, 6);   // left wall

// furniture as small grouped primitives, positioned in floor-plan coordinates
const table = new THREE.Group();
table.add(new THREE.Mesh(new THREE.BoxGeometry(1.4, 0.08, 0.8), new THREE.MeshStandardMaterial({ color: 0x8a5a3b })));
table.position.set(0, 0.45, 0);
scene.add(table);
```
Set the initial camera at a 3/4 elevated angle (`camera.position.set(6, 6, 6);
camera.lookAt(0, 1, 0);`) so the layout is legible immediately, with `OrbitControls`
letting the user drop to a true top-down or walk-through-ish angle themselves.

### Architectural massing (building form study)

Stack/combine boxes (and occasionally `ExtrudeGeometry` for non-rectangular footprints)
to represent building volumes at massing-study fidelity — no windows/materials detail
needed unless asked:
```js
const base = new THREE.Mesh(new THREE.BoxGeometry(4, 3, 4), new THREE.MeshStandardMaterial({ color: 0xaaaaaa }));
base.position.y = 1.5;
const tower = new THREE.Mesh(new THREE.BoxGeometry(2, 6, 2), new THREE.MeshStandardMaterial({ color: 0x8899aa }));
tower.position.set(0, 3 + 3, 0);
scene.add(base, tower);
```
Add a large ground plane and a low-angle directional light to cast readable shadows of
the massing relative to context, if the user cares about that framing.

## Composition checklist

- Group related primitives with `THREE.Group()` so the whole object can be positioned/
  rotated as one unit.
- Vary `roughness`/`metalness` deliberately per material — uniform default materials
  are the fastest way to make a scene look flat and generic.
- Give hero objects a pedestal/backdrop; give rooms a floor and at least two walls for
  spatial orientation; give massing studies a ground plane for scale context.
- If the user's request implies real proportions (a chair, a room of a stated size),
  keep relative scale roughly honest even if absolute units are simplified.
