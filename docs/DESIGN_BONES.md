# Whiskwick Design Bones

## Core Loop

```text
07:00 Morning prep
-> Buy ingredients
-> Prepare raw/prep/finished stock
-> Choose daily menu
-> 10:00 shop opens automatically
-> Customers arrive
-> Player may pause/resume new orders
-> Workers consume stamina and use nearby stock
-> 19:00 shop closes automatically
-> Optional night work with stamina penalties
-> Sleep and receive report/rewards/story progress
```

## Time Rules

- Day starts at 07:00.
- Shop opens at 10:00 automatically.
- Shop closes at 19:00 automatically.
- Night work is allowed after closing, but stamina costs increase after 22:00.
- Pausing orders stops new customers only. Time, active customers, cooking, spoilage, and stamina continue.

## Inventory Layers

- Raw ingredients: flour, eggs, sugar, milk, cheese, tomato.
- Prep stock: batter, dough, sauce, cream.
- Finished stock: cupcakes, cakes, pizza slices, omelets, drinks.

Inventory is stored in `InventoryService.raw`, `InventoryService.prep`, and `InventoryService.finished`.
Gameplay code should use service helpers instead of mutating those dictionaries directly.

### Shopping API

- `InventoryService.buy_ingredient(ingredient_id, amount = 1) -> Dictionary`
  - Looks up `ingredient_id` in `DataLibrary.ingredients`.
  - Uses `base_price * amount`.
  - Calls `GameState.spend_money(total_price)`.
  - Adds stock to the ingredient's configured `layer`.
  - Returns `{ "ok": bool, "message": String }` plus useful fields such as `price`, `money`, `layer`, and `amount`.

### Cooking API

- `DataLibrary.validate_recipe(recipe_id) -> Dictionary`
  - Checks that the recipe exists, uses known inventory layers, has positive ingredient amounts, and references known raw ingredients.
- `DataLibrary.get_recipe_ingredients_by_layer(recipe_id) -> Dictionary`
  - Returns normalized costs as `{ "raw": {...}, "prep": {...}, "finished": {...} }`.
  - Starter recipes may use the old flat format, which is treated as the recipe's `input_layer`.
- `InventoryService.can_craft_recipe(recipe_id) -> Dictionary`
  - Validates the recipe and reports missing stock by layer.
- `InventoryService.consume_recipe_ingredients(recipe_id) -> Dictionary`
  - Atomically consumes all required layered ingredients.
- `InventoryService.craft_recipe(recipe_id) -> Dictionary`
  - Instantly consumes ingredients and adds the recipe output to its `output_layer`.
- `CookStation.start_job_result(recipe_id) -> Dictionary`
  - Validates station type, validates layered ingredients, consumes inputs, and starts a timed job.
  - Existing `CookStation.start_job(recipe_id) -> bool` remains as a compatibility wrapper.

All new backend helpers return clear dictionaries with at least `ok` and `message`.

## Recipe Balance

Each recipe uses:

- `prep_minutes`
- `cook_minutes`
- `assembly_minutes`
- `workload_points`
- `batch_yield`
- `sell_price`
- `ingredient_cost`
- `station_type`
- `input_layer`
- `output_layer`
- `output_id`

Workload points drive worker stamina and daily score fairness.

## Worker Rules

- Workers have visible stamina.
- Workers only cook known recipes.
- Workers can only use ingredients/prep stock available at their station or nearby prep counter.
- Player begins manual. Workers and upgrades remove pain one system at a time.

## First Roles

- Cashier: accepts orders and payments.
- Baker: cooks known oven recipes.
- Runner: moves ingredients/stock.
- Cleaner: clears service mess and improves customer patience.
- Manager: improves forecasts and worker scheduling.

## Top-Down Shop Rooms

Whiskwick's shop layout is built as a top-down 2D grid with three foundational rooms:

- Sales room: customer entry, queue, service counters, display cases, seating, decor, and payment.
- Kitchen: prep counters, ovens, stovetops, pass counters, short-term stock, and worker production routes.
- Warehouse: tablet deliveries, ingredient intake, bulk storage, cold storage, and utility supplies.

The intended logistics loop is:

```text
Tablet order
-> Warehouse delivery intake
-> Warehouse storage
-> Runner/player moves stock to kitchen
-> Prep/cook/assemble
-> Sales room display or service counter
-> Customer purchase
```

Ingredient orders should be delivered to the warehouse, not directly to the kitchen. This makes storage, runners, and room expansion matter.

## Placement Foundation

Machines and placeable objects use grid footprints such as `{"width": 2, "height": 1}`. Most objects can rotate in 90-degree increments if they still fit inside room bounds and leave their interaction side reachable.

Placement should eventually validate:

- Object footprint does not overlap another blocking object.
- Object is allowed in the target room.
- Object tags are compatible with room allowed and blocked tags.
- At least one walkable path remains between important room entry points.
- Workers and customers can reach required interaction sides.

Room expansion is tuned per room with starter, minimum, and maximum sizes plus tile-based expansion costs. See `docs/ROOM_CONCEPT.md` for the full room concept and `docs/DATA_SCHEMA.md` for the design-data schema.
