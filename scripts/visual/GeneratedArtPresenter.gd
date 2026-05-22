extends RefCounted
class_name GeneratedArtPresenter

# ─────────────────────────────────────────────────────────────────────────────
# Whiskwick – GeneratedArtPresenter  (Phase 1 upgrade: pixel arts/ sprites)
#
# All textures now point to "res://pixel arts/" hand-crafted sprites.
# Architecture is identical to the original so every existing call site works.
# ─────────────────────────────────────────────────────────────────────────────

const CELL_SIZE := 32

# ── Floor / wall / decal (batch_03 sheets kept – no hand-crafted equivalent)
const FLOOR_TEXTURE_PATH   := "res://assets/art/generated/environment/batch_03/room_floor_tiles_8x4.png"
const WALL_TEXTURE_PATH    := "res://assets/art/generated/environment/batch_03/room_wall_modules_8x3.png"
const DECAL_TEXTURE_PATH   := "res://assets/art/generated/environment/batch_03/floor_decals_markers_8x1.png"

# ── Characters (pixel arts/ hand-crafted sprites)
const PLAYER_WALK_TEXTURE_PATH := "res://pixel arts/player_4dir.png"
const PLAYER_SOUTH_TEXTURE_PATH := "res://pixel arts/player_walk_south.png"

# ── Workers (pixel arts/ individual sprites)
const WORKER_BAKER_PATH   := "res://pixel arts/worker_baker.png"
const WORKER_CASHIER_PATH := "res://pixel arts/worker_cashier.png"
const WORKER_RUNNER_PATH  := "res://pixel arts/worker_runner.png"
const WORKER_CLEANER_PATH := "res://pixel arts/worker_cleaner.png"

# ── Customers (pixel arts/ individual sprites)
const CUSTOMER_REGULAR_PATH := "res://pixel arts/customer_regular.png"
const CUSTOMER_KID_PATH     := "res://pixel arts/customer_kid.png"
const CUSTOMER_OFFICE_PATH  := "res://pixel arts/customer_office.png"
const CUSTOMER_ELDER_PATH   := "res://pixel arts/customer_elder.png"

# ── Machines / placeables (pixel arts/ individual sprites)
const OVEN_PATH            := "res://pixel arts/oven.png"
const PREP_COUNTER_PATH    := "res://pixel arts/prep_counter.png"
const STOVETOP_PATH        := "res://pixel arts/stovetop.png"
const SHELF_DISPLAY_PATH   := "res://pixel arts/shelf_display.png"
const SHELF_INGR_PATH      := "res://pixel arts/shelf_ingredients.png"
const SHELF_WARE_PATH      := "res://pixel arts/shelf_warehouse.png"
const MIXER_PATH           := "res://pixel arts/mixer.png"
const CASHIER_STAND_PATH   := "res://pixel arts/cashier_stand.png"
const SINK_PATH            := "res://pixel arts/sink.png"
const TABLE_2_PATH         := "res://pixel arts/table_2seat.png"
const TABLE_4_PATH         := "res://pixel arts/table_4seat.png"
const COLD_STORAGE_PATH    := "res://pixel arts/cold_storage.png"
const TABLET_STATION_PATH  := "res://pixel arts/tablet_station.png"
const TRASH_BIN_PATH       := "res://pixel arts/trash_bin.png"
const PLANT_DECOR_PATH     := "res://pixel arts/plant_decor.png"
const INGREDIENT_CRATE_PATH := "res://pixel arts/ingredient_crate.png"
const DELIVERY_BOX_PATH    := "res://pixel arts/delivery_box.png"
const SERVICE_COUNTER_PATH := "res://pixel arts/service_counter.png"
const COOLING_RACK_PATH    := "res://pixel arts/cooling_rack.png"
const PALLET_PATH          := "res://pixel arts/pallet.png"

# ── Decor / props
const DOOR_ENTRANCE_PATH   := "res://pixel arts/door_entrance.png"
const DOOR_INTERIOR_PATH   := "res://pixel arts/door_interior.png"
const DECOR_MENU_BOARD_PATH := "res://pixel arts/decor_menu_board.png"
const DECOR_WALL_CLOCK_PATH := "res://pixel arts/decor_wall_clock.png"
const DECOR_PINBOARD_PATH  := "res://pixel arts/decor_pinboard.png"
const DECOR_FRAMED_ART_PATH := "res://pixel arts/decor_framed_art.png"
const DECOR_HANGING_LIGHT_PATH := "res://pixel arts/decor_hanging_light.png"

# ── FX sprites
const FX_COIN_POP_PATH     := "res://pixel arts/fx_coin_pop.png"
const FX_SPARKLE_PATH      := "res://pixel arts/fx_sparkle.png"
const FX_STEAM_PATH        := "res://pixel arts/fx_steam.png"
const FX_DUST_PUFF_PATH    := "res://pixel arts/fx_dust_puff.png"
const FX_HEAT_SHIMMER_PATH := "res://pixel arts/fx_heat_shimmer.png"

# ── Floor-tile row map (batch_03 sheet, unchanged)
const ROOM_FLOOR_ROWS := {
	"sales_room": 0,
	"kitchen":    1,
	"warehouse":  2
}

# ── Machine-id → pixel-art texture path
# Every call to decorate_control() looks up the build_id here and loads
# the matching full-sprite PNG (no atlas slicing needed for individual sprites).
const MACHINE_TEXTURE_MAP := {
	"oven_basic":           "res://pixel arts/oven.png",
	"prep_counter_basic":   "res://pixel arts/prep_counter.png",
	"stovetop_basic":       "res://pixel arts/stovetop.png",
	"display_case_basic":   "res://pixel arts/shelf_display.png",
	"warehouse_shelf_basic":"res://pixel arts/shelf_warehouse.png",
	"cold_storage_basic":   "res://pixel arts/cold_storage.png",
	"mixer":                "res://pixel arts/mixer.png",
	"drink_station":        "res://pixel arts/stovetop.png",
	"service_counter_basic":"res://pixel arts/service_counter.png",
	"small_table_two_seat": "res://pixel arts/table_2seat.png",
	"small_table_four_seat":"res://pixel arts/table_4seat.png",
	"sink":                 "res://pixel arts/sink.png",
	"trash_bin":            "res://pixel arts/trash_bin.png",
	"tablet_station":       "res://pixel arts/tablet_station.png",
	"packing_station":      "res://pixel arts/prep_counter.png",
	"decor_plant":          "res://pixel arts/plant_decor.png",
	"ingredient_crate_stack":"res://pixel arts/ingredient_crate.png",
	"kitchen_pass_counter": "res://pixel arts/service_counter.png",
	"cooling_rack":         "res://pixel arts/cooling_rack.png",
	"delivery_box":         "res://pixel arts/delivery_box.png",
}

# ── Animated machine ids → cycle sheet + frame count
# These use the batch_01 bake-cycle sheets that have proper frame sequences.
const ANIMATED_MACHINE_MAP := {
	"oven_basic":         {"path": "res://assets/art/generated/pixel_batch_01/oven_basic_bake_cycle_6x1.png",       "frames": 6, "fps": 4,  "anim": "bake"},
	"prep_counter_basic": {"path": "res://assets/art/generated/pixel_batch_01/prep_counter_work_cycle_6x1.png",     "frames": 6, "fps": 3,  "anim": "prep"},
	"display_case_basic": {"path": "res://assets/art/generated/pixel_batch_01/display_case_stock_states_4x1.png",   "frames": 4, "fps": 1,  "anim": "stock"},
}

# ── Texture cache (shared across all calls)
static var _texture_cache: Dictionary = {}

# ─────────────────────────────────────────────────────────────────────────────
# PUBLIC API – identical signatures to original so all call sites compile
# ─────────────────────────────────────────────────────────────────────────────

## Tile the floor of a room with batch_03 atlas tiles (unchanged).
static func add_room_floor(parent: Node2D, room_id: String, origin: Vector2i, size: Vector2i) -> void:
	if not ROOM_FLOOR_ROWS.has(room_id):
		push_error("GeneratedArtPresenter: missing floor row for room '%s'." % room_id)
		return
	var row: int = int(ROOM_FLOOR_ROWS[room_id])
	var tex := _load_texture(FLOOR_TEXTURE_PATH)
	for y in size.y:
		for x in size.x:
			var sprite := Sprite2D.new()
			sprite.name = "%sFloor_%02d_%02d" % [room_id, x, y]
			sprite.texture = _atlas_texture(tex, Vector2i((x + y) % 8, row), Vector2i(32, 32))
			sprite.position = Vector2(origin + Vector2i(x, y)) * CELL_SIZE + Vector2(16, 16)
			parent.add_child(sprite)

## Place a single floor decal from the batch_03 decal strip.
static func add_floor_decal(parent: Node2D, cell: Vector2i, decal_index: int, decal_name: String) -> void:
	if decal_index < 0 or decal_index >= 8:
		push_error("GeneratedArtPresenter: invalid decal index %d." % decal_index)
		return
	var sprite := Sprite2D.new()
	sprite.name = decal_name
	sprite.texture = _atlas_texture(_load_texture(DECAL_TEXTURE_PATH), Vector2i(decal_index, 0), Vector2i(32, 32))
	sprite.position = Vector2(cell) * CELL_SIZE + Vector2(16, 16)
	parent.add_child(sprite)

## Place a wall module from the batch_03 wall atlas.
static func add_wall_module(parent: Node2D, cell: Vector2i, room_row: int, module_col: int, module_name: String) -> void:
	if room_row < 0 or room_row >= 3 or module_col < 0 or module_col >= 8:
		push_error("GeneratedArtPresenter: invalid wall module (%d, %d)." % [module_col, room_row])
		return
	var sprite := Sprite2D.new()
	sprite.name = module_name
	sprite.texture = _atlas_texture(_load_texture(WALL_TEXTURE_PATH), Vector2i(module_col, room_row), Vector2i(64, 64))
	sprite.position = Vector2(cell) * CELL_SIZE + Vector2(32, 32)
	parent.add_child(sprite)

## Decorate a Control node (ColorRect fixture) with the matching pixel-art sprite.
## Animated machines get an AnimatedSprite2D; static machines get a Sprite2D.
static func decorate_control(control: Control, build_id: String, frame_size: Vector2i = Vector2i(64, 64), animated: bool = false) -> bool:
	if control == null:
		push_error("GeneratedArtPresenter: cannot decorate null control for '%s'." % build_id)
		return false

	# ── Animated path (bake-cycle sheets)
	if animated and ANIMATED_MACHINE_MAP.has(build_id):
		var anim_sprite := _animated_for_build(build_id)
		if anim_sprite == null:
			return false
		_clear_visual_children(control)
		if control is ColorRect:
			(control as ColorRect).color = Color(1, 1, 1, 0.02)
		anim_sprite.name = "GeneratedAnimatedArt"
		anim_sprite.position = control.size * 0.5
		anim_sprite.z_index = 1
		control.add_child(anim_sprite)
		return true

	# ── Static path – pixel arts/ individual PNG
	if MACHINE_TEXTURE_MAP.has(build_id):
		_clear_visual_children(control)
		if control is ColorRect:
			(control as ColorRect).color = Color(1, 1, 1, 0.02)
		var sprite := Sprite2D.new()
		sprite.name = "GeneratedStaticArt"
		sprite.texture = _load_texture(MACHINE_TEXTURE_MAP[build_id])
		# Scale to fit the control size (most pixel arts are designed at 64×64)
		if sprite.texture != null:
			var tex_size := sprite.texture.get_size()
			if tex_size.x > 0 and tex_size.y > 0:
				sprite.scale = Vector2(control.size.x / tex_size.x, control.size.y / tex_size.y)
		sprite.position = control.size * 0.5
		sprite.z_index = 1
		control.add_child(sprite)
		return true

	push_error("GeneratedArtPresenter: no pixel art registered for '%s'." % build_id)
	return false

## Wire the player ColorRect with the 4-directional walk sprite sheet.
## player_4dir.png: 64×96, hframes=4, vframes=4 (south/north/west/east rows).
static func decorate_player(player: Control) -> AnimatedSprite2D:
	if player == null:
		push_error("GeneratedArtPresenter: player node is null.")
		return null
	_clear_visual_children(player)
	if player is ColorRect:
		(player as ColorRect).color = Color(1, 1, 1, 0.02)

	var tex := _load_texture(PLAYER_WALK_TEXTURE_PATH)
	if tex == null:
		# Fallback: try the south-only sheet
		tex = _load_texture(PLAYER_SOUTH_TEXTURE_PATH)
	if tex == null:
		push_error("GeneratedArtPresenter: player texture not found.")
		return null

	# player_4dir.png layout per the project tips:
	#   hframes=4, vframes=4 — Row 0=South, Row 1=North, Row 2=West, Row 3=East
	var frame_size := Vector2i(16, 24)            # 64/4 × 96/4
	var tex_size   := tex.get_size()
	if tex_size.x >= 64 and tex_size.y >= 96:
		frame_size = Vector2i(int(tex_size.x) / 4, int(tex_size.y) / 4)

	var sprite := _build_4dir_player_sprite(tex, frame_size)
	sprite.name = "GeneratedPlayerArt"
	sprite.position = Vector2(player.size.x * 0.5, player.size.y * 0.5 - 4.0)
	sprite.z_index = 20
	sprite.scale = Vector2(2.0, 2.0)             # upscale for gameplay visibility
	player.add_child(sprite)
	return sprite

## Place an animated customer sprite on a Node2D.
static func decorate_customer(customer: Node2D) -> AnimatedSprite2D:
	if customer == null:
		push_error("GeneratedArtPresenter: customer node is null.")
		return null

	# Hide placeholder body rect
	var body := customer.get_node_or_null("Body")
	if body is ColorRect:
		(body as ColorRect).color = Color(1, 1, 1, 0.0)

	# Pick sprite by customer name or fall back to regular
	var tex_path := CUSTOMER_REGULAR_PATH
	var cname: String = str(customer.get("customer_name") if customer.get("customer_name") != null else "")
	# Simple heuristic: kids get the kid sprite (names "Ada","Milo","Nora" etc.)
	# Workers can extend this logic later with a role property
	if cname in ["Ada", "Poppy", "Finn"]:
		tex_path = CUSTOMER_KID_PATH

	var tex := _load_texture(tex_path)
	if tex == null:
		push_error("GeneratedArtPresenter: customer texture not found: %s" % tex_path)
		return null

	var sprite := AnimatedSprite2D.new()
	sprite.name = "GeneratedCustomerArt"

	# Customer sprites are single static frames — build a simple idle loop
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_speed("idle", 1.0)
	frames.set_animation_loop("idle", true)
	frames.add_frame("idle", tex)
	sprite.sprite_frames = frames
	sprite.animation = "idle"
	sprite.scale = Vector2(1.5, 1.5)
	sprite.position = Vector2(0, -8)
	sprite.z_index = 12
	customer.add_child(sprite)
	sprite.play("idle")
	return sprite

## Add a worker AnimatedSprite2D at a world position.
static func add_worker(parent: Node2D, role: String, world_pos: Vector2, animation_name: String) -> AnimatedSprite2D:
	var tex_path: String
	match role:
		"baker":   tex_path = WORKER_BAKER_PATH
		"cashier": tex_path = WORKER_CASHIER_PATH
		"runner":  tex_path = WORKER_RUNNER_PATH
		"cleaner": tex_path = WORKER_CLEANER_PATH
		_:
			push_error("GeneratedArtPresenter: unknown worker role '%s'." % role)
			return null

	var tex := _load_texture(tex_path)
	if tex == null:
		push_error("GeneratedArtPresenter: worker texture not found: %s" % tex_path)
		return null

	var frames := SpriteFrames.new()
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, 2.0)
	frames.set_animation_loop(animation_name, true)
	frames.add_frame(animation_name, tex)

	var sprite := AnimatedSprite2D.new()
	sprite.name = "%sWorkerArt" % role.capitalize()
	sprite.sprite_frames = frames
	sprite.animation = animation_name
	sprite.position = world_pos
	sprite.scale = Vector2(1.5, 1.5)
	sprite.z_index = 18
	parent.add_child(sprite)
	sprite.play(animation_name)
	return sprite

# ─────────────────────────────────────────────────────────────────────────────
# FX HELPERS
# ─────────────────────────────────────────────────────────────────────────────

## Spawn a floating "+N coins" label at world_pos and animate it upward.
static func spawn_coin_fx(parent: Node2D, world_pos: Vector2, amount: int) -> void:
	var label := Label.new()
	label.text = "+%d" % amount
	label.position = world_pos + Vector2(-16, -20)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1, 1.0))
	label.add_theme_font_size_override("font_size", 18)
	parent.add_child(label)

	# Optionally add coin-pop sprite above the label
	var tex := _load_texture(FX_COIN_POP_PATH)
	if tex != null:
		var sprite := Sprite2D.new()
		sprite.texture = tex
		sprite.position = world_pos + Vector2(8, -36)
		sprite.scale = Vector2(0.8, 0.8)
		parent.add_child(sprite)

	# Animate via tween (Godot 4 syntax)
	var tree := parent.get_tree()
	if tree == null:
		label.queue_free()
		return
	var tween := tree.create_tween()
	tween.tween_property(label, "position:y", label.position.y - 40.0, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)

## Spawn a sparkle FX at a world position (e.g. after a successful serve).
static func spawn_sparkle_fx(parent: Node2D, world_pos: Vector2) -> void:
	var tex := _load_texture(FX_SPARKLE_PATH)
	if tex == null:
		return
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.position = world_pos
	sprite.z_index = 30
	parent.add_child(sprite)

	var tree := parent.get_tree()
	if tree == null:
		sprite.queue_free()
		return
	var tween := tree.create_tween()
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.4)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.4)
	tween.tween_callback(sprite.queue_free)

# ─────────────────────────────────────────────────────────────────────────────
# INTERNAL HELPERS
# ─────────────────────────────────────────────────────────────────────────────

## Build the 4-direction player AnimatedSprite2D from a 4×4 walk sheet.
## Row 0=South, Row 1=North, Row 2=West, Row 3=East  (per project tips).
static func _build_4dir_player_sprite(texture: Texture2D, frame_size: Vector2i) -> AnimatedSprite2D:
	var frames     := SpriteFrames.new()
	var directions := ["south", "north", "west", "east"]

	for row in directions.size():
		var anim_name := "player_walk_%s" % directions[row]
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, 8.0)
		frames.set_animation_loop(anim_name, true)
		for col in 4:
			frames.add_frame(anim_name, _atlas_texture(texture, Vector2i(col, row), frame_size))

	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.animation = "player_walk_south"
	sprite.play(sprite.animation)
	return sprite

## Build an animated sprite from a horizontal strip (used for bake-cycle sheets).
static func _build_sequence_sprite(texture: Texture2D, frame_size: Vector2i, columns: Array[int], fps: int, animation_name: String) -> AnimatedSprite2D:
	var frames := SpriteFrames.new()
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, float(fps))
	frames.set_animation_loop(animation_name, true)
	for col in columns:
		frames.add_frame(animation_name, _atlas_texture(texture, Vector2i(col, 0), frame_size))
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.animation = animation_name
	sprite.play(animation_name)
	return sprite

## Return an AnimatedSprite2D for machines that have bake-cycle sheets.
static func _animated_for_build(build_id: String) -> AnimatedSprite2D:
	if not ANIMATED_MACHINE_MAP.has(build_id):
		return null
	var data: Dictionary = ANIMATED_MACHINE_MAP[build_id]
	var tex := _load_texture(str(data.get("path", "")))
	if tex == null:
		return null
	var frame_count: int = int(data.get("frames", 1))
	var fps: int = int(data.get("fps", 4))
	var anim: String = str(data.get("anim", "loop"))
	var tex_size := tex.get_size()
	var frame_w := int(tex_size.x) / frame_count if frame_count > 0 else int(tex_size.x)
	var frame_h := int(tex_size.y)
	var cols: Array[int] = []
	for i in frame_count:
		cols.append(i)
	return _build_sequence_sprite(tex, Vector2i(frame_w, frame_h), cols, fps, anim)

## Slice an atlas texture at the given grid cell.
static func _atlas_texture(texture: Texture2D, atlas_cell: Vector2i, frame_size: Vector2i) -> AtlasTexture:
	if texture == null:
		push_error("GeneratedArtPresenter: source texture is null.")
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas  = texture
	atlas.region = Rect2(Vector2(atlas_cell * frame_size), Vector2(frame_size))
	return atlas

## Load and cache a texture by path.
static func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if _texture_cache.has(path):
		return _texture_cache[path] as Texture2D

	# Try ResourceLoader first (works for imported .png files in Godot)
	var resource := ResourceLoader.load(path, "Texture2D")
	if resource is Texture2D:
		_texture_cache[path] = resource
		return resource as Texture2D

	# Fallback: load raw image bytes
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		push_warning("GeneratedArtPresenter: could not load '%s' (error %d)." % [path, error])
		return null
	var tex := ImageTexture.create_from_image(image)
	_texture_cache[path] = tex
	return tex

## Remove previously added Generated* children so we don't double-up.
static func _clear_visual_children(control: Node) -> void:
	for child in control.get_children():
		if child.name.begins_with("Generated"):
			child.queue_free()
