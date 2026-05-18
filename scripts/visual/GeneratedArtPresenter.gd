extends RefCounted
class_name GeneratedArtPresenter

const CELL_SIZE := 32
const FLOOR_TEXTURE_PATH := "res://assets/art/generated/environment/batch_03/room_floor_tiles_8x4.png"
const WALL_TEXTURE_PATH := "res://assets/art/generated/environment/batch_03/room_wall_modules_8x3.png"
const MACHINE_TEXTURE_PATH := "res://assets/art/generated/environment/batch_03/starter_machines_placeables_4x4.png"
const DECAL_TEXTURE_PATH := "res://assets/art/generated/environment/batch_03/floor_decals_markers_8x1.png"
const PLAYER_WALK_TEXTURE_PATH := "res://assets/art/generated/animations/batch_02/player_walk_4dir_4f_4x4.png"
const RUNNER_WALK_TEXTURE_PATH := "res://assets/art/generated/animations/batch_02/runner_carry_walk_4dir_4f_4x4.png"
const WORKER_TEXTURE_PATH := "res://assets/art/generated/animations/batch_02/worker_task_loops_6x4.png"
const CUSTOMER_TEXTURE_PATH := "res://assets/art/generated/animations/batch_02/customer_reactions_8x2.png"
const OVEN_TEXTURE_PATH := "res://assets/art/generated/pixel_batch_01/oven_basic_bake_cycle_6x1.png"
const PREP_COUNTER_TEXTURE_PATH := "res://assets/art/generated/pixel_batch_01/prep_counter_work_cycle_6x1.png"
const DISPLAY_CASE_TEXTURE_PATH := "res://assets/art/generated/pixel_batch_01/display_case_stock_states_4x1.png"
const CRATE_TEXTURE_PATH := "res://assets/art/generated/pixel_batch_01/ingredient_crate_stock_states_4x1.png"

static var _texture_cache: Dictionary = {}

const ROOM_FLOOR_ROWS := {
	"sales_room": 0,
	"kitchen": 1,
	"warehouse": 2
}

const MACHINE_CELLS := {
	"oven_basic": Vector2i(0, 0),
	"prep_counter_basic": Vector2i(1, 0),
	"stovetop_basic": Vector2i(2, 0),
	"display_case_basic": Vector2i(3, 0),
	"warehouse_shelf_basic": Vector2i(0, 1),
	"cold_storage_basic": Vector2i(1, 1),
	"mixer": Vector2i(2, 1),
	"drink_station": Vector2i(3, 1),
	"service_counter_basic": Vector2i(0, 2),
	"small_table_two_seat": Vector2i(1, 2),
	"sink": Vector2i(2, 2),
	"trash_bin": Vector2i(3, 2),
	"tablet_station": Vector2i(0, 3),
	"packing_station": Vector2i(1, 3),
	"decor_plant": Vector2i(2, 3)
}

static func add_room_floor(parent: Node2D, room_id: String, origin: Vector2i, size: Vector2i) -> void:
	if not ROOM_FLOOR_ROWS.has(room_id):
		push_error("GeneratedArtPresenter: missing floor row for room '%s'." % room_id)
		return
	var row := int(ROOM_FLOOR_ROWS[room_id])
	for y in size.y:
		for x in size.x:
			var sprite := Sprite2D.new()
			sprite.name = "%sFloor_%02d_%02d" % [room_id, x, y]
			sprite.texture = _atlas_texture(_load_texture(FLOOR_TEXTURE_PATH), Vector2i((x + y) % 8, row), Vector2i(32, 32))
			sprite.position = Vector2(origin + Vector2i(x, y)) * CELL_SIZE + Vector2(16, 16)
			parent.add_child(sprite)

static func add_floor_decal(parent: Node2D, cell: Vector2i, decal_index: int, name: String) -> void:
	if decal_index < 0 or decal_index >= 8:
		push_error("GeneratedArtPresenter: invalid decal index %d." % decal_index)
		return
	var sprite := Sprite2D.new()
	sprite.name = name
	sprite.texture = _atlas_texture(_load_texture(DECAL_TEXTURE_PATH), Vector2i(decal_index, 0), Vector2i(32, 32))
	sprite.position = Vector2(cell) * CELL_SIZE + Vector2(16, 16)
	parent.add_child(sprite)

static func add_wall_module(parent: Node2D, cell: Vector2i, room_row: int, module_col: int, name: String) -> void:
	if room_row < 0 or room_row >= 3 or module_col < 0 or module_col >= 8:
		push_error("GeneratedArtPresenter: invalid wall module cell (%d, %d)." % [module_col, room_row])
		return
	var sprite := Sprite2D.new()
	sprite.name = name
	sprite.texture = _atlas_texture(_load_texture(WALL_TEXTURE_PATH), Vector2i(module_col, room_row), Vector2i(64, 64))
	sprite.position = Vector2(cell) * CELL_SIZE + Vector2(32, 32)
	parent.add_child(sprite)

static func decorate_control(control: Control, build_id: String, frame_size: Vector2i = Vector2i(64, 64), animated: bool = false) -> bool:
	if control == null:
		push_error("GeneratedArtPresenter: cannot decorate null control for '%s'." % build_id)
		return false
	if animated:
		var animated_sprite := _animated_for_build(build_id)
		if animated_sprite == null:
			return false
		_clear_visual_children(control)
		if control is ColorRect:
			(control as ColorRect).color = Color(1, 1, 1, 0.02)
		animated_sprite.name = "GeneratedAnimatedArt"
		animated_sprite.position = control.size * 0.5
		animated_sprite.z_index = 1
		control.add_child(animated_sprite)
		return true
	if not MACHINE_CELLS.has(build_id):
		push_error("GeneratedArtPresenter: missing machine/placeable art for '%s'." % build_id)
		return false
	_clear_visual_children(control)
	if control is ColorRect:
		(control as ColorRect).color = Color(1, 1, 1, 0.02)
	var sprite := Sprite2D.new()
	sprite.name = "GeneratedStaticArt"
	var atlas_cell: Vector2i = MACHINE_CELLS[build_id]
	sprite.texture = _atlas_texture(_load_texture(MACHINE_TEXTURE_PATH), atlas_cell, frame_size)
	sprite.position = control.size * 0.5
	sprite.z_index = 1
	control.add_child(sprite)
	return true

static func decorate_player(player: Control) -> AnimatedSprite2D:
	if player == null:
		push_error("GeneratedArtPresenter: player node is null.")
		return null
	_clear_visual_children(player)
	if player is ColorRect:
		(player as ColorRect).color = Color(1, 1, 1, 0.02)
	var sprite := _build_directional_sprite(_load_texture(PLAYER_WALK_TEXTURE_PATH), Vector2i(48, 48), "player")
	sprite.name = "GeneratedPlayerArt"
	sprite.position = Vector2(player.size.x * 0.5, player.size.y * 0.5 - 10.0)
	sprite.z_index = 20
	player.add_child(sprite)
	return sprite

static func decorate_customer(customer: Node2D) -> AnimatedSprite2D:
	if customer == null:
		push_error("GeneratedArtPresenter: customer node is null.")
		return null
	var body := customer.get_node_or_null("Body")
	if body is ColorRect:
		(body as ColorRect).color = Color(1, 1, 1, 0.0)
	var sprite := _build_sequence_sprite(_load_texture(CUSTOMER_TEXTURE_PATH), Vector2i(48, 48), [0, 1, 2, 5], 8, "regular_wait")
	sprite.name = "GeneratedCustomerArt"
	sprite.position = Vector2(0, -8)
	sprite.z_index = 12
	customer.add_child(sprite)
	return sprite

static func add_worker(parent: Node2D, role: String, world_pos: Vector2, animation_name: String) -> AnimatedSprite2D:
	var row: int = int({"baker": 0, "cashier": 1, "runner": 2, "cleaner": 3}.get(role, -1))
	if row < 0:
		push_error("GeneratedArtPresenter: unknown worker role '%s'." % role)
		return null
	var frames := SpriteFrames.new()
	var sequence := [0, 1, 2, 3, 4, 5]
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, 6.0)
	frames.set_animation_loop(animation_name, true)
	for col in sequence:
		frames.add_frame(animation_name, _atlas_texture(_load_texture(WORKER_TEXTURE_PATH), Vector2i(col, row), Vector2i(48, 48)))
	var sprite := AnimatedSprite2D.new()
	sprite.name = "%sWorkerArt" % role.capitalize()
	sprite.sprite_frames = frames
	sprite.animation = animation_name
	sprite.position = world_pos
	sprite.z_index = 18
	parent.add_child(sprite)
	sprite.play(animation_name)
	return sprite

static func _animated_for_build(build_id: String) -> AnimatedSprite2D:
	if build_id == "oven_basic":
		return _build_sequence_sprite(_load_texture(OVEN_TEXTURE_PATH), Vector2i(64, 64), [0, 1, 2, 3, 4, 5], 6, "bake")
	if build_id == "prep_counter_basic":
		return _build_sequence_sprite(_load_texture(PREP_COUNTER_TEXTURE_PATH), Vector2i(64, 64), [0, 1, 2, 3, 4, 5], 6, "prep")
	if build_id == "display_case_basic":
		return _build_sequence_sprite(_load_texture(DISPLAY_CASE_TEXTURE_PATH), Vector2i(64, 64), [0, 1, 2, 3], 2, "stock")
	if build_id == "warehouse_shelf_basic":
		return _build_sequence_sprite(_load_texture(CRATE_TEXTURE_PATH), Vector2i(64, 64), [0, 1, 2, 3], 2, "stock")
	push_error("GeneratedArtPresenter: no animated art for '%s'." % build_id)
	return null

static func _build_directional_sprite(texture: Texture2D, frame_size: Vector2i, prefix: String) -> AnimatedSprite2D:
	var frames := SpriteFrames.new()
	var directions := ["south", "east", "north", "west"]
	for row in directions.size():
		var animation_name := "%s_walk_%s" % [prefix, directions[row]]
		frames.add_animation(animation_name)
		frames.set_animation_speed(animation_name, 8.0)
		frames.set_animation_loop(animation_name, true)
		for col in 4:
			frames.add_frame(animation_name, _atlas_texture(texture, Vector2i(col, row), frame_size))
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.animation = "%s_walk_south" % prefix
	sprite.play(sprite.animation)
	return sprite

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

static func _atlas_texture(texture: Texture2D, atlas_cell: Vector2i, frame_size: Vector2i) -> AtlasTexture:
	if texture == null:
		push_error("GeneratedArtPresenter: source texture is null.")
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(Vector2(atlas_cell * frame_size), Vector2(frame_size))
	return atlas

static func _load_texture(path: String) -> Texture2D:
	if _texture_cache.has(path):
		return _texture_cache[path] as Texture2D
	var resource := ResourceLoader.load(path, "Texture2D")
	if resource is Texture2D:
		_texture_cache[path] = resource
		return resource as Texture2D
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		push_error("GeneratedArtPresenter: failed to load texture '%s' with error %d." % [path, error])
		return null
	var texture := ImageTexture.create_from_image(image)
	_texture_cache[path] = texture
	return texture

static func _clear_visual_children(control: Node) -> void:
	for child in control.get_children():
		if child.name.begins_with("Generated"):
			child.queue_free()
