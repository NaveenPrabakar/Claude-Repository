---
name: threejs-algo-viz
description: >
  This skill should be used when the user wants a computer-science concept — an
  algorithm, data structure, or its execution — rendered as an interactive 3D
  visualization via the Three.js 3D Viewer. Trigger phrases include "visualize this
  algorithm in 3D", "show me how [sorting/search/traversal] works", "build a 3D
  linked list/tree/graph/stack/heap", "animate this data structure", or LeetCode/DSA
  explanations where the user wants a spatial, interactive view rather than a static
  diagram. Always load `threejs-core` alongside this skill before calling
  `show_threejs_scene`. Complements — does not replace — the leetcode-tutor-suite
  skills, which teach the code/logic; this skill is for the 3D visual layer.
metadata:
  version: "0.1.0"
  author: "Nav"
---

# threejs-algo-viz — Algorithm & Data Structure Visualization

Visual-first teaching: show the mechanics of the structure or algorithm in 3D space
before or alongside any code discussion. Every mesh's position, color, and motion
should map directly to a real state change in the algorithm — this is a simulation of
the algorithm's execution, not decoration. This skill assumes `threejs-core` rules
(lighting, controls, animation loop) are already being followed.

## Core patterns

### Array / list as a row of boxes (sorting, two-pointer, sliding window)

```js
const values = [5, 2, 8, 1, 9, 3];
const boxes = values.map((v, i) => {
  const geometry = new THREE.BoxGeometry(0.7, v * 0.3 + 0.3, 0.7); // height encodes value
  const material = new THREE.MeshStandardMaterial({ color: 0x4f8ef7 });
  const box = new THREE.Mesh(geometry, material);
  box.position.set((i - values.length / 2) * 1.0, (v * 0.3 + 0.3) / 2, 0);
  scene.add(box);
  return box;
});
```
Drive comparisons/swaps/pointers by recoloring (`box.material.color.set(0xffcc33)` for
"currently comparing", `0xe0664f` for "pivot", back to base color when done) and
animating `position.x` swaps over a few frames inside the animation loop — don't just
snap values instantly; a short lerp reads much better:
```js
box.position.x += (targetX - box.position.x) * 0.1; // per-frame easing toward target
```

### Linked list / pointers

Nodes as small spheres or boxes connected by thin cylinders (reuse the bond-drawing
helper from `threejs-science-lab`) or `THREE.Line` segments, laid out left-to-right or
along a gentle curve. Highlight the "current" node and animate a small marker (a cone
or arrow mesh) moving from node to node in a `next` traversal.

### Trees (BST, heaps, tries)

Layout children below and spread around the parent — classic tree-layout math:
```js
function layoutNode(node, depth, xMin, xMax) {
  const x = (xMin + xMax) / 2;
  const y = -depth * 1.4;
  node.position.set(x, y, 0);
  if (node.left) layoutNode(node.left, depth + 1, xMin, x);
  if (node.right) layoutNode(node.right, depth + 1, x, xMax);
}
```
Draw edges as thin cylinders/lines between parent and child positions after layout.
For a heap, an alternative is to *also* show the array-backing form (row of boxes) so
the parent/child index relationship is visible alongside the tree shape — a strong way
to make the "heap is really an array" insight land.

### Graphs (traversal, shortest path)

Nodes as spheres positioned via a simple force-directed-ish layout (or, if the user
gave explicit coordinates/a grid, just use those directly) with edges as lines. Animate
BFS/DFS/Dijkstra by progressively recoloring visited nodes and, for weighted graphs,
label edge weight via line thickness or color intensity rather than text.

### Stacks / queues / hash tables

Stack: vertical column of boxes, push/pop animates a box sliding in/out from the top.
Queue: horizontal row, enqueue/dequeue from opposite ends. Hash table: a row of
"bucket" columns (boxes at fixed x), with colliding keys stacked or chained visibly at
the same bucket — this is a great way to make collision handling concrete.

## Animating algorithm steps

For any multi-step algorithm, prefer a real step-by-step animation over a single static
snapshot:
1. Precompute the full list of "steps" as plain JS data (e.g.
   `[{type: 'compare', i: 0, j: 1}, {type: 'swap', i: 0, j: 1}, ...]`) before building
   any meshes.
2. In the animation loop, advance to the next step on a timer (e.g. every ~40-60
   frames, or ~0.7-1s) and apply its visual effect (recolor/reposition) with the easing
   pattern above.
3. Loop back to the start after the last step, or hold on the final state — holding is
   usually better so the user can see the completed structure.

## Teaching checklist

- Always map value → visual property explicitly (height = value, color = state) and
  say so in your reply, the same way `threejs-data-viz` does for charts.
- Keep step timing slow enough to actually watch (not a strobe) — err toward too slow
  over too fast.
- For LeetCode-style problems, pair this visual with a short explanation of what
  invariant or technique is being illustrated (e.g. "the two pointers only ever move
  inward"), matching the visual-first-then-code teaching approach.
