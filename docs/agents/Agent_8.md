# Agent 8 - Art QA And Integration Gate

## Objective
Validate all art outputs and provide pass/fix decisions.

## Inputs
- Outputs from Agents 1 to 7
- docs/DESIGN_AGENT_PROMPTS.md
- docs/ANIMATION_AGENT_PROMPTS.md

## Tasks
1. Check palette and style consistency.
2. Check gameplay readability at target scale.
3. Check sheet grid integrity and frame alignment.
4. Check tile seam quality by repetition tests.
5. Build fix list for any rejected assets.

## Output Files
- docs/agents/ART_QA_REPORT.md

## Acceptance Criteria
- Every approved file passes prompt-pack QA checks.
- Rejected files include exact reason and fix direction.
- Final report marks batch status as PASS or REVISE.