# Top-Down Room Concept

Whiskwick uses a top-down 2D bakery layout built from rooms on a shared grid. The player improves the shop by placing useful objects, rotating them, keeping paths readable, and expanding rooms when the current floor plan becomes too tight.

## Core Rooms

### Sales Room

The sales room is the customer-facing area. Customers enter through the front door, queue, browse visible finished goods, pay at counters, and may sit if seating exists.

Design priorities:

- Keep at least one clear tile of walking space through the queue and service route.
- Put display cases and service counters where customers can approach one side and workers can approach the other.
- Use decor and seating to improve patience, but avoid blocking the kitchen pass.
- Finished food belongs here only when it is ready to sell or hand off.

### Kitchen

The kitchen is the production room. Prep counters, ovens, stovetops, cold storage, and pass counters form the core route from ingredients to finished goods.

Design priorities:

- Raw stock comes in from the warehouse, then moves to prep and cooking stations.
- Workers need reachable interaction sides on machines.
- Heat sources should have at least one tile of clearance so layouts read clearly.
- The kitchen pass should shorten the route between cooked food and sales service.

### Warehouse

The warehouse is the intake and bulk storage room. Tablet orders arrive here first, then the player or runners move items into storage or onward to the kitchen.

Design priorities:

- Ingredient orders never appear directly at cooking stations.
- Delivery intake needs clear floor space so new orders can land without blocking the room.
- Bulk shelves and cold storage should sit near the kitchen door once runners exist.
- Overflow deliveries queue until there is storage space.

## Grid Placement

Rooms use a tile grid, with a current design target of 32 pixels per tile. Placeables and machines declare a `footprint.width` and `footprint.height` in grid tiles.

Placement rules:

- Objects cannot overlap.
- Objects marked `blocks_movement` reserve their occupied tiles.
- Rooms should preserve a walkable route between entry points.
- Objects may restrict valid rooms through `allowed_rooms`.
- Tags such as `heat_source`, `customer_facing`, `storage`, and `worker_station` drive room permissions.

## Rotation

Most placeables and machines can rotate in 90-degree increments. Rotation swaps the effective width and height of non-square footprints and changes which side is considered the front.

Rotation rules:

- A rotated object must still fit inside room bounds.
- Interaction sides should remain reachable after rotation.
- Wall-attached objects can rotate only when a wall or approved anchor exists.
- Customer-facing objects should expose a customer side and a worker side when relevant.

## Size Limits And Expansion

Each room definition includes:

- `starter_size`: the starting footprint.
- `min_size`: the smallest valid room after any future remodeling.
- `max_size`: the room's practical design cap.
- `expansion.base_cost` and `expansion.cost_per_tile`: economy tuning for growth.

Expansion should feel like solving a workflow problem, not only buying empty floor. The first useful expansions are expected to be:

- A wider sales room for queue, seating, and display cases.
- A deeper kitchen for parallel prep and cooking stations.
- A warehouse extension for tablet-order overflow and cold storage.

## Tablet Ingredient Orders

The tablet is the default purchasing interface for raw ingredients, packaging, and utility supplies. Items marked `orderable_from_tablet` in item category data can be bought through this channel.

Order flow:

1. Player buys items on the tablet.
2. Money is spent immediately or reserved at order time.
3. A delivery timer starts.
4. The delivery appears in the warehouse intake area.
5. If intake or storage is full, the delivery waits in an overflow queue.
6. Player or runner moves stock from warehouse to kitchen or sales room storage.

This keeps the warehouse meaningful and creates a clean logistics loop: order, receive, store, move, produce, sell.
