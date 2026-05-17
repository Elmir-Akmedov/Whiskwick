# Design Data Schema

These files are design-facing catalogs. They are safe to load later through `DataLibrary`, but they do not require current scripts or scenes to change.

## Files

- `data/items/item_categories.json`: Defines broad item behavior by inventory layer, storage tags, tablet ordering, stack limits, and spoilage group.
- `data/machines/starter_machines.json`: Defines production and storage machines with station type, footprint, room permissions, recipe tags, capacity, unlocks, and tuning.
- `data/rooms/room_definitions.json`: Defines sales room, kitchen, and warehouse size limits, expansion costs, grid rules, placement tags, and room-specific workflow rules.
- `data/placeables/starter_placeables.json`: Defines non-recipe layout objects such as counters, seating, decor, and utility storage.
- `data/workers/worker_roles.json`: Defines role-level worker behavior, task tags, room affinity, stamina tuning, and progression stats.

## Shared ID Rules

- IDs use lowercase snake case.
- Room IDs should match `allowed_rooms`.
- Machine `machine_type` should match recipe `station_type` when the machine can run that recipe.
- Tags are descriptive strings and should be reused rather than duplicated with near-synonyms.
- Economy fields are plain integers until a later balance pass needs decimals.

## Common Placement Fields

```json
{
  "footprint": {"width": 2, "height": 1},
  "rotation": {"allowed": true, "increments_degrees": 90},
  "allowed_rooms": ["kitchen"],
  "interaction_sides": ["front"],
  "placement_tags": ["worker_station"]
}
```

Use `placement_tags` for machines and `tags` for general placeables. Both represent the same design idea: room permissions and worker behaviors should be tag-driven.

## Room Permission Model

Room definitions expose `allowed_placeable_tags` and `blocked_placeable_tags`.

A future validator can accept placement when:

1. The object's `allowed_rooms` includes the room.
2. At least one of the object's tags appears in `allowed_placeable_tags`.
3. None of the object's tags appears in `blocked_placeable_tags`.
4. The footprint fits after rotation.
5. Required interaction sides remain reachable.
6. A valid path remains between room entry points.

## Worker Task Model

Worker role data is role-level design. Individual workers in `starter_workers.json` can keep personal stats such as stamina, quality bonus, and known recipes.

Role data answers:

- Which room does this worker prefer?
- Which task tags should the worker claim?
- Which placeable tags make good work anchors?
- Which stats improve as the role levels?

Individual worker data answers:

- Who is this worker?
- What recipes do they know?
- What are their current stamina and personal modifiers?
