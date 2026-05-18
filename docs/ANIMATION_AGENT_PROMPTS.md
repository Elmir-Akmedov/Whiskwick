# Whiskwick Animation Agent Prompt Pack

Use this pack for sprite-loop generation in cozy 2D pixel art (Stardew Valley-inspired direction).

## Global Rules

- Camera: top-down/three-quarter top-down and fixed per sheet.
- Background: transparent.
- Grid: strict equal cells, no labels.
- Scale: consistent sprite size across frames.
- Motion: readable, subtle, and cozy; no exaggerated smear frames.
- Palette/shading: match `docs/DESIGN_AGENT_PROMPTS.md`.

## Export Targets

- Character loops: `4 x 2` or `5 x 2`.
- FX loops: `6 x 1` or `8 x 1`.
- Keep frame spacing consistent and feet anchored for walk cycles.

## Prompts

### 1. Player Idle + Walk
Create a `4x2` sheet for the player baker: idle loop + walk north/east/south/west + settle frames. Keep outfit consistent (cream apron, sage shirt, dark trousers), transparent background, fixed camera and scale.

### 2. Baker Task Loop
Create a `5x2` sheet: idle, knead, stir, load oven, unload tray, walk north/east/south/west, tired pose. Keep chef-hat/apron silhouette clear.

### 3. Cashier Task Loop
Create a `5x2` sheet: idle, receive payment, tap register, hand bag, happy sale, walk north/east/south/west, tired pose.

### 4. Runner Task Loop
Create a `5x2` sheet: idle, carry sack, carry crate, push cart, place stock, walk north/east/south/west, tired pose.

### 5. Cleaner Task Loop
Create a `5x2` sheet: idle, sweep, wipe table, carry bucket, clear tray, walk north/east/south/west, tired pose.

### 6. Customer Queue Loop
Create a `4x2` sheet: wait, browse, order gesture, impatience, happy receive, satisfied leave, disappointed leave, placeholder shadow slot.

### 7. Coin Gain FX
Create an `8x1` pixel FX loop: coin pop, upward float, sparkle, fade.

### 8. Oven Heat FX
Create a `6x1` subtle heat shimmer loop near oven door area.

### 9. Patience Icons
Create a `3x1` strip for patience states: green/yellow/red with same shape and increasing urgency.

## QA Checklist

- Fixed cell size and alignment.
- Stable foot anchoring for walk loops.
- Matching palette with static art pack.
- Readable at gameplay size.
- No text, logo, watermark, or style drift.
