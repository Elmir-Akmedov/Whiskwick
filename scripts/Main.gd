@tool
extends Node2D

const GeneratedArt := preload("res://scripts/visual/GeneratedArtPresenter.gd")
const CUPCAKE_RECIPE_ID := "cupcake_batch"
const CUPCAKE_BATTER_RECIPE_ID := "cupcake_batter"
const STARTER_INGREDIENTS := {
	"flour": 2,
	"egg": 2,
	"sugar": 2,
	"milk": 2
}
const BUY_STARTER_STAMINA_COST := 4
const COOK_STAMINA_COST := 12
const ROOM_ORIGINS := {
	"sales_room": Vector2i(1, 2),
	"kitchen": Vector2i(15, 2),
	"warehouse": Vector2i(30, 2)
}
const ROOM_SIZES := {
	"sales_room": Vector2i(14, 19),
	"kitchen": Vector2i(15, 19),
	"warehouse": Vector2i(9, 19)
}
const BUILD_PRESETS := {
	"small_table_two_seat": {"room": "sales_room", "color": Color(0.27, 0.45, 0.32, 0.9)},
	"oven_basic": {"room": "kitchen", "color": Color(0.18, 0.18, 0.18, 0.92)},
	"warehouse_shelf_basic": {"room": "warehouse", "color": Color(0.21, 0.28, 0.38, 0.92)}
}

@onready var hud = $HUD
@onready var placed_layer: Node2D = $World/PlacedObjects
@onready var preview_rect: ColorRect = $World/PlacementPreview
@onready var player: ColorRect = $World/Player
@onready var interaction_popup: PanelContainer = $InteractionPopup

var selected_build_id: String = ""
var selected_rotation: int = 0
var hovered_room_id: String = ""
var hovered_cell: Vector2i = Vector2i.ZERO
var can_place_hovered: bool = false
var placed_interactables: Dictionary = {}
var active_interaction_id: String = ""
var table_dirty_state: Dictionary = {}
var art_floor_layer: Node2D = null
var art_wall_layer: Node2D = null
var art_actor_layer: Node2D = null

func _ready() -> void:
	if Engine.is_editor_hint():
		_apply_generated_art()
		return
	_attach_scene_switcher()
	_register_rooms()
	TimeService.time_changed.connect(_on_time_changed)
	TimeService.phase_changed.connect(_on_phase_changed)
	GameState.money_changed.connect(_on_money_changed)
	GameState.stamina_changed.connect(_on_stamina_changed)
	InventoryService.inventory_changed.connect(_on_inventory_changed)
	OrderService.order_created.connect(_on_order_created)
	OrderService.order_completed.connect(_on_order_completed)
	OrderService.orders_paused_changed.connect(_on_orders_paused_changed)
	hud.buy_starter_ingredients_requested.connect(_on_buy_starter_ingredients_requested)
	hud.cook_cupcakes_requested.connect(_on_cook_cupcakes_requested)
	hud.complete_first_order_requested.connect(_on_complete_first_order_requested)
	hud.pause_orders_toggled.connect(_on_pause_orders_toggled)
	hud.skip_time_requested.connect(_on_skip_time_requested)
	hud.place_table_requested.connect(func() -> void: _quick_place_build("small_table_two_seat"))
	hud.place_oven_requested.connect(func() -> void: _quick_place_build("oven_basic"))
	hud.place_rack_requested.connect(func() -> void: _quick_place_build("warehouse_shelf_basic"))
	hud.rotate_placement_requested.connect(_rotate_selected_build)
	$InteractionPopup/Margin/Stack/CleanButton.pressed.connect(_clean_active_table)
	$InteractionPopup/Margin/Stack/CloseButton.pressed.connect(func() -> void: interaction_popup.visible = false)
	GameState.start_new_game()
	InventoryService.reset()
	TimeService.reset_day()
	OrderService.reset_day()
	_apply_generated_art()
	_refresh_hud()
	hud.log_line("07:00 - Morning prep begins. Generated art batch is visible in the shop.")

func _attach_scene_switcher() -> void:
	var switcher_scene := load("res://scripts/ui/SceneSwitcher.gd")
	if switcher_scene == null:
		push_error("Missing SceneSwitcher script.")
		return
	var switcher := CanvasLayer.new()
	switcher.set_script(switcher_scene)
	add_child(switcher)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	TimeService.tick(delta)
	OrderService.tick(delta)
	_update_hovered_placement()

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		_interact_with_nearest()
		get_viewport().set_input_as_handled()
		return
	if selected_build_id.is_empty():
		return
	if event is InputEventMouseButton and event.pressed:
		if _is_hud_click_target():
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_place_selected()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placement()
			get_viewport().set_input_as_handled()

func _on_time_changed(minutes: int) -> void:
	hud.set_clock(TimeService.format_minutes(minutes))

func _on_phase_changed(phase: String) -> void:
	hud.set_phase(phase)
	if phase == TimeService.PHASE_OPEN:
		hud.log_line("10:00 - Shop opened. Customers can enter.")
	elif phase == TimeService.PHASE_CLOSED:
		hud.log_line("19:00 - Shop closed. Night prep is available.")
	elif phase == TimeService.PHASE_EXHAUSTED:
		hud.log_line("22:00 - Exhaustion begins. Actions cost more stamina.")

func _on_money_changed(value: int) -> void:
	hud.set_money(value)

func _on_stamina_changed(value: int) -> void:
	hud.set_stamina(value)

func _on_inventory_changed() -> void:
	hud.set_cupcake_stock(_cupcake_stock())

func _on_order_created(order: Dictionary) -> void:
	hud.set_active_order_count(OrderService.active_orders.size())
	hud.log_line("New order: %s x%s" % [order.get("recipe_id", "unknown"), order.get("quantity", 1)])

func _on_order_completed(order: Dictionary) -> void:
	hud.set_active_order_count(OrderService.active_orders.size())
	hud.log_line("%s - Completed order #%s." % [_clock_stamp(), order.get("id", "?")])

func _on_orders_paused_changed(paused: bool) -> void:
	hud.set_orders_paused(paused)
	hud.log_line("New orders paused." if paused else "New orders resumed.")

func _on_buy_starter_ingredients_requested() -> void:
	var cost := _starter_ingredients_cost()
	if not GameState.can_spend_money(cost):
		hud.log_line("%s - Need $%d for starter ingredients." % [_clock_stamp(), cost])
		return
	if not GameState.spend_stamina(BUY_STARTER_STAMINA_COST):
		hud.log_line("%s - Not enough stamina to shop." % _clock_stamp())
		return
	for ingredient_id in STARTER_INGREDIENTS:
		var buy_result := InventoryService.buy_ingredient(ingredient_id, int(STARTER_INGREDIENTS[ingredient_id]))
		if not bool(buy_result.get("ok", false)):
			hud.log_line("%s - %s" % [_clock_stamp(), buy_result.get("message", "Could not buy ingredient.")])
			return
	hud.log_line("%s - Bought starter ingredients for $%d." % [_clock_stamp(), cost])

func _on_cook_cupcakes_requested() -> void:
	var stamina_cost := COOK_STAMINA_COST
	if TimeService.current_phase == TimeService.PHASE_EXHAUSTED:
		stamina_cost *= 2
	if not GameState.spend_stamina(stamina_cost):
		hud.log_line("%s - Not enough stamina to cook." % _clock_stamp())
		return

	var batter_result := _craft_with_time(CUPCAKE_BATTER_RECIPE_ID)
	if not bool(batter_result.get("ok", false)):
		GameState.restore_stamina(stamina_cost)
		hud.log_line("%s - %s" % [_clock_stamp(), batter_result.get("message", "Could not make batter.")])
		return

	var cupcake_result := _craft_with_time(CUPCAKE_RECIPE_ID)
	if not bool(cupcake_result.get("ok", false)):
		hud.log_line("%s - %s" % [_clock_stamp(), cupcake_result.get("message", "Could not bake cupcakes.")])
		return

	hud.log_line("%s - Cooked %s cupcakes." % [_clock_stamp(), cupcake_result.get("amount", 0)])

func _on_complete_first_order_requested() -> void:
	if OrderService.active_orders.is_empty():
		hud.log_line("%s - No active orders to complete." % _clock_stamp())
		return
	var order: Dictionary = OrderService.active_orders[0]
	var recipe_id := str(order.get("recipe_id", CUPCAKE_RECIPE_ID))
	var quantity := int(order.get("quantity", 1))
	var finished_cost := {}
	finished_cost[recipe_id] = quantity
	if not InventoryService.has_items("finished", finished_cost):
		hud.log_line("%s - Need %d finished %s for order #%s." % [_clock_stamp(), quantity, recipe_id, order.get("id", "?")])
		return
	if not InventoryService.consume_items("finished", finished_cost):
		hud.log_line("%s - Finished stock changed before the order was packed." % _clock_stamp())
		return
	if not OrderService.complete_order(int(order.get("id", 0))):
		InventoryService.add_item("finished", recipe_id, quantity)
		hud.log_line("%s - Order could not be completed." % _clock_stamp())

func _on_pause_orders_toggled() -> void:
	OrderService.set_orders_paused(not OrderService.orders_paused)

func _on_skip_time_requested() -> void:
	TimeService.skip_to_next_milestone()
	hud.log_line("%s - Skipped to next day milestone." % _clock_stamp())

func _select_build(build_id: String) -> void:
	selected_build_id = build_id
	selected_rotation = 0
	_update_preview()
	var label := _display_name_for_build(build_id)
	hud.log_line("%s - Selected %s. Move cursor over the correct room, left-click to place." % [_clock_stamp(), label])

func _quick_place_build(build_id: String) -> void:
	var room_id := _preferred_room_for_build(build_id)
	if room_id.is_empty():
		hud.log_line("%s - No valid room found for %s." % [_clock_stamp(), _display_name_for_build(build_id)])
		return
	var cell_result := _find_first_empty_cell(room_id, _size_for_build(build_id), 0)
	if not bool(cell_result.get("ok", false)):
		hud.log_line("%s - No open %s tile for %s." % [_clock_stamp(), room_id, _display_name_for_build(build_id)])
		return
	var result := _place_build(room_id, build_id, cell_result.get("cell", Vector2i.ZERO), 0)
	if bool(result.get("ok", false)):
		selected_build_id = ""
		preview_rect.visible = false
	hud.log_line("%s - %s" % [_clock_stamp(), result.get("message", "Placement failed.")])

func _rotate_selected_build() -> void:
	if selected_build_id.is_empty():
		hud.log_line("%s - Select a build item first." % _clock_stamp())
		return
	selected_rotation = (selected_rotation + 90) % 360
	_update_preview()
	hud.log_line("%s - Rotated %s to %d degrees." % [_clock_stamp(), _display_name_for_build(selected_build_id), selected_rotation])

func _cancel_placement() -> void:
	if selected_build_id.is_empty():
		return
	hud.log_line("%s - Canceled %s placement." % [_clock_stamp(), _display_name_for_build(selected_build_id)])
	selected_build_id = ""
	preview_rect.visible = false

func _refresh_hud() -> void:
	hud.set_clock(TimeService.format_minutes(TimeService.current_minutes))
	hud.set_money(GameState.money)
	hud.set_phase(TimeService.current_phase)
	hud.set_stamina(GameState.player_stamina)
	hud.set_active_order_count(OrderService.active_orders.size())
	hud.set_cupcake_stock(_cupcake_stock())
	hud.set_orders_paused(OrderService.orders_paused)

func _starter_ingredients_cost() -> int:
	var total := 0
	for ingredient_id in STARTER_INGREDIENTS:
		total += DataLibrary.get_ingredient_price(ingredient_id, int(STARTER_INGREDIENTS[ingredient_id]))
	return total

func _cupcake_stock() -> int:
	return int(InventoryService.finished.get(CUPCAKE_RECIPE_ID, 0))

func _clock_stamp() -> String:
	return TimeService.format_minutes(TimeService.current_minutes)

func _craft_with_time(recipe_id: String) -> Dictionary:
	var recipe := DataLibrary.get_recipe(recipe_id)
	if recipe.is_empty():
		return {"ok": false, "message": "Missing recipe data: %s." % recipe_id}
	var result := InventoryService.craft_recipe(recipe_id)
	if not bool(result.get("ok", false)):
		return result
	var total_minutes := int(recipe.get("prep_minutes", 0)) + int(recipe.get("cook_minutes", 0)) + int(recipe.get("assembly_minutes", 0))
	TimeService.advance_minutes(max(1, total_minutes))
	return result

func _register_rooms() -> void:
	for room_id in ROOM_SIZES:
		PlacementService.set_room_bounds(room_id, ROOM_ORIGINS[room_id], ROOM_SIZES[room_id])

func _try_place_selected() -> void:
	if selected_build_id.is_empty():
		return
	if hovered_room_id.is_empty():
		hud.log_line("%s - Move cursor over a valid room first." % _clock_stamp())
		return
	var result := _place_build(hovered_room_id, selected_build_id, hovered_cell, selected_rotation)
	hud.log_line("%s - %s" % [_clock_stamp(), result.get("message", "Placement failed.")])
	if not bool(result.get("ok", false)):
		var empty := PlacementService.find_nearest_empty_cell(hovered_room_id, hovered_cell, _size_for_build(selected_build_id), selected_rotation)
		if bool(empty.get("ok", false)):
			hud.log_line("%s - Nearest empty tile: %s." % [_clock_stamp(), empty.get("cell")])
	if bool(result.get("ok", false)):
		selected_build_id = ""
		preview_rect.visible = false

func _place_build(room_id: String, build_id: String, cell: Vector2i, rotation: int) -> Dictionary:
	var size := _size_for_build(build_id)
	var result := PlacementService.place_object(room_id, build_id, cell, size, rotation)
	if not bool(result.get("ok", false)):
		return result
	var instance_id := str(result.get("instance_id", build_id))
	_render_placed_object(room_id, build_id, cell, size, rotation, instance_id)
	return result

func _preferred_room_for_build(build_id: String) -> String:
	if BUILD_PRESETS.has(build_id):
		return str(BUILD_PRESETS[build_id].get("room", ""))
	var placeable := DataLibrary.get_placeable(build_id)
	if not placeable.is_empty():
		var allowed_rooms: Array = placeable.get("allowed_rooms", [])
		if not allowed_rooms.is_empty():
			return str(allowed_rooms[0])
	var machine := DataLibrary.get_machine(build_id)
	if not machine.is_empty():
		var allowed_rooms: Array = machine.get("allowed_rooms", [])
		if not allowed_rooms.is_empty():
			return str(allowed_rooms[0])
	return ""

func _find_first_empty_cell(room_id: String, size: Vector2i, rotation: int) -> Dictionary:
	if not ROOM_SIZES.has(room_id):
		return {"ok": false, "message": "Unknown room: %s." % room_id}
	var room_size: Vector2i = ROOM_SIZES[room_id]
	var footprint := _rotated_size(size, rotation)
	var start_y: int = 2 if room_size.y > 4 else 0
	for y in range(start_y, room_size.y - footprint.y + 1):
		for x in range(1, room_size.x - footprint.x + 1):
			var cell := Vector2i(x, y)
			var check := PlacementService.can_place(room_id, "quick_place_probe", cell, size, rotation)
			if bool(check.get("ok", false)):
				return {"ok": true, "cell": cell}
	for y in range(0, room_size.y - footprint.y + 1):
		for x in range(0, room_size.x - footprint.x + 1):
			var cell := Vector2i(x, y)
			var check := PlacementService.can_place(room_id, "quick_place_probe", cell, size, rotation)
			if bool(check.get("ok", false)):
				return {"ok": true, "cell": cell}
	return {"ok": false, "message": "No free cell in %s." % room_id}

func _render_placed_object(room_id: String, build_id: String, cell: Vector2i, size: Vector2i, rotation: int, instance_id: String) -> void:
	var footprint := _rotated_size(size, rotation)
	var origin: Vector2i = ROOM_ORIGINS.get(room_id, Vector2i.ZERO)
	var rect := ColorRect.new()
	rect.name = instance_id
	rect.position = Vector2(origin + cell) * PlacementService.CELL_SIZE
	rect.size = Vector2(footprint) * PlacementService.CELL_SIZE
	rect.color = BUILD_PRESETS.get(build_id, {}).get("color", Color(0.3, 0.3, 0.3, 0.9))
	rect.mouse_filter = Control.MOUSE_FILTER_STOP
	placed_layer.add_child(rect)
	rect.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_open_interaction(instance_id)
	)
	placed_interactables[instance_id] = {
		"build_id": build_id,
		"room_id": room_id,
		"cell": cell,
		"size": footprint,
		"node": rect
	}
	if build_id == "small_table_two_seat":
		table_dirty_state[instance_id] = {"plates": 2, "crumbs": true}
	var decorated := GeneratedArt.decorate_control(rect, _art_id_for_build(build_id), Vector2i(64, 64), _uses_animated_art(build_id))
	if not decorated:
		var label := Label.new()
		label.text = _display_name_for_build(build_id)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = rect.size
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", Color(0.95, 0.93, 0.86, 1.0))
		rect.add_child(label)

func _update_preview() -> void:
	if selected_build_id.is_empty():
		preview_rect.visible = false
		return
	if hovered_room_id.is_empty():
		preview_rect.visible = false
		return
	var size := _rotated_size(_size_for_build(selected_build_id), selected_rotation)
	var origin: Vector2i = ROOM_ORIGINS.get(hovered_room_id, Vector2i.ZERO)
	preview_rect.position = Vector2(origin + hovered_cell) * PlacementService.CELL_SIZE
	preview_rect.size = Vector2(size) * PlacementService.CELL_SIZE
	var check := PlacementService.can_place(hovered_room_id, selected_build_id, hovered_cell, _size_for_build(selected_build_id), selected_rotation)
	can_place_hovered = bool(check.get("ok", false))
	preview_rect.color = Color(0.2, 0.8, 0.35, 0.35) if can_place_hovered else Color(0.9, 0.2, 0.2, 0.35)
	preview_rect.visible = true

func _size_for_build(build_id: String) -> Vector2i:
	if not DataLibrary.get_placeable(build_id).is_empty():
		return DataLibrary.get_placeable_size(build_id)
	if not DataLibrary.get_machine(build_id).is_empty():
		return DataLibrary.get_machine_size(build_id)
	return Vector2i.ONE

func _display_name_for_build(build_id: String) -> String:
	var placeable := DataLibrary.get_placeable(build_id)
	if not placeable.is_empty():
		return str(placeable.get("name", build_id))
	var machine := DataLibrary.get_machine(build_id)
	if not machine.is_empty():
		return str(machine.get("name", build_id))
	return build_id

func _rotated_size(size: Vector2i, rotation: int) -> Vector2i:
	var normalized := ((rotation % 360) + 360) % 360
	if normalized == 90 or normalized == 270:
		return Vector2i(size.y, size.x)
	return size

func _update_hovered_placement() -> void:
	if selected_build_id.is_empty():
		return
	var mouse_pos := get_viewport().get_mouse_position()
	var new_room := _room_at_world_pos(mouse_pos)
	var new_cell := Vector2i.ZERO
	if not new_room.is_empty():
		var origin: Vector2i = ROOM_ORIGINS[new_room]
		new_cell = Vector2i(floor(mouse_pos.x / PlacementService.CELL_SIZE), floor(mouse_pos.y / PlacementService.CELL_SIZE)) - origin
	if new_room != hovered_room_id or new_cell != hovered_cell:
		hovered_room_id = new_room
		hovered_cell = new_cell
	_update_preview()

func _room_at_world_pos(world_pos: Vector2) -> String:
	var grid_pos := Vector2i(floor(world_pos.x / PlacementService.CELL_SIZE), floor(world_pos.y / PlacementService.CELL_SIZE))
	for room_id in ROOM_SIZES:
		var origin: Vector2i = ROOM_ORIGINS[room_id]
		var size: Vector2i = ROOM_SIZES[room_id]
		if (
			grid_pos.x >= origin.x and
			grid_pos.y >= origin.y and
			grid_pos.x < origin.x + size.x and
			grid_pos.y < origin.y + size.y
		):
			return room_id
	return ""

func _is_hud_click_target() -> bool:
	var hovered := get_viewport().gui_get_hovered_control()
	var node: Node = hovered
	while node != null:
		if node.name == "HUD":
			return true
		node = node.get_parent()
	return false

func _interact_with_nearest() -> void:
	var nearest_id := ""
	var nearest_distance := INF
	var player_center := player.global_position + player.size * 0.5
	for instance_id in placed_interactables:
		var data: Dictionary = placed_interactables[instance_id]
		var node: ColorRect = data.get("node")
		var center := node.global_position + node.size * 0.5
		var distance := player_center.distance_to(center)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_id = instance_id
	if nearest_id.is_empty():
		hud.log_line("%s - Nothing nearby to interact with." % _clock_stamp())
		return
	if nearest_distance > 140.0:
		hud.log_line("%s - Move closer to interact." % _clock_stamp())
		return
	_open_interaction(nearest_id)

func _open_interaction(instance_id: String) -> void:
	active_interaction_id = instance_id
	var data: Dictionary = placed_interactables.get(instance_id, {})
	var build_id := str(data.get("build_id", ""))
	var title: Label = $InteractionPopup/Margin/Stack/Title
	var body: Label = $InteractionPopup/Margin/Stack/Body
	var clean_button: Button = $InteractionPopup/Margin/Stack/CleanButton
	var close_button: Button = $InteractionPopup/Margin/Stack/CloseButton
	title.text = _display_name_for_build(build_id)
	clean_button.visible = build_id == "small_table_two_seat"
	if build_id == "small_table_two_seat":
		var state: Dictionary = table_dirty_state.get(instance_id, {"plates": 0, "crumbs": false})
		body.text = "Table status:\nPlates: %d\nCrumbs: %s\nAction: move plates to trash, then wipe table." % [int(state.get("plates", 0)), "yes" if bool(state.get("crumbs", false)) else "no"]
	else:
		body.text = "Machine status:\nNo detailed interaction implemented yet.\nNext: ingredient input, job queue, output slots."
	interaction_popup.visible = true

func _clean_active_table() -> void:
	if active_interaction_id.is_empty():
		return
	table_dirty_state[active_interaction_id] = {"plates": 0, "crumbs": false}
	hud.log_line("%s - Table cleaned." % _clock_stamp())
	_open_interaction(active_interaction_id)

func _apply_generated_art() -> void:
	var world: Node2D = $World
	art_floor_layer = _replace_art_layer(world, "GeneratedFloorLayer", 5)
	for room_id in ROOM_SIZES:
		GeneratedArt.add_room_floor(art_floor_layer, room_id, ROOM_ORIGINS[room_id], ROOM_SIZES[room_id])
	_fade_room_backdrops()
	GeneratedArt.add_floor_decal(art_floor_layer, Vector2i(4, 10), 5, "SalesQueueMarker")
	GeneratedArt.add_floor_decal(art_floor_layer, Vector2i(36, 15), 7, "WarehouseDeliveryZone")
	GeneratedArt.add_floor_decal(art_floor_layer, Vector2i(25, 14), 6, "OvenHeatClearance")

	art_wall_layer = _replace_art_layer(world, "GeneratedWallLayer", 7)
	_add_room_wall_art()
	_decorate_existing_fixtures()
	_add_demo_actor_art()

func _replace_art_layer(world: Node2D, layer_name: String, target_index: int) -> Node2D:
	var existing := world.get_node_or_null(layer_name)
	if existing != null:
		world.remove_child(existing)
		existing.free()
	var layer := Node2D.new()
	layer.name = layer_name
	world.add_child(layer)
	world.move_child(layer, min(target_index, world.get_child_count() - 1))
	return layer

func _fade_room_backdrops() -> void:
	for path in ["World/SalesRoom", "World/Kitchen", "World/Warehouse"]:
		var rect: ColorRect = get_node_or_null(path)
		if rect == null:
			push_error("Missing room backdrop for generated floor: %s." % path)
			continue
		rect.color = Color(rect.color.r, rect.color.g, rect.color.b, 0.0)

func _add_room_wall_art() -> void:
	var modules := [
		{"cell": Vector2i(2, 2), "row": 0, "col": 0, "name": "SalesWallStraight"},
		{"cell": Vector2i(6, 2), "row": 0, "col": 4, "name": "SalesWallShelves"},
		{"cell": Vector2i(12, 2), "row": 0, "col": 7, "name": "SalesPassCounter"},
		{"cell": Vector2i(16, 2), "row": 1, "col": 0, "name": "KitchenWallStraight"},
		{"cell": Vector2i(22, 2), "row": 1, "col": 6, "name": "KitchenWallHooks"},
		{"cell": Vector2i(28, 2), "row": 1, "col": 3, "name": "KitchenDoor"},
		{"cell": Vector2i(31, 2), "row": 2, "col": 0, "name": "WarehouseWallStraight"},
		{"cell": Vector2i(34, 2), "row": 2, "col": 5, "name": "WarehouseBoard"},
		{"cell": Vector2i(37, 2), "row": 2, "col": 3, "name": "WarehouseDoor"}
	]
	for module in modules:
		GeneratedArt.add_wall_module(
			art_wall_layer,
			module.get("cell", Vector2i.ZERO),
			int(module.get("row", 0)),
			int(module.get("col", 0)),
			str(module.get("name", "WallModule"))
		)

func _decorate_existing_fixtures() -> void:
	var fixtures := {
		"World/SalesRoomFixtures/CashierStand": {"id": "service_counter_basic", "animated": false},
		"World/SalesRoomFixtures/DisplayShelf": {"id": "display_case_basic", "animated": true},
		"World/SalesRoomFixtures/TableA": {"id": "small_table_two_seat", "animated": false},
		"World/SalesRoomFixtures/TableB": {"id": "small_table_two_seat", "animated": false},
		"World/KitchenFixtures/PrepCounter": {"id": "prep_counter_basic", "animated": true},
		"World/KitchenFixtures/Oven": {"id": "oven_basic", "animated": true},
		"World/KitchenFixtures/MixerMachine": {"id": "mixer", "animated": false},
		"World/KitchenFixtures/PackingMachine": {"id": "packing_station", "animated": false},
		"World/WarehouseFixtures/RackA": {"id": "warehouse_shelf_basic", "animated": false},
		"World/WarehouseFixtures/RackB": {"id": "warehouse_shelf_basic", "animated": false},
		"World/WarehouseFixtures/ReceivingZone": {"id": "tablet_station", "animated": false}
	}
	for path in fixtures:
		var rect: ColorRect = get_node_or_null(path)
		if rect == null:
			push_error("Missing fixture for generated art: %s." % path)
			continue
		var data: Dictionary = fixtures[path]
		GeneratedArt.decorate_control(rect, str(data.get("id", "")), Vector2i(64, 64), bool(data.get("animated", false)))
	_hide_graybox_fixture_labels()

func _hide_graybox_fixture_labels() -> void:
	for label in get_tree().get_nodes_in_group("generated_art_hide"):
		if label is CanvasItem:
			(label as CanvasItem).visible = false
	for node in $World.find_children("*Label", "Label", true, false):
		var label := node as Label
		if label != null and label.name != "SalesRoomLabel" and label.name != "KitchenLabel" and label.name != "WarehouseLabel":
			label.visible = false

func _add_demo_actor_art() -> void:
	art_actor_layer = _replace_art_layer($World, "GeneratedActorLayer", $World.get_child_count())
	GeneratedArt.add_worker(art_actor_layer, "baker", Vector2(656, 572), "baker_task")
	GeneratedArt.add_worker(art_actor_layer, "cashier", Vector2(260, 292), "cashier_task")
	GeneratedArt.add_worker(art_actor_layer, "runner", Vector2(1060, 424), "runner_task")
	GeneratedArt.add_worker(art_actor_layer, "cleaner", Vector2(370, 520), "cleaner_task")
	var customer := Node2D.new()
	customer.name = "GeneratedCustomerTest"
	customer.position = Vector2(140, 344)
	art_actor_layer.add_child(customer)
	GeneratedArt.decorate_customer(customer)

func _art_id_for_build(build_id: String) -> String:
	if build_id == "small_table_two_seat":
		return "small_table_two_seat"
	if build_id == "warehouse_shelf_basic":
		return "warehouse_shelf_basic"
	if build_id == "oven_basic":
		return "oven_basic"
	return build_id

func _uses_animated_art(build_id: String) -> bool:
	return build_id == "oven_basic" or build_id == "prep_counter_basic" or build_id == "display_case_basic"
