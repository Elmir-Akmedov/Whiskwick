# Whiskwick Design Agent Prompt Pack

This pack is for image-generation agents producing cozy 2D pixel art for Whiskwick.
Target direction: Stardew Valley-inspired readability and warmth, while keeping Whiskwick-specific outfits, props, and palette.

For motion loops, pair with `docs/ANIMATION_AGENT_PROMPTS.md`.

## Style Bible

- Style: hand-crafted 2D pixel art sprites and tiles, top-down/three-quarter top-down gameplay readability.
- Resolution target: gameplay-ready for 32 px grid tiles.
- Character scale: readable at ~32 to 48 px height.
- Palette: warm bakery tones (cream, butter, oat, honey wood, sage, muted teal, cocoa) with restrained saturation.
- Linework: subtle dark outline clusters only where needed for silhouette clarity.
- Shading: soft cluster shading, no smooth 3D gradients.
- Lighting: stable top-left light source.
- Mood: calm, cozy, clean, and friendly.

## Global Negative Prompt

No photorealism, no anime style, no neon palette, no heavy bloom, no text labels, no watermarks, no signatures, no extreme perspective, no messy anti-aliased blur, no inconsistent sprite scale.

## Production Prompts

### 1. Player Baker Base Sprite
Create a Whiskwick player baker base sprite in cozy 2D pixel art, top-down three-quarter view, cream apron over sage shirt, dark trousers, simple practical shoes, clean silhouette readable at 32 px tile scale, transparent background.

### 2. Worker Set (Baker/Cashier/Runner/Cleaner)
Create a 4-character lineup in matching pixel style: baker, cashier, runner, cleaner. Each character must have a distinct silhouette and role prop, consistent camera angle, transparent background, spacing for easy crop.

### 3. Customer Set
Create six customer sprites in one sheet: student, office worker, elder regular, parent, kid, tourist. Keep muted cozy clothing colors and silhouette clarity from top-down gameplay camera.

### 4. Starter Machines
Create pixel-art placeables: small oven (2x1), prep counter (2x1), mixer (1x1), cashier stand (2x1), display case (2x1), warehouse rack (2x1). Transparent background, clear interaction side.

### 5. Ingredient/Logistics Props
Create a set of 1x1 props: flour crate, egg crate, sugar bag crate, milk bottle crate, delivery parcel, trash bin, small plant. Consistent scale and color language.

### 6. Floor/Wall Tiles
Create a tile sheet with seamless 32 px tiles for sales room, kitchen, warehouse, and transitions (door threshold and queue marker). Keep low-noise patterns for clean readability.

### 7. UI Icon Sheet
Create a 6x4 icon sheet (coin, stamina, clock, open/close, ingredients, products, worker, patience, crate) in matching pixel style, high contrast at HUD size, no text.

## Batch QA Checklist

- All sprites match one pixel scale and camera angle.
- Silhouettes are readable at target gameplay size.
- Tile seams are clean at repetition boundaries.
- No text/logo/watermark artifacts.
- Props and machines have clear front/interaction side.
