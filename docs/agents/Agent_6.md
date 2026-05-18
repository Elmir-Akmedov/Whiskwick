# Agent 6 - Character Animation

## Objective
Generate gameplay-ready character loops using approved base sprites.

## Inputs
- docs/ANIMATION_AGENT_PROMPTS.md (prompts 1 to 6)
- Approved outputs from Agent 1

## Tasks
1. Player idle + walk sheet (4x2).
2. Baker loop sheet (5x2).
3. Cashier loop sheet (5x2).
4. Runner loop sheet (5x2).
5. Cleaner loop sheet (5x2).
6. Customer queue loop (4x2).

## Output Files
- assets/art/generated/animations/player_idle_walk_4x2.png
- assets/art/generated/animations/baker_loop_5x2.png
- assets/art/generated/animations/cashier_loop_5x2.png
- assets/art/generated/animations/runner_loop_5x2.png
- assets/art/generated/animations/cleaner_loop_5x2.png
- assets/art/generated/animations/customer_queue_4x2.png

## Constraints
- Fixed cell size per sheet.
- Feet anchoring stable across walk cycles.
- No scale drift between frames.

## Acceptance Criteria
- Loops play without jitter.
- Roles are readable while moving.
- Palette and shading match static character sprites.