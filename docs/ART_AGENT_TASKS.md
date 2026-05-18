# Whiskwick Art Agent Tasks

Direction: Stardew Valley-inspired cozy 2D pixel art for top-down bakery tycoon gameplay.

## Agent 1: Character Base Sprites

- Input: `docs/DESIGN_AGENT_PROMPTS.md` sections 1 to 3.
- Task: Produce player, 4 worker roles, and 6 customer base sprites.
- Output: transparent PNG sheets with clean separations per character.
- Done when: silhouettes are readable at 32 to 48 px and role identity is clear.

## Agent 2: Placeable Machines

- Input: `docs/DESIGN_AGENT_PROMPTS.md` section 4.
- Task: Produce starter machine set (oven, prep counter, mixer, cashier stand, display case, warehouse rack).
- Output: transparent PNG assets aligned to intended 1x1 / 2x1 / 2x2 footprints.
- Done when: each machine has a clear interaction/front side.

## Agent 3: Props And Logistics

- Input: `docs/DESIGN_AGENT_PROMPTS.md` section 5.
- Task: Produce ingredient crates and logistics props.
- Output: transparent PNG prop sheet with 1x1-consistent scale.
- Done when: all props are distinguishable in-game at small size.

## Agent 4: Tiles And Materials

- Input: `docs/DESIGN_AGENT_PROMPTS.md` section 6.
- Task: Produce floor/wall tile sheets for sales room, kitchen, warehouse, and transition tiles.
- Output: seamless tile atlas PNG.
- Done when: repeated tiling shows no visible seams.

## Agent 5: UI Icons

- Input: `docs/DESIGN_AGENT_PROMPTS.md` section 7.
- Task: Produce full HUD icon sheet (6x4).
- Output: transparent icon atlas.
- Done when: icons remain readable at small HUD scale without labels.

## Agent 6: Character Animation

- Input: `docs/ANIMATION_AGENT_PROMPTS.md` prompts 1 to 6.
- Task: Produce player/worker/customer loop sheets.
- Output: `4x2` and `5x2` loop sheets with consistent anchoring.
- Done when: loops play cleanly in sequence with no frame jitter.

## Agent 7: Gameplay FX Animation

- Input: `docs/ANIMATION_AGENT_PROMPTS.md` prompts 7 to 9.
- Task: Produce coin FX, oven heat FX, and patience-state strip.
- Output: FX sheets (`8x1`, `6x1`, `3x1`).
- Done when: FX read clearly over both light and dark floor tiles.

## Agent 8: Art QA + Integration Gate

- Input: all generated outputs from Agents 1 to 7.
- Task: Validate scale, palette consistency, seam quality, and style drift.
- Output: acceptance log + reject/fix list.
- Done when: all approved assets pass both prompt-pack QA checklists.

## Delivery Order

1. Agents 1, 2, 3, 4, 5 run in parallel.
2. Agent 6 starts after Agent 1 base sprites are approved.
3. Agent 7 can run in parallel with Agent 6.
4. Agent 8 validates final combined batch.
