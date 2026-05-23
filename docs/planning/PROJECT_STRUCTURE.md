# Whiskwick Project Structure

This layout keeps runtime files grouped by responsibility and keeps production references away from playable game assets.

## Runtime

- `project.godot`: Godot project settings, autoloads, and the main scene path.
- `scenes/gameplay/`: playable world scenes such as `Main.tscn` and spawned gameplay entities.
- `scenes/screens/`: full-screen menus, market, upgrades, and day summary screens.
- `scenes/ui/`: reusable UI scene fragments such as the HUD.
- `scripts/autoload/`: global state, managers, and services.
- `scripts/gameplay/`: main scene controller, player controller, and world-grid scripts.
- `scripts/components/`: entity-level behavior attached to machines, customers, stockpiles, and workers.
- `scripts/systems/`: domain services that coordinate multiple nodes or services.
- `scripts/data/`: typed data resource definitions.
- `scripts/ui/`: HUD, screen controllers, and navigation helpers.
- `scripts/visual/`: generated-art presentation helpers.

## Content

- `data/`: canonical JSON content for ingredients, recipes, rooms, machines, placeables, workers, and day themes.
- `assets/art/pixel/`: hand-authored individual pixel sprites.
- `assets/art/generated/`: generated sprite sheets, manifests, tiles, icons, effects, and animation batches.
- `assets/art/icon_placeholder.svg`: temporary project icon.

## Documentation And Production

- `docs/planning/roadmap.md`: roadmap and milestone planning.
- `docs/planning/CODEX_PROMPT_WHISKWICK.md`: older project prompt archive.
- `docs/*_DESIGN_BRIEF.md`: art and style constraints.
- `docs/*_AGENT_PROMPTS.md`: prompt packs for generated assets and animation work.
- `docs/agents/`: per-agent production notes and trackers.
- `docs/credits/`: asset credit and license notes.
- `docs/ai_skills/source_packages/`: downloaded AI skill packages and reference markdown.
- `tools/`: scripts for asset generation and local project utilities.

## Suggested Next Steps

1. Keep new gameplay features in `scripts/gameplay/`, `scripts/components/`, or `scripts/systems/` based on ownership.
2. Move one system at a time when refactoring. Update `.tscn`, `.gd`, `.import`, and docs paths in the same change.
3. Add a small validation script later that checks all JSON files parse and all `res://` paths referenced by scripts/scenes exist.
4. Split large `Main.gd` behavior into focused components only when a feature is actively being changed.
5. Keep generated art sheets under `assets/art/generated/` and only put final individual sprites in `assets/art/pixel/`.
