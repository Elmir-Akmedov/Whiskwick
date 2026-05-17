# Placement System

## Current Prototype

The build mode is a landscape top-down grid prototype.

- Select an object from the HUD.
- Move the mouse over a valid room.
- The preview follows the grid.
- Green preview means the object can be placed.
- Red preview means it is blocked, outside the room, or overlapping.
- Left-click places the object.
- Right-click cancels placement.
- Rotate changes the footprint by 90 degrees.

## Rooms

The starter graybox uses three rooms:

- `sales_room`: tables, shelves, cashier/service objects.
- `kitchen`: ovens, prep counters, machines, worker stations.
- `warehouse`: racks, crates, tablet deliveries, storage.

Each room has:

- grid origin
- grid size
- allowed object categories
- expansion rules in data

## Footprints

Objects use tile footprints, not pixels.

Examples:

- two-seat table: `2x2`
- basic oven: `2x2`
- warehouse shelf: `2x1`

Rotation swaps width/height for 90 and 270 degrees.

## Validation Rules

Placement fails if:

- the room does not exist
- the footprint is outside room bounds
- the footprint overlaps an existing placed object
- future rule: the object is not allowed in that room
- future rule: a required interaction side is blocked
- future rule: customer/worker pathing is blocked

## Next Implementation Steps

1. Use DataLibrary room origins instead of hardcoded room constants.
2. Validate allowed rooms for both machines and placeables.
3. Add build cost and money checks.
4. Add sell/move mode.
5. Add path checks for customer lane and worker access.
6. Add touch controls for mobile.
7. Save and load placed objects.

