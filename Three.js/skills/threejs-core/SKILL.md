---
name: threejs-core
description: >
  MANDATORY prerequisite — load this skill BEFORE every `show_threejs_scene` tool call
  (the Three.js 3D Viewer connector). NEVER call `show_threejs_scene` directly without
  loading this skill first. Trigger whenever the user wants anything rendered as an
  interactive 3D visual: "show me in 3D", "visualize this in three.js", "make this
  interactive/rotatable", "build a 3D model/scene/animation", or any request that would
  clearly benefit from a real 3D view instead of a flat SVG diagram or 2D chart. This
  skill also routes to the right specialized skill (data-viz, science-lab, algo-viz,
  generative-art, product-showcase) based on what the user is asking for.
metadata:
  version: "0.1.0"
  author: "Nav"
---

# threejs-core — Foundation for the Three.js 3D Viewer

This is the shared foundation for every skill in the threejs-studio plugin. It covers
the connector's execution model, the non-negotiable code rules, and how to pick which
specialized skill to layer on top. Read this first, always — even for a "simple" scene.

## 1. What the connector actually does

`show_threejs_scene` (Three.js 3D Viewer, tagged `[third_party_mcp_app]`) takes a
`code` string and renders it inline in the chat as a live, interactive canvas. There is
also `learn_threejs`, which returns quick-reference docs/examples — call it once per
session if you're unsure of current syntax, but don't call it if this skill already
covers what you need.

**Execution model:**
- Your `code` runs in a sandboxed browser context with these globals already defined:
  `THREE`, `canvas`, `width`, `height`, `OrbitControls`, `EffectComposer`,
  `RenderPass`, `UnrealBloomPass`.
- Do NOT create your own `<canvas>`, import Three.js, or set up a module system. Use
  the globals directly.
- Do NOT wrap the code in an IIFE or worry about cleanup/unmounting — the host handles
  the canvas lifecycle.
- The scene is genuinely interactive (mouse drag/scroll via `OrbitControls`), so treat
  every request as "build a small live demo," not "render a static picture."

## 2. Non-negotiable code rules

1. **Always create scene, camera, renderer in that order**, sized to `width`/`height`:
   ```js
   const scene = new THREE.Scene();
   const camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 1000);
   const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
   renderer.setSize(width, height);
   renderer.setClearColor(0x000000, 0); // transparent, blends with host UI
   ```
2. **Default to a transparent background** (`alpha: true` + `setClearColor(0x000000, 0)`)
   so the scene blends into the chat UI. Only use a solid `setClearColor(hexColor)`
   (no alpha arg) when the content needs a deliberate backdrop — e.g. a night-sky
   scene, a "room" for a product showcase, or contrast for very light-colored objects.
3. **Always light the scene.** A bare `MeshStandardMaterial`/`MeshPhysicalMaterial`
   mesh with no lights renders pure black. Minimum viable lighting:
   ```js
   scene.add(new THREE.DirectionalLight(0xffffff, 1));
   scene.add(new THREE.AmbientLight(0x404040));
   ```
   Keep directional light intensity ≤ 1 to avoid blown-out highlights. Use
   `MeshBasicMaterial` only for things that should look intrinsically self-lit (e.g.
   stars, wireframes, UI gizmos) — everything else should be Standard/Physical so it
   reads as a real 3D object rather than a flat cutout.
4. **Add `OrbitControls` by default** for anything the user is meant to explore:
   ```js
   const controls = new OrbitControls(camera, renderer.domElement);
   controls.enableDamping = true;
   ```
   Skip it only for very short, purely-decorative loop animations where user framing
   doesn't matter.
5. **Animate with `requestAnimationFrame`, and call `controls.update()` inside the
   loop** if controls exist:
   ```js
   function animate() {
     requestAnimationFrame(animate);
     controls.update();
     // per-frame mutations here
     renderer.render(scene, camera);
   }
   animate();
   ```
   For a static, non-animated scene, skip the loop entirely and just call
   `renderer.render(scene, camera)` once — don't spin up `requestAnimationFrame` for
   nothing.
6. **Position the camera deliberately.** Frame the whole scene — for an object of
   radius ~1, `camera.position.set(x, y, z)` with a magnitude of 3-6 is a reasonable
   start; for spread-out scenes (e.g. multi-object data viz), pull back further and
   angle the camera down slightly (`camera.position.set(a, b, c); camera.lookAt(0,0,0)`)
   so the viewer isn't staring edge-on at a flat layout.
7. **Keep geometry segment counts sane.** `SphereGeometry(r, 32, 32)` /
   `CylinderGeometry(..., 32)` is plenty for smooth-looking shapes without tanking
   frame rate. Don't reach for 128+ segments unless there's a specific visual reason.
8. **Respect geometry version limits.** This is Three.js r181 — recent APIs are fine.
   Do not rely on removed/renamed APIs from very old tutorials (e.g. `THREE.Geometry`,
   `THREE.CanvasRenderer`) — use `BufferGeometry`-based classes (the default in modern
   Three.js) throughout.
9. **Color as hex integers**, not CSS strings, for materials/lights:
   `new THREE.MeshStandardMaterial({ color: 0x4f8ef7 })`.
10. **No external assets.** No texture loaders pointed at arbitrary URLs, no imported
    fonts/models. Build everything from primitive geometries, `THREE.Shape`/
    `ExtrudeGeometry`, `BufferGeometry` with custom vertex data, or particle systems
    (`THREE.Points`). If the user provides actual data (numbers, categories, a small
    dataset), encode it procedurally into the geometry — don't fake it with a static
    image.

## 3. Routing to a specialized skill

Once you've decided a 3D scene is the right call, check what domain the request falls
into and load the matching skill alongside this one for domain-specific patterns and
copy-ready templates:

| User is asking for...                                                              | Load also |
|--------------------------------------------------------------------------------------|-----------|
| Charts/graphs/plots of numbers, categories, comparisons, distributions, time series | `threejs-data-viz` |
| Physics, molecules, orbits/solar systems, waves, fields, science concepts to teach   | `threejs-science-lab` |
| Sorting/search/trees/graphs/linked lists/DP grids — any CS/DSA concept to visualize  | `threejs-algo-viz` |
| Abstract/decorative art, particle effects, ambient backgrounds, "just make something cool" | `threejs-generative-art` |
| A specific object/product mockup, room/interior layout, architectural massing        | `threejs-product-showcase` |

If a request doesn't cleanly match any row (e.g. a genuinely novel scene), it's fine to
build directly from this core skill's rules alone — the specialized skills add
domain vocabulary and templates, they don't gate whether you can proceed.

## 4. Workflow

1. Identify the domain and load the matching specialized skill (step 3 above).
2. Sketch the scene mentally: what are the 3D objects, what does position/scale/color
   *mean* in this scene (this matters a lot for data-viz and algo-viz — every visual
   property should map to something real), what's static vs. animated, does the user
   need to interact with specific elements or just view the whole thing.
3. Write the code following the rules in section 2, plus the domain template from the
   specialized skill.
4. Call `show_threejs_scene` with a short, specific `title` and 1-4 fitting
   `loading_messages` (~5 words each, playful and topic-relevant unless the topic is
   sensitive — see the tool's own guidance).
5. Follow the visual with a brief, plain-language explanation of what's shown and how
   to interact with it (drag to rotate, scroll to zoom) — don't just drop the widget
   silently.

## 5. Common pitfalls

- **Black screen** → missing lights, or camera not positioned/looking at content.
- **Nothing visible** → camera clipping planes (`0.1, 1000`) don't cover object
  distance, or object scale is off by orders of magnitude from camera distance.
- **Frozen/no interaction** → forgot `controls.update()` inside the animation loop.
- **Looks flat/2D despite being "3D"** → all objects on the same z-plane with an
  orthographic-feeling camera angle; vary depth (z) and/or tilt the camera off-axis.
- **Overwhelming/cluttered** → too many objects with no visual hierarchy; use color,
  scale, and spacing to group related elements, and don't be afraid to simplify what
  the user asked for into its clearest 3D expression.
