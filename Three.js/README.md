# threejs-studio

A Claude plugin that turns requests into diverse, interactive 3D visuals using the
**Three.js 3D Viewer** connector (`show_threejs_scene` / `learn_threejs`).

Rather than one generic "make a 3D thing" skill, this plugin splits the work into a
shared foundation plus five domain-specialized skills, so the output is idiomatic for
whatever the user is actually asking for.

## Skills

| Skill | Purpose |
|---|---|
| `threejs-core` | **Mandatory prerequisite.** Connector execution model, lighting/camera/controls/animation-loop rules, and routing logic to the specialized skills below. Always loaded first. |
| `threejs-data-viz` | 3D bar charts, scatter plots, and surface/heightmap plots for real datasets — every visual channel (position, height, color) maps to actual data. |
| `threejs-science-lab` | Physics & science simulations — orbital mechanics, molecular ball-and-stick models, waves/fields, simple force integration — built to teach real mechanisms. |
| `threejs-algo-viz` | Algorithm & data-structure visualizations — sorting, linked lists, trees, graphs, stacks/queues/hash tables — animated step-by-step, visual-first. |
| `threejs-generative-art` | Abstract/decorative scenes — particle fields, procedural noise-driven geometry, instanced swarms, bloom/glow post-processing. |
| `threejs-product-showcase` | Concrete real-world objects — product mockups on a pedestal, room/interior layouts, architectural massing studies, built from composed primitives. |

## How it works

1. A request that implies "show this as an interactive 3D visual" triggers
   `threejs-core`, which sets the non-negotiable execution rules (scene/camera/
   renderer setup, lighting, `OrbitControls`, animation loop, no external assets).
2. `threejs-core` routes to whichever specialized skill matches the domain of the
   request (see table above), which supplies copy-ready code templates and
   domain-specific composition guidance.
3. Claude writes the scene code following both skills' rules and calls
   `show_threejs_scene`, then explains what's shown and how to interact with it.

## Notes

- No `.mcp.json` is bundled — the Three.js 3D Viewer connector is expected to already
  be available as a tool in the environment this plugin is installed into.
- All scenes are built from Three.js primitives only (no texture/model imports), per
  `threejs-core` rule 10 — every specialized skill's templates follow this constraint.
