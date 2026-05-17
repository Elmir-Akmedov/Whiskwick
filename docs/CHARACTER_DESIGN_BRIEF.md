# Character Design Brief

Whiskwick characters should read instantly from a top-down camera while still feeling like believable miniature people in a cozy food shop. The target look is realistic 3D pixel/voxel-like: chunky, low-detail forms; soft baked-goods colors; tactile fabric and apron materials; and silhouettes that remain clear when scaled down.

## Shared Style Rules

- Characters use simple blocky proportions with softened bevels, not toy-like cylinders or flat paper sprites.
- Heads, shoulders, hands, tools, and aprons should be exaggerated just enough to read from above.
- Hair and hats should create strong top-down identifiers.
- Outfits should avoid tiny text, thin stripes, noisy prints, or details that disappear at gameplay scale.
- Staff should share a warm shop uniform language, but each role needs one unmistakable shape cue.
- Customers should feel like regular neighborhood visitors, not fantasy caricatures.
- Each archetype needs idle, walk, interact/order, happy, impatient, and blocked/failed micro-reactions unless noted otherwise.

## Top-Down Sprite Requirements

- Camera target: top-down or three-quarter top-down with visible head, shoulders, torso color block, hands, and role props.
- Direction set: 4-direction minimum; 8-direction preferred for smoother pathing.
- Read size: recognizable at 32 to 48 pixels tall in gameplay.
- Silhouette priority: headwear/hair shape first, torso block second, carried prop third.
- Contrast: hair/hat must separate from floor colors; apron or jacket must separate from counters.
- Animation timing: cozy and slightly bouncy, with short anticipation on work actions.
- Occlusion: important props should sit above or beside the body so counters do not hide them.
- Shadow: soft compact oval shadow, consistent across all characters.

## Staff Archetypes

### 1. Player

- Silhouette: compact, balanced body with a rounded head, short practical hair or tucked cap, visible hands, and a small waist apron.
- Outfit: casual shop clothes under a half apron; rolled sleeves; comfortable shoes; optional flour smudge on apron.
- Palette: cream apron, warm teal or sage shirt, dark cocoa trousers, chestnut or dark hair.
- Personality: capable, curious, hands-on, slightly scrappy; should look like someone learning by doing.
- Animation needs: idle breathing, walk, pick up, carry tray/box, place item, cook/prep, serve, use tablet, tired slump, success cheer.
- Gameplay readability: the player must be the most neutral and flexible character, with no role prop that implies only one job.
- Top-down sprite requirements: strong apron rectangle and visible hand positions for carrying states; hair/cap must remain distinct from staff hats.
- AI prompt snippet: "cozy top-down food shop player character, realistic 3D pixel voxel style, cream half apron, sage shirt, dark trousers, practical friendly look, chunky readable silhouette, soft bakery lighting"

### 2. Cashier

- Silhouette: upright and front-facing posture with crisp shoulders, small coin pouch or receipt pad, and a tidy hair shape.
- Outfit: clean full apron over a button shirt; name tag as a simple color block; neat shoes.
- Palette: buttercream apron, muted navy shirt, brass accent, soft brown hair.
- Personality: warm, efficient, composed under a queue, good at making customers feel noticed.
- Animation needs: idle at register, tap register, accept payment, hand receipt, wave next customer, polite apology, queue-stress glance.
- Gameplay readability: should be instantly tied to payment and order-taking; hands often held forward over counter.
- Top-down sprite requirements: register-side stance should have a clear forward arm pose; avoid props hidden by the counter.
- AI prompt snippet: "cashier for cozy bakery management game, top-down realistic 3D pixel voxel character, buttercream apron, muted navy shirt, tidy posture, receipt pad, friendly service expression"

### 3. Baker

- Silhouette: broad upper body, tall chef hat or kerchief, thick oven mitts, floury apron.
- Outfit: short-sleeve baker coat, full apron, oven mitts clipped or worn, sturdy shoes.
- Palette: flour white, toasted cream, oven red accents, charcoal shoes.
- Personality: focused, calm, proud of craft, a little perfectionist.
- Animation needs: knead, stir, load oven, unload oven, sprinkle/topping, inspect bake, wipe brow, satisfied nod.
- Gameplay readability: chef hat and mitts must scream oven/cooking role even from the camera angle.
- Top-down sprite requirements: chef hat must be wide enough to read from above; oven mitt color should contrast with apron.
- AI prompt snippet: "cozy bakery baker character, top-down realistic 3D pixel voxel style, tall soft chef hat, flour-dusted apron, oven mitts, warm cream and red accents, sturdy readable silhouette"

### 4. Runner

- Silhouette: lean forward-tilted body, cross-body satchel or crate straps, quick feet, one raised carry arm.
- Outfit: short apron or utility vest, rolled trousers, grippy shoes, small towel tucked at waist.
- Palette: oat tan, tomato red strap, denim blue trousers, cream shirt.
- Personality: energetic, practical, alert, always looking for the shortest clean route.
- Animation needs: brisk walk, light jog, pick up crate, carry stack, drop off stock, route confusion, stamina slowdown.
- Gameplay readability: should read as movement/logistics, not cooking; straps and carry poses do most of the work.
- Top-down sprite requirements: carried boxes must extend to one side or above the head so item transport is visible.
- AI prompt snippet: "food shop runner worker, top-down realistic 3D pixel voxel style, utility apron, cross-body strap, carrying ingredient crate, energetic lean, warm oat tan and tomato red palette"

### 5. Cleaner

- Silhouette: slightly bent ready posture with mop, small bucket, tied bandana, and sleeves pushed up.
- Outfit: durable apron, gloves, bandana or hair wrap, rubber shoes.
- Palette: mint green apron, pale cream shirt, blue gloves, warm gray trousers.
- Personality: observant, unflappable, gently no-nonsense; keeps the shop feeling cared for.
- Animation needs: mop, wipe counter, collect trash, carry bucket, spot mess, satisfied sparkle gesture, tired stretch.
- Gameplay readability: cleaning tool must remain visible at all times when assigned or moving to a mess.
- Top-down sprite requirements: mop handle should angle diagonally outside the body footprint for recognition.
- AI prompt snippet: "cozy bakery cleaner worker, top-down realistic 3D pixel voxel character, mint apron, blue gloves, bandana, mop and small bucket, practical warm personality, clear chunky silhouette"

### 6. Manager

- Silhouette: taller confident stance, clipboard or tablet held near chest, neat jacket or vest, distinct hairstyle.
- Outfit: soft vest over shop shirt, waist apron, practical dress shoes, small pen behind ear.
- Palette: cocoa vest, cream shirt, muted gold apron tie, dark green detail.
- Personality: strategic, reassuring, quietly sharp; sees the whole room instead of one task.
- Animation needs: check clipboard, point route, review schedule, approve order, encourage staff, concern glance, calm celebration.
- Gameplay readability: should read as planning/scheduling rather than service counter labor.
- Top-down sprite requirements: clipboard/tablet must be visible as a colored rectangle above the torso.
- AI prompt snippet: "cozy food shop manager, top-down realistic 3D pixel voxel style, cocoa vest, cream shirt, clipboard, confident calm posture, bakery management game character"

## Customer Archetypes

### 7. Morning Regular

- Silhouette: relaxed upright shape with commuter bag, tidy hair, and small takeaway cup pose.
- Outfit: cardigan or light jacket, simple trousers or skirt, shoulder bag.
- Palette: coffee brown, pale blue, cream, soft black shoes.
- Personality: kind, routine-driven, patient if the line moves, attached to favorite items.
- Animation needs: enter, browse display, queue idle, order, pay, sip, happy nod, mild impatience.
- Gameplay readability: should communicate quick breakfast customer with low visual noise.
- Top-down sprite requirements: shoulder bag should sit on one side to create asymmetry.
- AI prompt snippet: "morning regular customer in cozy bakery, top-down realistic 3D pixel voxel style, cardigan, shoulder bag, takeaway cup, soft coffee brown and pale blue palette"

### 8. Sweet-Tooth Kid

- Silhouette: short round body, oversized hair bow or cap, tiny backpack, excited bouncing posture.
- Outfit: bright jacket, shorts or comfy pants, small backpack, sneakers.
- Palette: strawberry pink, lemon yellow, denim blue, white accents.
- Personality: delighted, impulsive, easily amazed by cakes and cupcakes.
- Animation needs: bounce idle, point at display, order with excitement, happy jump, impatient foot tap, follow adult path.
- Gameplay readability: small scale must still be obvious; color and bounce identify the kid.
- Top-down sprite requirements: head accessory must be large enough to read without making the character look like a toy.
- AI prompt snippet: "sweet-tooth child customer, cozy bakery game, top-down realistic 3D pixel voxel style, small rounded silhouette, bright jacket, tiny backpack, excited cake-pointing pose"

### 9. Office Luncher

- Silhouette: narrow vertical body with squared blazer shoulders, phone in hand, compact briefcase.
- Outfit: casual office blazer, pressed shirt, slim trousers, simple shoes.
- Palette: charcoal, soft white, mustard scarf or tie, muted burgundy bag.
- Personality: time-conscious, polite but easily impatient during rush.
- Animation needs: check phone, queue shuffle, order quickly, pay fast, impatience glance, relieved exit.
- Gameplay readability: should signal short patience and lunch-rush behavior through phone and posture.
- Top-down sprite requirements: phone hand should be visible as a bright small rectangle near the head or chest.
- AI prompt snippet: "office lunch customer, top-down realistic 3D pixel voxel bakery character, blazer, phone in hand, compact briefcase, time-conscious posture, charcoal and mustard palette"

### 10. Cozy Elder

- Silhouette: slightly stooped posture, rounded shoulders, cane or folded shopping bag, soft hat.
- Outfit: knitted cardigan, long skirt or loose trousers, comfortable shoes, small hat.
- Palette: lavender gray, warm cream, muted plum, soft moss green.
- Personality: patient, observant, appreciates seating and calm service.
- Animation needs: slow walk, careful queue idle, sit, order, pay, grateful smile, mild confusion if blocked.
- Gameplay readability: slower movement and cane/bag tell the player this customer needs clear paths.
- Top-down sprite requirements: cane or bag should offset the silhouette; walk cycle should have smaller steps.
- AI prompt snippet: "cozy elderly bakery customer, top-down realistic 3D pixel voxel style, knitted cardigan, soft hat, cane or folded shopping bag, gentle patient personality, lavender gray palette"

### 11. Family Treat Buyer

- Silhouette: medium broad body with tote bag, warm jacket, one hand raised as if choosing for others.
- Outfit: practical jacket, soft scarf, roomy tote, comfortable shoes.
- Palette: pumpkin orange, cream, forest green, dark denim.
- Personality: thoughtful, compares options, buys multiple items, happiest when displays are stocked.
- Animation needs: browse longer, compare display items, order several goods, count money/card, pleased carry-out pose.
- Gameplay readability: should imply larger orders and display browsing without needing UI text.
- Top-down sprite requirements: tote bag should visibly expand or shift during exit after purchase if possible.
- AI prompt snippet: "family treat buyer customer, cozy top-down bakery game, realistic 3D pixel voxel style, practical jacket, roomy tote bag, choosing cakes for family, pumpkin orange and forest green palette"

### 12. Trendy Foodie

- Silhouette: stylish angular shape with statement hair, small camera/phone, crossbody mini bag.
- Outfit: cropped jacket or patterned overshirt, clean sneakers, compact bag, subtle accessory.
- Palette: black sesame, cream, raspberry accent, pale mint.
- Personality: curious, expressive, notices specialty items and decor, rewards variety.
- Animation needs: photograph food, browse decor, order specialty item, delighted reaction, disappointed shrug, social-share pose.
- Gameplay readability: should read as variety-seeking and specialty-focused through phone/camera action.
- Top-down sprite requirements: hairstyle and phone pose must remain identifiable; avoid patterns that shimmer at low resolution.
- AI prompt snippet: "trendy foodie customer in cozy bakery, top-down realistic 3D pixel voxel style, statement hair, crossbody bag, phone camera pose, black sesame cream raspberry mint palette"

## Readability Checks

- Staff roles should be identifiable by silhouette alone in grayscale.
- Customer types should be identifiable by motion and accessories even when outfits share warm colors.
- No two staff members should share the same dominant head shape.
- No two customer types should share the same side accessory placement.
- Any AI-generated character concept should be checked from the top-down camera before accepting outfit details.
- Character palettes should harmonize with bakery interiors while preserving contrast against wood floors, cream counters, metal machines, and display cases.
