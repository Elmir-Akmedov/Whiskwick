# Whiskwick: Cozy Kitchen Roadmap

## North Star

Whiskwick is a landscape top-down cozy food shop tycoon. The player begins with a tiny sales room, kitchen, and warehouse, then grows into the town's favorite food spot by planning menus, buying ingredients from a tablet, receiving deliveries in the warehouse, preparing stock, surviving the rush, training workers, placing machines, expanding rooms, fulfilling bulk orders, and unlocking story chapters.

## Core Daily Loop

```text
07:00 Morning prep
-> Buy ingredients
-> Prepare raw/prep/finished stock
-> Choose today menu
-> Review forecast and bulk orders
-> 10:00 shop opens automatically
-> Customers arrive
-> Pause/resume new orders as needed
-> Cook, restock, serve, pack, and manage workers
-> 19:00 shop closes automatically
-> Optional night prep with stamina penalties
-> Sleep
-> End-day report, XP, money, story, unlocks
```

## Current Technical Direction

- Engine: Godot 4.
- Language: GDScript.
- Target: landscape Android/mobile, with desktop testing builds.
- Monetization: premium/itch-first prototype, no ads or IAP in v1.
- Art direction: top-down 2D gameplay using realistic 3D pixel/voxel-like rendered assets as sprites or reference art.
- Layout direction: grid-based rooms with placeable/rotatable machines, shelves, tables, and warehouse racks.

## First 20 Build Phases

1. Build project skeleton and autoload services.
2. Make the main landscape top-down shop scene readable on phone and desktop aspect ratios.
3. Add data loading for recipes, ingredients, day themes, and workers.
4. Implement in-game time from 07:00 to sleep.
5. Add automatic opening at 10:00 and closing at 19:00.
6. Add player stamina and exhaustion penalties.
7. Add raw ingredient buying.
8. Add warehouse/storage capacity.
9. Add prep counter stock.
10. Add oven cooking with recipe time and batch yield.
11. Add finished stock/display shelf.
12. Add customer order tickets.
13. Add customer patience.
14. Add pause/resume new orders.
15. Add manual serving and payment.
16. Add end-day report.
17. Add XP, coins, reputation, and level unlocks.
18. Add capacity-based daily Bronze/Silver/Gold/Legendary goals.
19. Add first worker: cashier.
20. Add first worker: baker with stamina and known recipes.
21. Add room definitions for sales room, kitchen, and warehouse.
22. Add placeable data for machines, shelves, tables, racks, and decor.
23. Add grid-placement validation for footprint, rotation, room limits, and overlap.
24. Add player top-down movement prototype.
25. Add tablet ordering concept: ingredients arrive in warehouse receiving zone.
26. Add designer prompt pack for characters, machines, rooms, items, and UI icons.
27. Replace graybox rectangles with first generated/hand-cleaned placeholder asset set.
28. Add room expansion rules and visual expansion states.

## First Playable Acceptance Criteria

- Player starts at 07:00 with money and stamina.
- Player buys ingredients.
- Player cooks a cupcake batch.
- Shop opens automatically at 10:00.
- Customers order from the available menu.
- Player can pause and resume new orders.
- Shop closes at 19:00.
- End-day report shows money, XP, orders served, orders missed, and goal tier.

## Testing Checklist

- Time advances correctly and phase changes fire once.
- Skip time moves only to the next safe milestone.
- Pausing orders stops new orders but does not stop the clock.
- Recipe data loads from JSON.
- Missing recipe IDs fail safely.
- Inventory cannot go negative.
- Cooking consumes ingredients and creates finished stock.
- Workers cannot cook unknown recipes.
- Worker stamina decreases by workload points.
- Capacity service never offers impossible bulk orders.
- Portrait UI remains usable at small phone sizes.
- Landscape UI remains usable at mobile and desktop sizes.
- Grid placement rejects overlaps and wrong-room placement.
- Player can move around the top-down graybox shop.
- Generated design assets follow the style bible and are tracked in `ASSET_CREDITS.md`.
