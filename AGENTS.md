# Whiskwick Repository Directives

## Coding Rules

- Prefer strict typing in all GDScript APIs. Add explicit argument and return types for new or changed functions.
- Do not use silent fallbacks for runtime failures. Validate inputs and return explicit errors or emit failure signals.
- Keep diffs minimal. Patch only the exact files and sections needed for the current task.
- Preserve existing architecture boundaries:
  - `scripts/autoload/`: global state/services only.
  - `scripts/gameplay/`: main shop-floor scene scripts, player controls, and world-grid presentation.
  - `scripts/components/`: entity-level behavior.
  - `scripts/systems/`: domain logic that coordinates multiple components/services.
  - `scripts/data/`: typed data resources.
  - `scripts/ui/`: HUD, navigation helpers, and screen controllers.

## Data And Validation

- JSON data under `data/` is the canonical content source. Script defaults must not drift from data definitions.
- When loading data, fail loudly for missing required fields and malformed types.
- Never allow negative inventory, capacity overflow, or invalid room placement states.

## Testing Expectations

- For gameplay/script edits, run headless Godot validation:
  - `.\open_godot.ps1`
- For balance/data edits, verify all changed JSON files parse and required keys exist.
- For UI-flow edits, test at least one morning-to-close loop (07:00 to 19:00) and validate end-day report values.

## Current Plan Baseline

- Continue the roadmap in `docs/planning/roadmap.md`.
- Keep design prompts centralized in `docs/DESIGN_AGENT_PROMPTS.md`.
- Use `docs/CHARACTER_DESIGN_BRIEF.md` and `docs/MACHINE_AND_ITEM_DESIGN_BRIEF.md` as style constraints for generated assets.
- Use `docs/ANIMATION_AGENT_PROMPTS.md` for sprite-sheet and motion generation prompts.

## Project Structure

- Gameplay scenes live in `scenes/gameplay/`.
- Menu, market, upgrade, shop-floor test, and summary scenes live in `scenes/screens/`.
- Shared UI scene fragments live in `scenes/ui/`.
- Loose hand-authored pixel art lives in `assets/art/pixel/`.
- Generated sheets and batch manifests stay in `assets/art/generated/`.
- Planning docs live in `docs/planning/`; production prompts and briefs stay under `docs/`.
- AI skill/source packages live in `docs/ai_skills/source_packages/`.
- Art and generation utilities live in `tools/`.

## Morph MCP Workflow

- Use Morph `edit_file` over string replacement or full-file writes when the tool is available.
- Use `warpgrep_codebase_search` for broad semantic exploration before changing unfamiliar systems.
