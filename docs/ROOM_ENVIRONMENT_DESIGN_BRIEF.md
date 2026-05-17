# Room Environment Design Brief

Whiskwick's rooms should read as a cozy top-down bakery shop built from clean grid tiles, warm materials, and chunky realistic 3D pixel/voxel-like props. The style target is miniature diorama realism: believable materials and lighting, but simplified forms with crisp silhouettes, readable tile edges, and no visual clutter that hides paths or interactions.

This brief defines the visual direction only. It does not define code, scenes, data structures, economy, or placement rules.

## Camera And Readability

- Use a fixed top-down camera with a slight three-quarter tilt, enough to show front faces of counters, doors, wall trim, and appliances.
- Keep object height modest. Tall shelves, fridges, and walls should be readable but must not cover walking lanes or key interaction sides.
- Favor orthographic composition. The grid should remain aligned, stable, and easy to scan while the art keeps a small 3D sense of depth.
- Important gameplay surfaces need strong silhouettes: counters, ovens, registers, delivery intake, doors, and storage racks.
- Avoid heavy floor patterns under working routes. Detail belongs near edges, corners, and prop clusters rather than in the center of paths.
- Leave a visible one-tile walkway impression between major objects through contrast, floor seams, shadows, and uncluttered tile centers.

## Shared Grid Floor Language

The floor should make the room grid visible without feeling like a debug overlay.

- Tile scale: every floor tile should have a subtle border, bevel, grout line, plank seam, or wear variation.
- Path tiles: slightly cleaner, lighter, and lower contrast so moving characters remain readable.
- Occupied tiles: props may cast soft contact shadows onto them, grounding the footprint.
- Service lanes: use small directional cues such as cleaner tile wear, runner tracks, or repeated mat edges, never bright arrows as permanent decor.
- Expansion edges: unfinished borders can show bare subfloor, taped chalk lines, stacked spare tiles, or temporary trim gaps.

## Sales Room

The sales room is the warm public face of the shop. It should feel inviting, lightly polished, and easy for customers to understand at a glance.

Visual mood:

- Warm bakery light, cream-painted walls, honey wood, glass display cases, brass or dark metal accents.
- More decorative than the kitchen, but still arranged for readable queue and service flow.
- Finished goods should add small color sparks: frosting, fruit, labels, cake stands, pastry trays.

Primary visual anchors:

- Front door and welcome mat.
- Customer queue path.
- Display case line.
- Service counter and register.
- Small seating or waiting corner when expanded.

Materials:

- Floor: warm checker tile, pale wood plank, or matte terrazzo with muted cream, rose, butter yellow, and soft gray notes.
- Walls: painted plaster with tile wainscot or wood trim.
- Counters: warm wood bases, pale stone or cream laminate tops, glass fronts for display cases.

Readability notes:

- The customer side of display cases must be visually obvious through glass fronts and product trays.
- The worker side should be simpler: wood back panel, small handles, register cable, paper bags, or tongs.
- Queue path should remain one of the cleanest shapes in the room.

## Kitchen

The kitchen is busy, functional, and satisfying. It should feel like a compact production space where the workflow from raw stock to prep to cooking to pass counter is visible.

Visual mood:

- Brighter task lighting, cooler clean surfaces, controlled warmth from ovens and baked goods.
- Less decorative, more utilitarian: stainless steel, pale tile, wood cutting boards, labeled bins, flour dust.
- Props should imply motion and prep without making interaction sides confusing.

Primary visual anchors:

- Prep counter run.
- Oven and stovetop zone.
- Short-term ingredient storage.
- Pass counter toward the sales room.
- Washing or cleanup corner if needed later.

Materials:

- Floor: non-slip square kitchen tile in light gray, soft blue-gray, or off-white with slightly darker grout.
- Walls: white subway tile, pale painted plaster above, occasional heat-safe backsplash.
- Counters: stainless steel tops, butcher-block inserts, white ceramic bowls, rolling pins, trays.

Readability notes:

- Heat sources should have darker bases, warm glows, or red/orange indicator lights, but the walkable floor around them should stay clear.
- Prep counters should display ingredients at low height so players can still see the tile footprint.
- The pass counter should visually bridge kitchen and sales room with trays, order tickets, and a clear open side.

## Warehouse

The warehouse is the logistical back room. It should feel practical, slightly rougher, and built for deliveries, storage, and future automation.

Visual mood:

- Cooler back-of-house light, muted materials, stacked boxes, metal racks, bulk sacks, crate labels.
- Less cozy than the sales room, but not grim. It should still belong to the same bakery world.
- Clear intake space is more important than prop density.

Primary visual anchors:

- Delivery intake tile or mat.
- Bulk shelving.
- Cold storage or freezer unit.
- Kitchen access door.
- Tablet-order holding area.

Materials:

- Floor: sealed concrete, painted concrete, or hard-wearing gray tile with scuffs and pallet marks.
- Walls: painted brick, plain plaster, or utility panels with darker base trim.
- Storage: powder-coated metal racks, wood crates, canvas sacks, plastic ingredient tubs.

Readability notes:

- Intake area should be visually framed by tape lines, a rubber mat, or a low threshold, but remain empty enough for deliveries to appear readable.
- Shelving should be aligned to walls or aisles, with fronts clearly facing accessible floor tiles.
- Cold storage should use pale blue highlights and strong rectangular silhouettes.

## Expansion States

Room expansion should look like the shop is physically growing, not simply revealing more blank floor.

Starter state:

- Compact rooms, simple wall trim, limited props, clear routes.
- Sales room has minimal seating or none.
- Kitchen has one main prep line and a small cooking area.
- Warehouse has one intake area and basic shelving.

First expansion:

- New floor tiles are slightly cleaner or subtly mismatched.
- Trim seams, fresh paint patches, boxed fixtures, and temporary dust marks show recent construction.
- Sales room gains space for seating, larger display cases, or cleaner queue shaping.
- Kitchen gains parallel work surfaces.
- Warehouse gains longer rack runs and better delivery staging.

Later expansion:

- The room should feel professionally upgraded: coordinated flooring, better lighting, finished trim, stronger signage, and purpose-built zones.
- Earlier mismatched details can remain at corners to preserve charm.
- Bigger rooms need more visual landmarks so the player can orient quickly.

Expansion boundary language:

- Use half-height construction rails, chalk layout marks, stacked tile boxes, covered furniture, or new baseboard strips at edges.
- Do not use visually loud barricades that look like hard gameplay blockers unless the area is actually unavailable.

## Walls

Walls should frame rooms without hiding the grid.

- Use low or cutaway walls for the camera-facing sides.
- Back and side walls can show more detail: trim, shelves, menus, vents, framed recipes, electrical boxes, hooks.
- Wall corners should have chunky bevels or clear vertical posts so rooms read as constructed spaces.
- Keep wall color distinct by room while sharing a common bakery palette.
- Avoid tall wall decor directly behind frequent interaction points if it competes with props.

Room wall direction:

- Sales room: cream plaster, pastel tile wainscot, menu boards, small framed pastry prints.
- Kitchen: white tile, stainless backsplash, vents, hanging utensils, washable surfaces.
- Warehouse: painted brick or utility plaster, warning labels, shelf anchors, clipboards.

## Doors And Thresholds

Doors should communicate room purpose and traffic type.

- Front door: wider, warmer, glass panel, visible handle, welcome mat, possible hanging sign.
- Kitchen door: swinging half-door, service pass, or open arch with tile threshold.
- Warehouse door: sturdy utility door, darker trim, scuffed lower panel, delivery label holder.
- Expansion doorway: unfinished trim or newly painted frame, depending on upgrade state.

Door readability:

- Every door should have a visible threshold tile.
- Avoid placing tall props near door frames where they obscure the entry route.
- Customer-facing doors should be visually softer and brighter than worker-only utility doors.

## Lighting

Lighting should help explain room function.

- Sales room: warm ambient light, soft window light, gentle highlights on glass cases and pastries.
- Kitchen: neutral task lighting, brighter countertop highlights, mild warm glow near ovens.
- Warehouse: cooler overhead light, fewer decorative highlights, slightly stronger shadows under shelves.
- Expansion zones: freshly installed lights or temporary work lights can mark new areas.

Use shadows carefully:

- Contact shadows ground props.
- Large shadows should not cross main paths strongly enough to look blocked.
- Doorways and service passes can use soft pools of light to draw the eye.

## Path Readability

Readable movement paths are part of the art direction.

- Keep central walkways clean, with small scuffs and crumbs pushed to edges.
- Use object orientation to suggest allowed approach sides.
- Contrast busy prop clusters with calm floor lanes.
- Use rugs, mats, grout direction, and floor wear to guide the eye toward doors and counters.
- Do not scatter small props on route tiles unless they are clearly decorative overlays with no collision meaning.

## Tile Palette

The palette should vary by room but share enough warmth to feel like one shop.

Core neutrals:

- Frosting cream: `#F3E8D2`
- Warm flour: `#D8C5A5`
- Pale dough: `#E7D7B7`
- Soft gray grout: `#B9B7AE`
- Deep cocoa trim: `#4F3A2D`

Sales room accents:

- Strawberry glaze: `#D97A82`
- Butter yellow: `#E8C86A`
- Mint label: `#93BFA8`
- Brass handle: `#B48745`

Kitchen accents:

- Clean tile white: `#EDEBE2`
- Steel blue-gray: `#8F9DA3`
- Oven warmth: `#D9783F`
- Herb green: `#6E8F67`

Warehouse accents:

- Concrete gray: `#8B8980`
- Cardboard kraft: `#A8794B`
- Utility blue: `#5F7F9B`
- Rack charcoal: `#3D4242`

Grid and outline guidance:

- Tile seams should sit close to `#9B9488` for warm rooms and `#737A7A` for warehouse/concrete rooms.
- Use darker outlines only at object bases and critical silhouettes, not around every small surface.
- Keep saturation modest. Pastries and labels can carry the brightest colors.

## Realistic 3D Pixel/Voxel-Like Asset Prompts

Use these prompts for concept generation or asset style alignment. They describe visual intent only.

### Floors

Sales floor prompt:

```text
realistic 3D pixel art voxel-like bakery sales room floor tiles, top-down orthographic view with slight three-quarter angle, warm cream and pale rose checker tiles, subtle grout lines, gentle bevels, small flour dust near edges, clean central walking lane, cozy miniature diorama lighting, crisp tile grid readability, no characters, no text
```

Kitchen floor prompt:

```text
realistic 3D pixel art voxel-like commercial bakery kitchen floor, top-down orthographic view, matte off-white square non-slip tiles with blue-gray grout, subtle scuffs around prep stations, clean readable grid seams, soft contact shadows, bright neutral task lighting, miniature diorama style, no characters, no text
```

Warehouse floor prompt:

```text
realistic 3D pixel art voxel-like bakery warehouse floor, top-down orthographic view, sealed concrete tiles with faint pallet marks, taped delivery intake rectangle, muted gray palette, readable square grid, light scuffs and dust along edges, practical back-room lighting, no characters, no text
```

Expansion floor prompt:

```text
realistic 3D pixel art voxel-like bakery room expansion floor, top-down orthographic view, newly installed tiles beside older tiles, slight color mismatch, chalk layout marks, stacked spare tiles at edge, clean walkable grid, cozy construction-in-progress detail, no characters, no text
```

### Wall Sets

Sales wall set prompt:

```text
realistic 3D pixel art voxel-like cozy bakery sales room wall set, low cutaway walls for top-down game, cream plaster, pastel tile wainscot, honey wood trim, small menu board shapes without readable text, framed pastry decor, warm soft lighting, modular corner and straight wall pieces, crisp silhouettes, no characters
```

Kitchen wall set prompt:

```text
realistic 3D pixel art voxel-like commercial bakery kitchen wall set, low cutaway top-down game walls, white subway tile backsplash, pale washable plaster above, stainless vent hood pieces, utensil hooks, clean modular corners and straight segments, bright task lighting, crisp readable silhouettes, no characters, no text
```

Warehouse wall set prompt:

```text
realistic 3D pixel art voxel-like bakery warehouse wall set, low cutaway top-down game walls, painted brick and utility plaster, darker base trim, shelf anchor plates, small clipboard shapes, muted cool lighting, modular straight wall and corner pieces, sturdy practical look, no characters, no readable text
```

### Doors

Front door prompt:

```text
realistic 3D pixel art voxel-like bakery front door asset, top-down orthographic three-quarter view, warm wood frame, glass panel, brass handle, welcome mat, cozy shop entrance, clear threshold tile, chunky miniature diorama style, crisp silhouette, no characters, no readable text
```

Kitchen service door prompt:

```text
realistic 3D pixel art voxel-like bakery kitchen service door, top-down orthographic three-quarter view, swinging half-door with pale paint, metal kick plate, tile threshold, visible open pass route, clean practical style, soft task lighting, crisp readable silhouette, no characters, no text
```

Warehouse utility door prompt:

```text
realistic 3D pixel art voxel-like bakery warehouse utility door, top-down orthographic three-quarter view, sturdy painted metal door, scuffed lower panel, darker trim, rubber threshold mat, delivery label holder shape without readable text, cool back-room lighting, crisp silhouette, no characters
```

### Countertops And Stations

Sales display counter prompt:

```text
realistic 3D pixel art voxel-like bakery glass display counter, top-down orthographic three-quarter view, warm wood base, pale stone top, glass front with trays of colorful pastries, customer side clearly visible, worker side with tongs and paper bags, cozy lighting, crisp footprint, no characters, no readable text
```

Kitchen prep counter prompt:

```text
realistic 3D pixel art voxel-like bakery prep counter, top-down orthographic three-quarter view, stainless steel top with butcher-block insert, mixing bowl, flour dust, rolling pin, ingredient bins, low props that preserve grid readability, bright task lighting, crisp rectangular footprint, no characters
```

Pass counter prompt:

```text
realistic 3D pixel art voxel-like bakery kitchen pass counter, top-down orthographic three-quarter view, open counter between kitchen and sales room, trays, small order ticket shapes without readable text, warm food highlights, clear approach sides, crisp silhouette, miniature diorama style, no characters
```

Warehouse packing counter prompt:

```text
realistic 3D pixel art voxel-like bakery warehouse packing counter, top-down orthographic three-quarter view, sturdy workbench, cardboard boxes, tape roll, ingredient labels without readable text, muted concrete and metal materials, clear front interaction side, crisp footprint, no characters
```

### Room Props

Sales props prompt:

```text
realistic 3D pixel art voxel-like cozy bakery sales room prop set, top-down orthographic three-quarter view, small cafe table, two chairs, pastry stand, potted herb, napkin holder, wall menu shapes without readable text, warm cream and strawberry accents, crisp silhouettes, grid-friendly footprints, no characters
```

Kitchen props prompt:

```text
realistic 3D pixel art voxel-like bakery kitchen prop set, top-down orthographic three-quarter view, oven, stovetop, cooling rack, mixing bowls, trays, flour sacks, utensil rail, stainless and ceramic materials, warm oven glow, clear interaction sides, crisp silhouettes, no characters
```

Warehouse props prompt:

```text
realistic 3D pixel art voxel-like bakery warehouse prop set, top-down orthographic three-quarter view, metal shelving, stacked cardboard boxes, flour sacks, plastic ingredient tubs, small freezer unit, pallet jack, muted gray and kraft colors, readable grid footprints, no characters, no readable text
```

Expansion props prompt:

```text
realistic 3D pixel art voxel-like bakery expansion prop set, top-down orthographic three-quarter view, stacked spare tiles, paint bucket, covered counter, rolled floor mat, trim boards, chalk marks, temporary work light, cozy construction detail, readable silhouettes, no characters, no text
```

## Asset Consistency Checklist

- Every asset should read clearly from the top-down camera before close inspection.
- Props should be chunky enough to survive small screen sizes.
- Materials should differ by room: warm customer-facing, clean production, rugged storage.
- Floor tiles should keep paths legible even when props are dense.
- Wall and door sets should be modular and share trim proportions.
- The brightest colors should come from food, labels, lights, and important interaction anchors.
- Expansion art should show progress while preserving the same bakery identity.
