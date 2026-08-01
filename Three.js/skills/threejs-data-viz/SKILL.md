---
name: threejs-data-viz
description: >
  This skill should be used when the user wants numeric or categorical data rendered
  as an interactive 3D visualization via the Three.js 3D Viewer — trigger phrases
  include "3D bar chart", "3D scatter plot", "surface plot", "visualize this dataset
  in 3D", "turn this spreadsheet/CSV into a 3D chart", or any comparison/distribution/
  time-series request where the user explicitly wants depth or interactivity beyond a
  flat 2D chart. Always load `threejs-core` alongside this skill before calling
  `show_threejs_scene`.
metadata:
  version: "0.1.0"
  author: "Nav"
---

# threejs-data-viz — 3D Charts & Data Visualization

Encode real data into 3D geometry so position, height, size, and color all carry
meaning. This skill assumes `threejs-core` rules (lighting, controls, animation loop)
are already being followed.

## When to reach for 3D instead of a flat chart

3D earns its place when there's a genuine third dimension of meaning (e.g. two
independent categorical axes plus a value, or a real spatial/time dimension), or when
the user explicitly asked for something 3D/interactive. For a simple single-series
comparison, a flat chart (Visualizer's `chart` module) is usually clearer — don't force
data into 3D just because this skill exists. If the request is genuinely 2D in nature,
say so and suggest a normal chart instead.

## Core patterns

### 3D bar chart (categories × categories × value)

Place bars on an X/Z grid, scale height (Y) by value, color-encode a second variable.

```js
const data = [
  { x: 0, z: 0, value: 4.2, label: "Q1" },
  { x: 1, z: 0, value: 6.8, label: "Q2" },
  // ...
];
const maxValue = Math.max(...data.map(d => d.value));
const spacing = 1.5;

data.forEach(d => {
  const height = (d.value / maxValue) * 4; // normalize to a 0-4 unit range
  const geometry = new THREE.BoxGeometry(0.8, height, 0.8);
  const color = new THREE.Color().setHSL(0.6 - (d.value / maxValue) * 0.5, 0.7, 0.5);
  const material = new THREE.MeshStandardMaterial({ color, roughness: 0.4 });
  const bar = new THREE.Mesh(geometry, material);
  bar.position.set(d.x * spacing, height / 2, d.z * spacing); // base sits on y=0
  scene.add(bar);
});
```

Add a faint ground plane so bars read as "standing on" something:
```js
const ground = new THREE.Mesh(
  new THREE.PlaneGeometry(20, 20),
  new THREE.MeshStandardMaterial({ color: 0x222233, roughness: 1 })
);
ground.rotation.x = -Math.PI / 2;
scene.add(ground);
```

### 3D scatter plot (three continuous variables)

```js
data.forEach(d => {
  const geometry = new THREE.SphereGeometry(0.12, 16, 16);
  const material = new THREE.MeshStandardMaterial({
    color: new THREE.Color().setHSL(d.category / numCategories, 0.7, 0.55),
  });
  const point = new THREE.Mesh(geometry, material);
  point.position.set(d.x, d.y, d.z); // pre-normalize x/y/z into a similar range, e.g. -3..3
  scene.add(point);
});
```
For large datasets (100+ points), prefer `THREE.Points` with a `BufferGeometry` of
positions and per-vertex colors over individual meshes — meshes that numerous will hurt
frame rate.

### Surface / heightmap plot (continuous function of two variables)

Use a `PlaneGeometry` and displace vertices by value:
```js
const resolution = 40;
const geometry = new THREE.PlaneGeometry(6, 6, resolution, resolution);
const pos = geometry.attributes.position;
for (let i = 0; i < pos.count; i++) {
  const x = pos.getX(i), y = pos.getY(i);
  const z = Math.sin(x * 1.5) * Math.cos(y * 1.5); // replace with real f(x, y)
  pos.setZ(i, z);
}
geometry.computeVertexNormals();
const surface = new THREE.Mesh(
  geometry,
  new THREE.MeshStandardMaterial({ color: 0x4f8ef7, side: THREE.DoubleSide, flatShading: false })
);
surface.rotation.x = -Math.PI / 2;
scene.add(surface);
```

### Axis labels and reference lines

Three.js has no built-in text unless drawn manually; when labels matter, either:
- keep the visual self-explanatory via color legends explained in your prose response, or
- draw simple tick marks/gridlines with `THREE.Line`/`THREE.LineSegments` rather than
  attempting text geometry (avoid font loaders — see threejs-core rule 10).

## Layout checklist

- Normalize all axes into a comparable numeric range (e.g. roughly -3 to 4) before
  building geometry — raw data units (dollars, counts) will produce wildly
  mis-scaled scenes.
- Always add a ground/reference plane or gridlines for bar/surface charts so depth is
  legible without needing to rotate immediately.
- Angle the camera down and back (`camera.position.set(6, 6, 8); camera.lookAt(0, 1, 0);`)
  rather than head-on, so the third dimension is visible on first render.
- Mention in your reply what each visual channel (position/height/color) encodes —
  don't make the user guess the legend.
