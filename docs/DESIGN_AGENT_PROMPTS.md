# Whiskwick Design Agent Prompt Pack

This prompt pack is for designer and image-generation agents producing realistic 3D pixel/voxel-like assets for Whiskwick, a cozy top-down food-shop tycoon. Use these prompts to create consistent source art that can be cleaned into sprites, icons, tiles, UI elements, and promotional asset references.

## Style Bible

Whiskwick should look like a miniature handmade bakery diorama rendered with chunky voxel/pixel forms, soft 3D depth, and cozy food-shop warmth. Assets must feel tactile and readable at game scale: rounded-square silhouettes, simplified geometry, bevelled corners, soft clay-like materials, and crisp color separation.

Core art direction:

- Realistic 3D pixel/voxel-like forms, not flat pixel art.
- Top-down or three-quarter top-down camera, suitable for a 2D grid game.
- Orthographic camera unless the prompt explicitly asks for icon perspective.
- Soft global illumination, warm window light, gentle ambient occlusion, no harsh cinematic shadows.
- Chunky low-poly voxel proportions with small bevels, clean edges, and readable silhouettes.
- Cozy bakery mood: flour dust, warm pastries, cream, wood, ceramic, enamel, brushed metal, linen, glass.
- Family-friendly, calm, charming, production-ready, not noisy or hyper-detailed.

Color palette:

- Base warm neutrals: oat, cream, vanilla, butter, pale flour, warm gray.
- Food accents: strawberry red, cherry red, tomato red, egg yolk yellow, milk white, cocoa brown, blueberry blue.
- Shop accents: sage green, faded teal, soft coral, gentle sky blue, muted rose.
- Utility accents: brushed steel, cool gray, deep charcoal outlines, dark coffee trim.
- Avoid dominant purple, neon colors, over-saturated candy palettes, and muddy brown-only scenes.

Camera and scale:

- Default camera: orthographic three-quarter top-down, looking down at roughly 45 degrees.
- For room tiles and floor/wall materials: straight top-down orthographic.
- For UI icons: centered orthographic or slight three-quarter icon view, square canvas.
- Assets should imply a 32 px tile grid. Placeables should read as 1x1, 2x1, 2x2, or 3x2 grid footprints.
- Leave breathing room around the asset so it can be cropped or sprite-packed.

Lighting:

- Warm daylight from upper left.
- Soft fill from upper right.
- Subtle contact shadow directly under the object.
- Transparent background for individual assets unless the prompt asks for a tile or material swatch.
- No dramatic black shadows, rim-light spectacle, bloom, lens flare, or dark vignette.

Output requirements:

- Produce high-resolution PNG source art, ideally 1024x1024 for single assets and 2048x2048 for sprite sheets.
- Use transparent background for characters, machines, furniture, crates, icons, and standalone props.
- For tileable materials, output square seamless textures with no object shadow and no transparent background unless requested.
- Keep silhouettes centered, uncropped, and separated from any shadow.
- Include both clean asset render and optional shadow layer if the tool supports layered export.
- Use consistent scale across related assets in the same batch.

Sprite-sheet notes:

- When a prompt asks for a sprite sheet, use a strict grid layout with equal cells.
- Keep each pose or variant centered in its own cell.
- Use transparent background, no cell borders in final output unless requested for review.
- Maintain identical character height, foot position, and camera angle across cells.
- Suggested sheets: 4 columns x 2 rows for simple walk/idle sets, 5 columns x 2 rows for workers with task poses, 6 columns x 4 rows for UI icons.

Consistency rules:

- Characters should share the same body proportions: chunky head, compact torso, simple hands, short legs, large readable hair/hat shapes.
- Workers use aprons, role props, and stronger color coding; customers use softer everyday outfits.
- Machines use warm off-white enamel, muted metal, and small colored knobs or labels.
- Sales-room props should be cleaner and more decorative; kitchen props should show use; warehouse props should be sturdier and more utilitarian.
- Every asset should have one clear front/interaction side.
- Avoid tiny details that disappear at 32 px tile scale.
- If generating multiple assets, keep the same camera height, shadow softness, material finish, and bevel size.

Global negative prompt:

No photoreal humans, no anime, no flat 2D cartoon, no glossy mobile-game plastic, no high-poly realism, no horror, no grime, no cluttered backgrounds, no text labels, no brand logos, no watermark, no signature, no heavy outlines, no excessive bloom, no fisheye lens, no dramatic perspective, no extreme close-up, no cropped asset, no transparent pixels inside solid objects, no messy jagged edges, no random extra limbs, no unreadable tiny details, no unrelated kitchen appliances, no weapons, no dark cyberpunk palette.

## Production Prompts

### 1. Player Baker Character

Create a realistic 3D pixel/voxel-like player baker character for a cozy top-down bakery tycoon. Chunky miniature proportions, warm face, simple dot eyes, tidy hair under a small baker cap, cream apron over sage shirt, dark coffee shoes, small flour smudge on apron. Orthographic three-quarter top-down camera at 45 degrees, centered full-body standing pose, transparent background, soft contact shadow. Readable at 32 px tile scale, friendly but not childish. Use warm daylight, soft ambient occlusion, bevelled voxel forms, clean silhouette. Negative prompt: no anime, no realistic skin pores, no text, no logo, no oversized head beyond style bible, no cropped feet.

### 2. Baker Worker Sprite Sheet

Create a 5 columns x 2 rows transparent-background sprite sheet of a cozy voxel baker worker. Same character in every cell: white baker hat, butter-yellow neckerchief, cream apron, rolled sleeves. Poses: idle, carrying mixing bowl, kneading dough, placing tray into oven, holding finished cupcakes, walking north, walking east, walking south, walking west, tired low-stamina pose. Orthographic three-quarter top-down camera, identical scale and foot position per cell, no borders, no labels. Soft warm lighting and consistent shadow per pose. Negative prompt: no inconsistent outfit, no different character per cell, no cell text, no dramatic action blur.

### 3. Cashier Worker Sprite Sheet

Create a 5 columns x 2 rows transparent-background sprite sheet of a cozy voxel cashier worker for Whiskwick. Compact figure with teal vest, cream shirt, small apron pocket, friendly service posture. Poses: idle at register, taking payment, handing paper bag, pointing to display case, happy sale reaction, walking north, walking east, walking south, walking west, tired stamina pose. Orthographic three-quarter top-down camera, all poses centered and same scale. Soft bakery daylight, gentle contact shadows, readable hands and props. Negative prompt: no modern barcode scanner emphasis, no text on money, no floating props, no mismatched colors.

### 4. Runner Worker Sprite Sheet

Create a 5 columns x 2 rows transparent-background sprite sheet of a cozy voxel runner worker who moves stock between warehouse and kitchen. Outfit: coral bandana, cream apron, sturdy brown shoes, small delivery satchel. Poses: idle, carrying flour sack, carrying ingredient crate, pushing small hand cart, placing stock on counter, walking north, walking east, walking south, walking west, tired pose. Orthographic three-quarter top-down camera, consistent character scale and shadow. Props must be chunky and readable. Negative prompt: no sports uniform, no huge cart blocking character, no unreadable crate contents, no harsh shadows.

### 5. Cleaner Worker Sprite Sheet

Create a 5 columns x 2 rows transparent-background sprite sheet of a cozy voxel cleaner worker for a bakery shop. Outfit: pale blue shirt, cream apron, simple gloves, small towel at waist. Poses: idle, sweeping crumbs, wiping table, holding mop bucket, clearing tray, walking north, walking east, walking south, walking west, tired stamina pose. Orthographic three-quarter top-down camera, warm light, soft contact shadow, clean readable silhouette. Negative prompt: no dirty grim scene, no janitor cart, no caution text, no complex mop strings, no mismatched pose scale.

### 6. Customer Family Set

Create a transparent-background set of six cozy voxel bakery customers in one image, each standing separately with space between them: student with backpack, office worker with coffee, elderly regular with scarf, parent holding shopping bag, child with cupcake, casual tourist with camera strap. Use the same orthographic three-quarter top-down camera and consistent height range. Clothing uses muted rose, sky blue, oat, sage, and cocoa accents. Friendly neutral poses, no text or logos. Soft contact shadows under each character. Negative prompt: no celebrity likeness, no realistic faces, no crowd overlap, no exaggerated cartoon expressions.

### 7. Customer Queue Sprite Sheet

Create a 4 columns x 2 rows transparent-background sprite sheet of one cozy voxel customer in queue behavior poses. Same customer in every cell wearing a muted green jacket and cream pants. Poses: idle waiting, looking at display case, holding menu card with no readable text, impatient foot tap, happy purchase, leaving with pastry bag, sitting at table, disappointed leaving. Orthographic three-quarter top-down camera, equal cell sizes, consistent scale. Negative prompt: no text on card, no angry aggression, no phone UI details, no cropped props.

### 8. Small Brick Oven

Create a standalone cozy voxel small brick bakery oven for a 2x1 grid footprint. Off-white plaster body, rounded brick arch opening, warm orange glow inside, small metal handle, flour-dusted tray lip, one clear front interaction side. Orthographic three-quarter top-down camera, transparent background, centered, soft contact shadow. Must read clearly at small game scale and look usable from the front. Negative prompt: no giant industrial furnace, no flames spilling out, no soot-heavy horror look, no text labels.

### 9. Double Deck Oven

Create a realistic 3D pixel/voxel-like double deck bakery oven for a cozy kitchen, intended 2x2 grid footprint. Warm enamel cream body, brushed steel doors, small teal temperature knobs, two tray windows glowing softly, rounded voxel bevels. Three-quarter top-down orthographic camera, transparent background, clean silhouette, soft contact shadow. Include one clear worker-facing side. Negative prompt: no brand logo, no complicated control panel text, no photoreal reflections, no black industrial palette.

### 10. Prep Counter With Ingredients

Create a 2x1 voxel prep counter for a cozy bakery kitchen. Butcher-block wood top, cream painted base, visible chunky bowls of batter, flour dust, eggs, spoon, folded towel, and cutting board. Orthographic three-quarter top-down camera, transparent background, centered, soft contact shadow. Keep props simplified and readable, no clutter spilling beyond footprint. Negative prompt: no knife emphasis, no raw meat, no text, no overly messy counter, no unrealistic perspective.

### 11. Dough Mixer Machine

Create a standalone chunky voxel dough mixer machine for Whiskwick kitchen, 1x1 grid footprint. Cream enamel stand mixer with stainless bowl, sage green knob, rounded base, subtle dough swirl inside bowl. Orthographic three-quarter top-down camera, transparent background, soft contact shadow. It should look like a placeable production machine with one clear interaction side. Negative prompt: no handheld mixer, no wire mess, no brand logo, no hyper-detailed screws, no plastic toy shine.

### 12. Stovetop And Sauce Station

Create a 2x1 cozy voxel stovetop and sauce station. Enamel stovetop with two burners, small red sauce pot, egg pan, tile backsplash strip attached low behind it, warm metal accents, readable front side. Orthographic three-quarter top-down camera, transparent background, centered, soft contact shadow. Suitable for omelets and sauce prep. Negative prompt: no open raging fire, no restaurant-scale range, no smoke cloud, no text labels, no greasy grime.

### 13. Cashier Stand

Create a 2x1 voxel cashier stand for the sales room. Cream-painted counter with warm wood top, small mint cash register, card reader without text, pastry bag stack, tiny bell, rounded corners, customer-facing front and worker side visible. Orthographic three-quarter top-down camera, transparent background, soft contact shadow. Keep it cozy, compact, and readable at 32 px tile scale. Negative prompt: no brand logos, no readable receipt text, no modern supermarket checkout belt, no cluttered background.

### 14. Glass Display Case

Create a 2x1 cozy voxel glass bakery display case. Warm wood base, glass top with simplified transparent reflection, visible cupcakes, cake slices, and pastries inside, customer-facing front. Orthographic three-quarter top-down camera, transparent background, soft shadow, clean edges. Pastries should be chunky and readable, not tiny specks. Negative prompt: no opaque glass, no excessive glare, no labels, no photoreal pastry texture, no crowded shelves.

### 15. Sales Room Shelf Set

Create a transparent-background set of four separate cozy voxel sales-room shelves: wall pastry shelf, jam jar shelf, packaged cookie shelf, and decor shelf with plant and folded linens. Warm wood, cream brackets, muted accent items, clear front-facing side. Orthographic three-quarter top-down camera, consistent scale, soft contact shadows, space between each shelf for easy cropping. Negative prompt: no readable product labels, no wall background, no overpacked clutter, no mismatched camera angles.

### 16. Customer Table And Chairs

Create a cozy voxel cafe table set for a 2x2 grid footprint. Round warm wood table, two simple chairs, small plate with cupcake, tiny cup, folded napkin, soft sage seat cushions. Orthographic three-quarter top-down camera, transparent background, centered, soft contact shadow. Furniture must leave readable spaces and fit a top-down room layout. Negative prompt: no people, no tablecloth text, no ornate high-detail furniture, no cropped chairs.

### 17. Kitchen Pass Counter

Create a 2x1 voxel kitchen pass counter used to transfer finished food from kitchen to sales room. Half-height cream counter, warm wood top, two plated dishes, small order rail with blank cards, clear worker side and customer/service side. Orthographic three-quarter top-down camera, transparent background, soft contact shadow. Negative prompt: no readable ticket text, no restaurant stainless-steel coldness, no huge lamps, no clutter.

### 18. Warehouse Rack

Create a sturdy voxel warehouse rack for a 2x1 grid footprint. Dark warm metal frame, wood shelves, sacks of flour, egg crates, milk bottles, tomato boxes, sugar bags, all simplified and readable. Orthographic three-quarter top-down camera, transparent background, soft contact shadow. Must feel utilitarian but still cozy and clean. Negative prompt: no dirty basement look, no unreadable labels, no broken shelves, no excessive tiny boxes.

### 19. Cold Storage Cabinet

Create a 1x2 voxel cold storage cabinet for warehouse or kitchen. Rounded cream refrigerator cabinet, teal handle, subtle frost edge, tiny magnetic blank note with no text, clear front interaction side. Orthographic three-quarter top-down camera, transparent background, soft contact shadow. Negative prompt: no brand logo, no glass supermarket fridge, no icy fantasy effect, no text, no open door spilling contents.

### 20. Ingredient Crate Set

Create a transparent-background set of eight separate cozy voxel ingredient crates for Whiskwick: flour sack crate, egg crate, sugar bag crate, milk bottle crate, cheese crate, tomato crate, batter bowl crate, dough tray crate. Use consistent size, 1x1 tile footprint each, orthographic three-quarter top-down camera, soft shadows, space between assets. Materials: wood crates, paper sacks, glass bottles, ceramic bowls, cloth covers. Negative prompt: no readable labels, no photoreal food, no rotten ingredients, no inconsistent scale.

### 21. Delivery Intake Pallet

Create a 2x2 voxel warehouse delivery intake pallet. Wooden pallet with mixed ingredient boxes, tablet-order parcel bundles, blank tags with no readable text, one small hand truck nearby but not attached. Orthographic three-quarter top-down camera, transparent background, soft contact shadow. It should communicate new deliveries arriving in warehouse intake space. Negative prompt: no shipping-company logos, no text labels, no forklift, no messy pile beyond footprint.

### 22. UI Icon Sprite Sheet

Create a 6 columns x 4 rows transparent-background sprite sheet of cozy voxel-style UI icons for Whiskwick. Icons: money coin, stamina heart, time clock, pause orders sign, open shop sign, close shop sign, flour, eggs, sugar, milk, cheese, tomato, batter, dough, sauce, cream, cupcake, cake, pizza slice, omelet, drink, worker, customer patience, storage crate. Square cells, centered icons, consistent 3D pixel/voxel style, soft shadow directly under each icon, no cell borders, no text. Negative prompt: no labels, no different art style per icon, no complex backgrounds, no tiny unreadable details.

### 23. Worker Role Badge Icons

Create a transparent-background square icon set for five worker roles in cozy voxel style: cashier bell and coin, baker hat and tray, runner crate and arrow, cleaner broom and sparkle, manager clipboard and calendar. Center each icon in its own equal cell, no text, no borders, consistent color palette and camera. Icons must be readable at small HUD size. Negative prompt: no letters, no words, no brand marks, no overly thin linework, no realistic paper text.

### 24. Room Tile Set

Create a top-down orthographic seamless room tile set for a cozy food-shop tycoon. Provide 12 square tiles in a 4 columns x 3 rows sheet: sales-room honey wood floor, sales-room checker accent floor, kitchen cream ceramic tile, kitchen flour-dusted tile, warehouse worn plank floor, warehouse concrete tile, doorway threshold, pass-counter floor marker, queue path floor marker without text, service area mat, cold storage floor tile, delivery intake floor tile. No perspective, no object shadows, no text, consistent 32 px tile-readability, clean edges. Negative prompt: no diagonal perspective, no furniture, no labels, no dramatic lighting, no visible seams unless designed.

### 25. Wall And Floor Material Swatches

Create a 4 columns x 4 rows sheet of seamless top-down or front-facing material swatches for Whiskwick interiors. Include cream plaster wall, sage beadboard wall, pale teal tile wall, warm brick oven wall, honey wood floor, checker cream floor, flour-dusted kitchen tile, warehouse plank, soft gray concrete, cork notice board blank, warm wood counter top, butcher block, brushed steel, frosted glass, linen fabric, cardboard parcel. No object shadows, no labels, no perspective distortion, tileable when appropriate. Negative prompt: no text, no logos, no grunge horror, no high-frequency noise, no dark palette.

### 26. Complete Starter Room Asset Board

Create a production reference board of cohesive cozy voxel assets for Whiskwick starter shop, transparent or light neutral background for review only. Include one player baker, cashier stand, glass display case, small brick oven, prep counter, dough mixer, warehouse rack, ingredient crate, cafe table, and three floor tile samples. Use identical camera angle, lighting, palette, bevels, and scale logic. Arrange items with clear spacing, no labels, no overlapping. This is for consistency review, not final sprite export. Negative prompt: no text annotations, no scene background, no mismatched asset styles, no inconsistent shadows, no unrelated props.

## Batch QA Checklist

Before accepting generated assets, verify:

- Asset is readable at 32 px tile scale.
- Camera angle matches the pack: orthographic top-down or three-quarter top-down.
- Transparent-background assets have clean alpha edges.
- Tile materials are seamless or intentionally grid-aligned.
- Shadows are soft and do not merge multiple assets together.
- No text, labels, signatures, watermarks, or brand marks are visible.
- Each machine or counter has a clear interaction side.
- Scale is consistent inside each generated batch.
- Palette remains warm, cozy, and varied without becoming neon or monochrome.
- Sprite sheets use strict equal cells with centered poses.
