# Machine And Item Design Brief

This brief defines the first 20 placeable assets for Whiskwick. It is design-facing only: visual direction, gameplay role, footprint, rotation, interaction sides, and upgrade variants. It does not define implementation data, scenes, or scripts.

## Shared Placement Language

- Grid tile target: 32 pixels per tile.
- Footprints are written as width x height in grid tiles before rotation.
- Rotations are 0, 90, 180, and 270 degrees unless an asset says otherwise.
- Interaction sides use top-down placement language: front, back, left, right. Front is the primary facing side at 0 degrees.
- Customer-facing objects should keep customer and worker sides visually distinct.
- Machines should read clearly from a phone screen: strong silhouette, bright interaction face, and minimal tiny detail.
- Upgrade variants should keep the same footprint where possible so replacing a placed object does not break a layout.

## Visual Direction

Whiskwick assets should feel hand-built, cozy, and practical. The shop is a working bakery, not a showroom: warm metal, painted wood, ceramic knobs, flour dust, folded cloths, clipped labels, and soft light are welcome. Each object needs a clear gameplay silhouette from the top-down view.

Suggested prompt style for generated or commissioned art:

```text
cozy top-down 2D bakery game asset, clean low-res illustrated sprite, readable silhouette, warm hand-painted texture, mobile game clarity, transparent background, no text labels, no people
```

## Asset Catalog

### 1. Starter Oven

- Room: Kitchen.
- Gameplay role: Early baking station for cupcakes, small cakes, and simple oven recipes.
- Footprint: 2 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for loading and collecting; left or right can show a small heat clearance zone visually but should not require interaction.
- Placement notes: Works best against a kitchen wall or counter run, but should also be valid as a freestanding station if the front is reachable.
- Visual prompt: Small rounded enamel oven with one glass door, brass handle, tiny temperature dial, warm orange glow, flour-dusted mitt on top.
- Upgrade variants:
  - Level 1: Single-door enamel oven, low capacity, slower cook time.
  - Level 2: Cleaner glass, brighter heat glow, small tray rail, modest speed and capacity bump.
  - Level 3: Double internal rack visible through the door, polished trim, better reliability and less burn risk.

### 2. Pro Oven

- Room: Kitchen.
- Gameplay role: Mid-to-late baking station for larger batches and advanced recipes.
- Footprint: 2 x 2.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for worker use; back is service/vent side and should not be required.
- Placement notes: Should look heavier than the starter oven and need visually readable clearance around its front.
- Visual prompt: Professional compact deck oven, two stacked doors, stainless steel with warm brass accents, vent pipe, glowing trays, cozy bakery style.
- Upgrade variants:
  - Level 1: Two-deck oven, medium capacity, faster than starter oven.
  - Level 2: Three visible rack lanes, improved insulation, higher batch yield.
  - Level 3: Premium stone-deck oven with side thermometer, best bake quality and speed.

### 3. Prep Counter

- Room: Kitchen.
- Gameplay role: General assembly surface for batter, dough, cream, chopping, and staging short-term prep stock.
- Footprint: 2 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for worker use; back can connect visually to wall or another counter.
- Placement notes: Should support adjacency with ovens, mixer, pan station, and packing station.
- Visual prompt: Wooden bakery prep counter with pale stone top, flour smudges, rolling pin, mixing bowl, folded towel, clean top-down readable form.
- Upgrade variants:
  - Level 1: Simple wooden counter, small prep capacity.
  - Level 2: Stone worktop with ingredient bins, increased prep storage.
  - Level 3: Wide organized station with inset boards and tool hooks, faster assembly actions.

### 4. Mixing Machine

- Room: Kitchen.
- Gameplay role: Converts raw ingredients into prep stock such as batter, dough, cream, and sauce.
- Footprint: 1 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for loading and collecting.
- Placement notes: Small but visually distinct; should not be confused with decor or storage.
- Visual prompt: Cute countertop stand mixer on a tiny wheeled base, large bowl, dough hook, pastel paint, gentle motion lines optional.
- Upgrade variants:
  - Level 1: Small stand mixer, single bowl, low batch size.
  - Level 2: Larger bowl and timer knob, faster mixing.
  - Level 3: Twin-bowl mixer with polished base, can queue or produce larger prep batches.

### 5. Pan Station

- Room: Kitchen.
- Gameplay role: Cook station for omelets, pancakes, sauces, and fast hot recipes that are not baked.
- Footprint: 2 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for cooking; left or right can visually imply pan access but should be secondary.
- Placement notes: Heat-source asset. Keep a clear front tile for readability.
- Visual prompt: Compact stovetop pan station with two burners, hanging skillet, small sauce pot, warm blue-orange flame, cozy top-down sprite.
- Upgrade variants:
  - Level 1: Two-burner tabletop range, basic speed.
  - Level 2: Four-burner range with pan rack, improved parallel cooking.
  - Level 3: Griddle and burner combo, fastest hot recipe throughput.

### 6. Drink Station

- Room: Sales Room or Kitchen.
- Gameplay role: Produces or dispenses drinks for customer orders; can be customer-facing later if self-serve is added.
- Footprint: 1 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for worker use; optional customer side if placed in sales room.
- Placement notes: In the starter version, treat as worker-operated. Later upgrades can become semi-self-serve.
- Visual prompt: Small drink dispenser station with kettle, syrup bottles, cups, tiny drip tray, colorful but clean bakery cafe style.
- Upgrade variants:
  - Level 1: Manual tea and lemonade setup, low capacity.
  - Level 2: Dual dispenser with cup stack, faster service.
  - Level 3: Compact cafe beverage machine, more drink types and higher patience bonus.

### 7. Cashier Stand

- Room: Sales Room.
- Gameplay role: Accepts orders, handles payment, anchors queue behavior, and gives cashiers a work position.
- Footprint: 2 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for customers; back for workers. Both sides should remain reachable in ideal layouts.
- Placement notes: Must read as the main service point. Strong front/back silhouette is important.
- Visual prompt: Cozy wooden cashier counter with small register, bell, pastry signboard shape without readable text, customer side lower, worker side with shelf.
- Upgrade variants:
  - Level 1: Simple register stand, manual checkout.
  - Level 2: Larger counter with receipt tray, faster order/payment handling.
  - Level 3: Polished service counter with token display, supports cashier worker efficiency and fewer missed payments.

### 8. Small Shelf

- Room: Sales Room or Kitchen.
- Gameplay role: Small finished-stock display or compact supply shelf depending on room.
- Footprint: 1 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for stocking and taking items.
- Placement notes: Should be readable as storage, not decor. Sales-room version should face customers.
- Visual prompt: One-tile wooden display shelf with two tiers, small trays, jars, folded cloth, cozy bakery storage asset.
- Upgrade variants:
  - Level 1: Two-tier shelf, low capacity.
  - Level 2: Three-tier shelf with baskets, higher capacity.
  - Level 3: Labeled modular shelf, better visibility and slower spoilage for displayed goods.

### 9. Large Shelf

- Room: Sales Room or Warehouse.
- Gameplay role: Larger finished-stock display in sales room or bulk dry storage in warehouse.
- Footprint: 2 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for stocking and taking items.
- Placement notes: Keep the front approachable. When used in sales, customers should read it as browsable.
- Visual prompt: Wide bakery shelving unit with tiered trays, jars, baskets, warm wood, clear empty slots for stock icons.
- Upgrade variants:
  - Level 1: Wide wooden shelf, medium capacity.
  - Level 2: Reinforced shelf with bins and display trays, improved capacity.
  - Level 3: Premium lit display/storage shelf, high capacity and sales-room appeal.

### 10. Two-Seat Table

- Room: Sales Room.
- Gameplay role: Compact seating for one or two customers; improves patience and supports dine-in orders.
- Footprint: 2 x 2.
- Rotation: Full 90-degree rotation allowed, though square footprint does not change.
- Interaction sides: Any open side for customer entry; at least one side should remain reachable.
- Placement notes: Include chairs inside the footprint so the seating shape is clear and pathing stays predictable.
- Visual prompt: Small round cafe table with two chairs, tiny vase, pastry crumb detail, warm wood, top-down cozy bakery seating.
- Upgrade variants:
  - Level 1: Plain two-seat table, small patience bonus.
  - Level 2: Cushioned chairs and cleaner tabletop, better patience bonus.
  - Level 3: Charming set with tablecloth and candle, strongest small-table comfort bonus.

### 11. Four-Seat Table

- Room: Sales Room.
- Gameplay role: Larger seating for groups; improves patience and lets the sales room support longer customer stays.
- Footprint: 3 x 2.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Any open side for customer entry; long sides should visually imply chair access.
- Placement notes: More efficient for groups but harder to fit in starter sales rooms.
- Visual prompt: Rectangular cafe table with four chairs, napkin holder, small shared dessert plate, cozy top-down restaurant asset.
- Upgrade variants:
  - Level 1: Basic four-seat set, medium patience bonus.
  - Level 2: Cushioned booth-like chairs, higher comfort.
  - Level 3: Family table with centerpiece and matching chairs, best dine-in satisfaction.

### 12. Warehouse Rack

- Room: Warehouse.
- Gameplay role: Bulk dry storage for raw ingredients, packaging, and utility supplies.
- Footprint: 2 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for loading and taking stock.
- Placement notes: Should form clear warehouse aisles; visually taller and more industrial than sales shelves.
- Visual prompt: Sturdy metal warehouse rack with flour sacks, cardboard boxes, labeled crates without readable text, cozy but practical.
- Upgrade variants:
  - Level 1: Basic metal rack, medium bulk capacity.
  - Level 2: Deeper rack with organized bins, higher capacity.
  - Level 3: Reinforced inventory rack with color-coded bins, best warehouse capacity and runner efficiency.

### 13. Fridge

- Room: Kitchen or Warehouse.
- Gameplay role: Cold storage for milk, cream, cheese, and spoilage-sensitive prep.
- Footprint: 1 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for opening.
- Placement notes: Door swing should be implied on the front side; do not require extra footprint for the swing.
- Visual prompt: Rounded retro bakery fridge, pale mint or cream enamel, handle, tiny magnets, cool blue interior glow from top-down view.
- Upgrade variants:
  - Level 1: Small retro fridge, low cold capacity.
  - Level 2: Taller glass-door fridge, better capacity and visibility.
  - Level 3: Double cold cabinet, slower spoilage and high capacity.

### 14. Ingredient Crate

- Room: Warehouse or Kitchen.
- Gameplay role: Temporary stock container for delivered ingredients or short-distance staging.
- Footprint: 1 x 1.
- Rotation: Rotation visually optional; allowed for consistency.
- Interaction sides: Any side.
- Placement notes: Should be easy to distinguish from permanent storage. Useful as delivery overflow or manual staging.
- Visual prompt: Open wooden ingredient crate with flour bag, eggs, tomatoes, folded paper receipt shape, compact top-down sprite.
- Upgrade variants:
  - Level 1: Plain crate, small temporary capacity.
  - Level 2: Reinforced crate with dividers, better stack handling.
  - Level 3: Wheeled crate, easier runner pickup and larger temporary capacity.

### 15. Tablet Ordering Station

- Room: Warehouse.
- Gameplay role: Interface object for ordering raw ingredients, packaging, and utility supplies.
- Footprint: 1 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for player or manager use.
- Placement notes: Should visually anchor the ordering workflow near delivery intake.
- Visual prompt: Tiny wall-side ordering podium with tablet screen glow, clipboard, stylus, delivery notes, cozy warehouse corner asset.
- Upgrade variants:
  - Level 1: Basic tablet on stand, manual ordering.
  - Level 2: Tablet with order slots and forecast notes, faster ordering flow.
  - Level 3: Smart ordering kiosk with small printer, better forecasts and bulk-order convenience.

### 16. Packing Station

- Room: Kitchen or Sales Room.
- Gameplay role: Converts finished goods into packed orders, delivery bags, or bulk order bundles.
- Footprint: 2 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for packing; back can be used for pass-through visuals if placed between rooms later.
- Placement notes: Should sit near shelves, cashier, or kitchen pass for efficient routes.
- Visual prompt: Packing counter with paper boxes, twine, sticker roll without readable text, stack of folded bags, cozy bakery fulfillment station.
- Upgrade variants:
  - Level 1: Manual packing table, low throughput.
  - Level 2: Organized box dispenser and bag rail, faster packing.
  - Level 3: Premium fulfillment bench with scale and label printer, supports bulk and delivery order efficiency.

### 17. Delivery Box

- Room: Warehouse or Sales Room.
- Gameplay role: Temporary object for incoming deliveries or outgoing delivery orders.
- Footprint: 1 x 1.
- Rotation: Rotation visually optional; allowed for consistency.
- Interaction sides: Any side.
- Placement notes: Should communicate transient state. It can be used as a spawned placement marker or a player-placeable staging object in future design.
- Visual prompt: Sealed cardboard delivery box with bakery tape, small handle holes, simple icon-like sticker shapes, top-down cozy game asset.
- Upgrade variants:
  - Level 1: Small box, low order capacity.
  - Level 2: Stacked box pair, medium capacity.
  - Level 3: Insulated delivery tote, keeps packed goods fresh longer.

### 18. Sink

- Room: Kitchen.
- Gameplay role: Utility station for cleaning, hygiene, and possible recipe prep that needs water.
- Footprint: 1 x 1.
- Rotation: Full 90-degree rotation allowed.
- Interaction sides: Front for worker use.
- Placement notes: Wall placement is visually preferred, but freestanding utility placement can be allowed if needed.
- Visual prompt: Compact ceramic sink with brass faucet, soap bottle, dish towel, few plates, clean top-down bakery kitchen sprite.
- Upgrade variants:
  - Level 1: Small hand sink, basic cleaning.
  - Level 2: Deeper utility sink with drying rack, faster cleanup.
  - Level 3: Double sink with sprayer, best cleaner efficiency and hygiene bonus.

### 19. Trash Bin

- Room: Kitchen, Sales Room, or Warehouse.
- Gameplay role: Utility object for clearing waste, reducing mess penalties, and supporting cleaner routes.
- Footprint: 1 x 1.
- Rotation: Rotation visually optional; allowed for consistency.
- Interaction sides: Any side, with front visually preferred.
- Placement notes: Should be visually compact and avoid looking like an ingredient crate.
- Visual prompt: Small lidded trash bin with foot pedal, paper scrap, muted color, clean readable top-down utility asset.
- Upgrade variants:
  - Level 1: Basic bin, low mess capacity.
  - Level 2: Larger lidded bin, better mess handling.
  - Level 3: Sorting station with two small compartments, best cleanliness and reputation support.

### 20. Decorative Plant

- Room: Sales Room, Kitchen, or Warehouse.
- Gameplay role: Low-impact decor that improves room charm and customer patience when visible in sales areas.
- Footprint: 1 x 1.
- Rotation: Rotation visually optional; allowed for consistency.
- Interaction sides: None required after placement.
- Placement notes: Non-work object. It should not be required for routes and should never hide interaction sides of nearby machines.
- Visual prompt: Cozy potted plant with rounded leaves, ceramic pot, tiny bow or tag shape without readable text, charming top-down cafe decor.
- Upgrade variants:
  - Level 1: Small potted herb, tiny charm bonus.
  - Level 2: Fuller leafy plant, better charm bonus.
  - Level 3: Decorative planter with flowers and stand, strongest small decor appeal.

## Readability Checklist

- Every machine has a clear front side.
- Customer-facing assets have a visibly different customer side and worker side.
- Storage assets show capacity through shelves, bins, crates, or empty slots.
- Heat sources use warm glow and metal silhouettes.
- Cold storage uses cool glow, glass, or enamel.
- Temporary logistics objects look movable and less permanent than shelves or racks.
- Upgrade variants add visible capability without changing the core silhouette.
- One-tile assets remain identifiable at phone size.

## Suggested First Art Pass

Prioritize these assets first because they define the starter loop:

1. Starter oven.
2. Prep counter.
3. Mixing machine.
4. Cashier stand.
5. Small shelf.
6. Warehouse rack.
7. Ingredient crate.
8. Tablet ordering station.

The second pass should add comfort and operational depth: two-seat table, four-seat table, fridge, pan station, drink station, packing station, sink, trash bin, delivery box, large shelf, pro oven, and decorative plant.
