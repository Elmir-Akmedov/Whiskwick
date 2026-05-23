@tool
extends Node2D
# ─────────────────────────────────────────────────────────────────────────────
# Main.gd  –  Phase 1 + 2 upgrade
#
# Phase 1: pixel art sprites wired through updated GeneratedArtPresenter.
# Phase 2: full gameplay loop — buy → cook → serve → end day report.
# ─────────────────────────────────────────────────────────────────────────────

const GeneratedArt := preload("res://scripts/visual/GeneratedArtPresenter.gd")

# ── Recipe / ingredient constants ────────────────────────────────────────────
const CUPCAKE_RECIPE_ID        := "cupcake_batch"
const CUPCAKE_BATTER_RECIPE_ID := "cupcake_batter"
const STARTER_INGREDIENTS := {
	"flour": 2,
	"egg":   2,
	"sugar": 2,
	"milk":  2
}
const BUY_STARTER_STAMINA_COST := 4
const COOK_STAMINA_COST        := 12

# ── Room layout (grid cells) ──────────────────────────────────────────────────
const ROOM_ORIGINS := {
	"sales_room": Vector2i(1, 2),
	"kitchen":    Vector2i(15, 2),
	"warehouse":  Vector2i(30, 2)
}
const ROOM_SIZES := {
	"sales_room": Vector2i(14, 19),
	"kitchen":    Vector2i(15, 19),
	"warehouse":  Vector2i(9, 19)
}

# ── Build presets for quick-place ────────────────────────────────────────────
const BUILD_PRESETS := {
	"small_table_two_seat":  {"room": "sales_room", "color": Color(0.27, 0.45, 0.32, 0.0)},
	"oven_basic":            {"room": "kitchen",    "color": Color(0.18, 0.18, 0.18, 0.0)},
	"warehouse_shelf_basic": {"room": "warehouse",  "color": Color(0.21, 0.28, 0.38, 0.0)}
}

# ── Node refs ────────────────────────────────────────────────────────────────
@onready var hud: CanvasLayer                  = $HUD
@onready var placed_layer: Node2D              = $World/PlacedObjects
@onready var preview_rect: ColorRect           = $World/PlacementPreview
@onready var player: ColorRect                 = $World/Player
@onready var interaction_popup: PanelContainer = $InteractionPopup

# ── Placement state ───────────────────────────────────────────────────────────
var selected_build_id:  String  = ""
var selected_rotation:  int     = 0
var hovered_room_id:    String  = ""
var hovered_cell:       Vector2i = Vector2i.ZERO
var can_place_hovered:  bool    = false

# ── Placed object tracking ────────────────────────────────────────────────────
var placed_interactables: Dictionary = {}
var active_interaction_id: String   = ""
var table_dirty_state: Dictionary   = {}

# ── Art layers ────────────────────────────────────────────────────────────────
var art_floor_layer: Node2D = null
var art_wall_layer:  Node2D = null
var art_actor_layer: Node2D = null

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	if Engine.is_editor_hint():
		_apply_generated_art()
		return

	_attach_scene_switcher()
	_register_rooms()

	# ── Service signals
	TimeService.time_changed.connect(_on_time_changed)
	TimeService.phase_changed.connect(_on_phase_changed)
	GameState.money_changed.connect(_on_money_changed)
	GameState.stamina_changed.connect(_on_stamina_changed)
	InventoryService.inventory_changed.connect(_on_inventory_changed)
	OrderService.order_created.connect(_on_order_created)
	OrderService.order_completed.connect(_on_order_completed)
	OrderService.orders_paused_changed.connect(_on_orders_paused_changed)

	# ── HUD signals
	hud.buy_starter_ingredients_requested.connect(_on_buy_starter_ingredients_requested)
	hud.cook_cupcakes_requested.connect(_on_cook_cupcakes_requested)
	hud.complete_first_order_requested.connect(_on_complete_first_order_requested)
	hud.pause_orders_toggled.connect(_on_pause_orders_toggled)
	hud.skip_time_requested.connect(_on_skip_time_requested)
	hud.place_table_requested.connect(func() -> void: _quick_place_build("small_table_two_seat"))
	hud.place_oven_requested.connect(func() -> void: _quick_place_build("oven_basic"))
	hud.place_rack_requested.connect(func() -> void: _quick_place_build("warehouse_shelf_basic"))
	hud.rotate_placement_requested.connect(_rotate_selected_build)

	# ── Interaction popup buttons
	$InteractionPopup/Margin/Stack/CleanButton.pressed.connect(_clean_active_table)
	$InteractionPopup/Margin/Stack/CloseButton.pressed.connect(func() -> void: interaction_popup.visible = false)

	# ── Bootstrap game
	GameState.start_new_game()
	InventoryService.reset()
	TimeService.reset_day()
	OrderService.reset_day()

	_apply_generated_art()
	_refresh_hud()

	# Try to load a previous save so the player keeps their progress
	var load_result := SaveManager.load_game()
	if bool(load_result.get("ok", false)):
		_refresh_hud()
		hud.log_line("Save loaded. Welcome back!")
	else:
		hud.log_line("07:00 — Morning prep. Buy ingredients and cook cupcakes!")

# ─────────────────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	TimeService.tick(delta)
	OrderService.tick(delta)
	_update_hovered_placement()

# ─────────────────────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	# E key → interact with nearest object
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

# ─────────────────────────────────────────────────────────────────────────────
# TIME / PHASE CALLBACKS
# ─────────────────────────────────────────────────────────────────────────────

func _on_time_changed(minutes: int) -> void:
	hud.set_clock(TimeService.format_minutes(minutes))

func _on_phase_changed(phase: String) -> void:
	hud.set_phase(phase)
	match phase:
		TimeService.PHASE_OPEN:
			hud.log_line("10:00 — Shop opened! Customers are arriving.")
			CustomerManager.start_day()
		TimeService.PHASE_CLOSED:
			hud.log_line("19:00 — Shop closed. Review the day's results.")
			_end_day()
		TimeService.PHASE_EXHAUSTED:
			hud.log_line("22:00 — You're exhausted. Actions cost extra stamina.")

func _end_day() -> void:
	var stats := CustomerManager.end_day()
	GameState.daily_stats = stats
	SaveManager.save_game()
	# Give player a moment before transitioning
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/screens/DaySummaryScreen.tscn")

# ─────────────────────────────────────────────────────────────────────────────
# GAMESTATE CALLBACKS
# ─────────────────────────────────────────────────────────────────────────────

func _on_money_changed(value: int) -> void:
	hud.set_money(value)

func _on_stamina_changed(value: int) -> void:
	hud.set_stamina(value)

func _on_inventory_changed() -> void:
	hud.set_cupcake_stock(_cupcake_stock())

# ─────────────────────────────────────────────────────────────────────────────
# ORDER CALLBACKS
# ─────────────────────────────────────────────────────────────────────────────

func _on_order_created(order: Dictionary) -> void:
	hud.set_active_order_count(OrderService.active_orders.size())
	hud.log_line("New order: %s x%s" % [order.get("recipe_id", "unknown"), order.get("quantity", 1)])

func _on_order_completed(order: Dictionary) -> void:
	hud.set_active_order_count(OrderService.active_orders.size())
	hud.log_line("%s — Completed order #%s." % [_clock_stamp(), order.get("id", "?")])
	# Spawn coin FX near the player
	if art_actor_layer != null:
		GeneratedArt.spawn_coin_fx(art_actor_layer, player.global_position + Vector2(0, -24), 12)

func _on_orders_paused_changed(paused: bool) -> void:
	hud.set_orders_paused(paused)
	hud.log_line("Orders paused." if paused else "Orders resumed.")

# ─────────────────────────────────────────────────────────────────────────────
# HUD ACTION HANDLERS
# ─────────────────────────────────────────────────────────────────────────────

func _on_buy_starter_ingredients_requested() -> void:
	var cost := _starter_ingredients_cost()
	if not GameState.can_spend_money(cost):
		hud.log_line("%s — Need $%d for starter ingredients." % [_clock_stamp(), cost])
		return
	if not GameState.spend_stamina(BUY_STARTER_STAMINA_COST):
		hud.log_line("%s — Not enough stamina to shop." % _clock_stamp())
		return
	for ingredient_id in STARTER_INGREDIENTS:
		var result := InventoryService.buy_ingredient(ingredient_id, int(STARTER_INGREDIENTS[ingredient_id]))
		if not bool(result.get("ok", false)):
			hud.log_line("%s — %s" % [_clock_stamp(), result.get("message", "Could not buy.")])
			return
	hud.log_line("%s — Bought starter ingredients for $%d." % [_clock_stamp(), cost])

func _on_cook_cupcakes_requested() -> void:
	var stamina_cost := COOK_STAMINA_COST
	if TimeService.current_phase == TimeService.PHASE_EXHAUSTED:
		stamina_cost *= 2
	if not GameState.spend_stamina(stamina_cost):
		hud.log_line("%s — Not enough stamina to cook." % _clock_stamp())
		return

	var batter_result := _craft_with_time(CUPCAKE_BATTER_RECIPE_ID)
	if not bool(batter_result.get("ok", false)):
		GameState.restore_stamina(stamina_cost)
		hud.log_line("%s — %s" % [_clock_stamp(), batter_result.get("message", "Could not make batter.")])
		return

	var cupcake_result := _craft_with_time(CUPCAKE_RECIPE_ID)
	if not bool(cupcake_result.get("ok", false)):
		hud.log_line("%s — %s" % [_clock_stamp(), cupcake_result.get("message", "Could not bake cupcakes.")])
		return

	hud.log_line("%s — Baked %s cupcakes!" % [_clock_stamp(), cupcake_result.get("amount", 0)])

	# Spawn steam FX over the oven fixture if present
	var oven_node: Node = get_node_or_null("World/KitchenFixtures/Oven")
	if oven_node != null and art_actor_layer != null:
		GeneratedArt.spawn_sparkle_fx(art_actor_layer, oven_node.global_position + Vector2(32, 0))

func _on_complete_first_order_requested() -> void:
	if OrderService.active_orders.is_empty():
		hud.log_line("%s — No active orders." % _clock_stamp())
		return
	var order: Dictionary = OrderService.active_orders[0]
	var recipe_id := str(order.get("recipe_id", CUPCAKE_RECIPE_ID))
	var quantity  := int(order.get("quantity", 1))
	var cost      := {recipe_id: quantity}

	if not InventoryService.has_items("finished", cost):
		hud.log_line("%s — Need %d %s in stock." % [_clock_stamp(), quantity, recipe_id])
		return
	if not InventoryService.consume_items("finished", cost):
		hud.log_line("%s — Stock changed before packing." % _clock_stamp())
		return
	if not OrderService.complete_order(int(order.get("id", 0))):
		InventoryService.add_item("finished", recipe_id, quantity)
		hud.log_line("%s — Order could not be completed." % _clock_stamp())

func _on_pause_orders_toggled() -> void:
	OrderService.set_orders_paused(not OrderService.orders_paused)

func _on_skip_time_requested() -> void:
	TimeService.skip_to_next_milestone()
	hud.log_line("%s — Skipped to next milestone." % _clock_stamp())

# ─────────────────────────────────────────────────────────────────────────────
# PLACEMENT SYSTEM
# ─────────────────────────────────────────────────────────────────────────────

func _select_build(build_id: String) -> void:
	selected_build_id = build_id
	selected_rotation = 0
	_update_preview()
	hud.log_line("%s — Selected %s. Click to place." % [_clock_stamp(), _display_name_for_build(build_id)])

func _quick_place_build(build_id: String) -> void:
	var room_id := _preferred_room_for_build(build_id)
	if room_id.is_empty():
		hud.log_line("%s — No room for %s." % [_clock_stamp(), _display_name_for_build(build_id)])
		return
	var cell_result := _find_first_empty_cell(room_id, _size_for_build(build_id), 0)
	if not bool(cell_result.get("ok", false)):
		hud.log_line("%s — No space in %s." % [_clock_stamp(), room_id])
		return
	var result := _place_build(room_id, build_id, cell_result.get("cell", Vector2i.ZERO), 0)
	if bool(result.get("ok", false)):
		selected_build_id = ""
		preview_rect.visible = false
	hud.log_line("%s — %s" % [_clock_stamp(), result.get("message", "Placement failed.")])

func _rotate_selected_build() -> void:
	if selected_build_id.is_empty():
		hud.log_line("%s — Select an item first." % _clock_stamp())
		return
	selected_rotation = (selected_rotation + 90) % 360
	_update_preview()
	hud.log_line("%s — Rotated to %d°." % [_clock_stamp(), selected_rotation])

func _cancel_placement() -> void:
	if selected_build_id.is_empty():
		return
	hud.log_line("%s — Cancelled." % _clock_stamp())
	selected_build_id = ""
	preview_rect.visible = false

func _try_place_selected() -> void:
	if selected_build_id.is_empty() or hovered_room_id.is_empty():
		return
	var result := _place_build(hovered_room_id, selected_build_id, hovered_cell, selected_rotation)
	hud.log_line("%s — %s" % [_clock_stamp(), result.get("message", "Placement failed.")])
	if bool(result.get("ok", false)):
		selected_build_id = ""
		preview_rect.visible = false

func _place_build(room_id: String, build_id: String, cell: Vector2i, rotation: int) -> Dictionary:
	var size   := _size_for_build(build_id)
	var result := PlacementService.place_object(room_id, build_id, cell, size, rotation)
	if not bool(result.get("ok", false)):
		return result
	var instance_id := str(result.get("instance_id", build_id))
	_render_placed_object(room_id, build_id, cell, size, rotation, instance_id)
	return result

func _render_placed_object(room_id: String, build_id: String, cell: Vector2i, size: Vector2i, rotation: int, instance_id: String) -> void:
	var footprint := _rotated_size(size, rotation)
	var origin: Vector2i = ROOM_ORIGINS.get(room_id, Vector2i.ZERO)

	var rect := ColorRect.new()
	rect.name  = instance_id
	rect.position = Vector2(origin + cell) * PlacementService.CELL_SIZE
	rect.size  = Vector2(footprint) * PlacementService.CELL_SIZE
	# Transparent so the sprite shows through
	rect.color = Color(0.0, 0.0, 0.0, 0.0)
	rect.mouse_filter = Control.MOUSE_FILTER_STOP
	placed_layer.add_child(rect)

	rect.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_open_interaction(instance_id)
	)

	placed_interactables[instance_id] = {
		"build_id": build_id,
		"room_id":  room_id,
		"cell":     cell,
		"size":     footprint,
		"node":     rect
	}
	if build_id == "small_table_two_seat":
		table_dirty_state[instance_id] = {"plates": 2, "crumbs": true}

	# ── Decorate with pixel art sprite
	var is_animated := build_id in ["oven_basic", "prep_counter_basic", "display_case_basic"]
	var decorated   := GeneratedArt.decorate_control(rect, _art_id_for_build(build_id), Vector2i(64, 64), is_animated)
	if not decorated:
		var label := Label.new()
		label.text = _display_name_for_build(build_id)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		label.size = rect.size
		label.add_theme_font_size_override("font_size", 11)
		label.add_theme_color_override("font_color", Color(0.95, 0.93, 0.86))
		rect.add_child(label)

# ─────────────────────────────────────────────────────────────────────────────
# PREVIEW / HOVER
# ─────────────────────────────────────────────────────────────────────────────

func _update_preview() -> void:
	if selected_build_id.is_empty() or hovered_room_id.is_empty():
		preview_rect.visible = false
		return
	var size   := _rotated_size(_size_for_build(selected_build_id), selected_rotation)
	var origin: Vector2i = ROOM_ORIGINS.get(hovered_room_id, Vector2i.ZERO)
	preview_rect.position = Vector2(origin + hovered_cell) * PlacementService.CELL_SIZE
	preview_rect.size     = Vector2(size) * PlacementService.CELL_SIZE
	var check  := PlacementService.can_place(hovered_room_id, selected_build_id, hovered_cell, _size_for_build(selected_build_id), selected_rotation)
	can_place_hovered     = bool(check.get("ok", false))
	preview_rect.color    = Color(0.2, 0.8, 0.35, 0.35) if can_place_hovered else Color(0.9, 0.2, 0.2, 0.35)
	preview_rect.visible  = true

func _update_hovered_placement() -> void:
	if selected_build_id.is_empty():
		return
	var mouse_pos := get_viewport().get_mouse_position()
	var new_room  := _room_at_world_pos(mouse_pos)
	var new_cell  := Vector2i.ZERO
	if not new_room.is_empty():
		var origin: Vector2i = ROOM_ORIGINS[new_room]
		new_cell = Vector2i(int(floor(mouse_pos.x / PlacementService.CELL_SIZE)), int(floor(mouse_pos.y / PlacementService.CELL_SIZE))) - origin
	if new_room != hovered_room_id or new_cell != hovered_cell:
		hovered_room_id = new_room
		hovered_cell    = new_cell
	_update_preview()

# ─────────────────────────────────────────────────────────────────────────────
# INTERACTION
# ─────────────────────────────────────────────────────────────────────────────

func _interact_with_nearest() -> void:
	var nearest_id  := ""
	var nearest_dist := INF
	var player_center := player.global_position + player.size * 0.5
	for instance_id in placed_interactables:
		var data: Dictionary = placed_interactables[instance_id]
		var node: ColorRect  = data.get("node")
		var center := node.global_position + node.size * 0.5
		var dist   := player_center.distance_to(center)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_id   = instance_id
	if nearest_id.is_empty():
		hud.log_line("%s — Nothing nearby." % _clock_stamp())
		return
	if nearest_dist > 140.0:
		hud.log_line("%s — Move closer (press E)." % _clock_stamp())
		return
	_open_interaction(nearest_id)

func _open_interaction(instance_id: String) -> void:
	active_interaction_id = instance_id
	var data: Dictionary = placed_interactables.get(instance_id, {})
	var build_id := str(data.get("build_id", ""))
	var title: Label = $InteractionPopup/Margin/Stack/Title
	var body:  Label = $InteractionPopup/Margin/Stack/Body
	var clean_btn: Button = $InteractionPopup/Margin/Stack/CleanButton
	title.text = _display_name_for_build(build_id)
	clean_btn.visible = (build_id == "small_table_two_seat")
	if build_id == "small_table_two_seat":
		var state: Dictionary = table_dirty_state.get(instance_id, {"plates": 0, "crumbs": false})
		body.text = "Plates: %d\nCrumbs: %s" % [int(state.get("plates", 0)), "Yes" if bool(state.get("crumbs", false)) else "No"]
	else:
		body.text = "No interaction implemented yet."
	interaction_popup.visible = true

func _clean_active_table() -> void:
	if active_interaction_id.is_empty():
		return
	table_dirty_state[active_interaction_id] = {"plates": 0, "crumbs": false}
	hud.log_line("%s — Table cleaned." % _clock_stamp())
	_open_interaction(active_interaction_id)

# ─────────────────────────────────────────────────────────────────────────────
# ART SETUP
# ─────────────────────────────────────────────────────────────────────────────

func _apply_generated_art() -> void:
	var world: Node2D = $World

	# Floor tiles
	art_floor_layer = _replace_art_layer(world, "GeneratedFloorLayer", 5)
	for room_id in ROOM_SIZES:
		GeneratedArt.add_room_floor(art_floor_layer, room_id, ROOM_ORIGINS[room_id], ROOM_SIZES[room_id])
	_fade_room_backdrops()

	# Floor decals
	GeneratedArt.add_floor_decal(art_floor_layer, Vector2i(4, 10),  5, "SalesQueueMarker")
	GeneratedArt.add_floor_decal(art_floor_layer, Vector2i(36, 15), 7, "WarehouseDeliveryZone")
	GeneratedArt.add_floor_decal(art_floor_layer, Vector2i(25, 14), 6, "OvenHeatClearance")

	# Wall modules
	art_wall_layer = _replace_art_layer(world, "GeneratedWallLayer", 7)
	_add_room_wall_art()

	# Pre-placed fixture sprites
	_decorate_existing_fixtures()

	# Demo workers + customer using pixel art sprites
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
			continue
		rect.color = Color(rect.color.r, rect.color.g, rect.color.b, 0.0)

func _add_room_wall_art() -> void:
	var modules := [
		{"cell": Vector2i(2,  2), "row": 0, "col": 0, "name": "SalesWallStraight"},
		{"cell": Vector2i(6,  2), "row": 0, "col": 4, "name": "SalesWallShelves"},
		{"cell": Vector2i(12, 2), "row": 0, "col": 7, "name": "SalesPassCounter"},
		{"cell": Vector2i(16, 2), "row": 1, "col": 0, "name": "KitchenWallStraight"},
		{"cell": Vector2i(22, 2), "row": 1, "col": 6, "name": "KitchenWallHooks"},
		{"cell": Vector2i(28, 2), "row": 1, "col": 3, "name": "KitchenDoor"},
		{"cell": Vector2i(31, 2), "row": 2, "col": 0, "name": "WarehouseWallStraight"},
		{"cell": Vector2i(34, 2), "row": 2, "col": 5, "name": "WarehouseBoard"},
		{"cell": Vector2i(37, 2), "row": 2, "col": 3, "name": "WarehouseDoor"}
	]
	for module in modules:
		GeneratedArt.add_wall_module(art_wall_layer, module.get("cell", Vector2i.ZERO),
			int(module.get("row", 0)), int(module.get("col", 0)), str(module.get("name", "")))

func _decorate_existing_fixtures() -> void:
	var fixtures := {
		"World/SalesRoomFixtures/CashierStand":  {"id": "cashier_stand",        "animated": false},
		"World/SalesRoomFixtures/DisplayShelf":  {"id": "display_case_basic",   "animated": true},
		"World/SalesRoomFixtures/TableA":        {"id": "small_table_two_seat", "animated": false},
		"World/SalesRoomFixtures/TableB":        {"id": "small_table_two_seat", "animated": false},
		"World/KitchenFixtures/PrepCounter":     {"id": "prep_counter_basic",   "animated": true},
		"World/KitchenFixtures/Oven":            {"id": "oven_basic",           "animated": true},
		"World/KitchenFixtures/MixerMachine":    {"id": "mixer",                "animated": false},
		"World/KitchenFixtures/PackingMachine":  {"id": "packing_station",      "animated": false},
		"World/WarehouseFixtures/RackA":         {"id": "warehouse_shelf_basic","animated": false},
		"World/WarehouseFixtures/RackB":         {"id": "warehouse_shelf_basic","animated": false},
		"World/WarehouseFixtures/ReceivingZone": {"id": "tablet_station",       "animated": false}
	}
	for path in fixtures:
		var node: ColorRect = get_node_or_null(path)
		if node == null:
			push_warning("GeneratedArtPresenter: missing fixture: %s" % path)
			continue
		var data: Dictionary = fixtures[path]
		GeneratedArt.decorate_control(node, str(data.get("id", "")), Vector2i(64, 64), bool(data.get("animated", false)))
	_hide_graybox_fixture_labels()

func _hide_graybox_fixture_labels() -> void:
	for label in get_tree().get_nodes_in_group("generated_art_hide"):
		if label is CanvasItem:
			(label as CanvasItem).visible = false
	for node in $World.find_children("*Label", "Label", true, false):
		var label := node as Label
		if label != null and label.name not in ["SalesRoomLabel", "KitchenLabel", "WarehouseLabel"]:
			label.visible = false

func _add_demo_actor_art() -> void:
	art_actor_layer = _replace_art_layer($World, "GeneratedActorLayer", $World.get_child_count())
	GeneratedArt.add_worker(art_actor_layer, "baker",   Vector2(656, 572), "baker_idle")
	GeneratedArt.add_worker(art_actor_layer, "cashier", Vector2(260, 292), "cashier_idle")
	GeneratedArt.add_worker(art_actor_layer, "runner",  Vector2(1060, 424), "runner_idle")
	GeneratedArt.add_worker(art_actor_layer, "cleaner", Vector2(370, 520), "cleaner_idle")
	# Demo customer
	var customer_node := Node2D.new()
	customer_node.name = "GeneratedCustomerTest"
	customer_node.position = Vector2(140, 344)
	art_actor_layer.add_child(customer_node)
	GeneratedArt.decorate_customer(customer_node)

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

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
		return {"ok": false, "message": "Missing recipe: %s." % recipe_id}
	var result := InventoryService.craft_recipe(recipe_id)
	if not bool(result.get("ok", false)):
		return result
	var total_minutes := int(recipe.get("prep_minutes", 0)) + int(recipe.get("cook_minutes", 0)) + int(recipe.get("assembly_minutes", 0))
	TimeService.advance_minutes(max(1, total_minutes))
	return result

func _register_rooms() -> void:
	for room_id in ROOM_SIZES:
		PlacementService.set_room_bounds(room_id, ROOM_ORIGINS[room_id], ROOM_SIZES[room_id])

func _preferred_room_for_build(build_id: String) -> String:
	if BUILD_PRESETS.has(build_id):
		return str(BUILD_PRESETS[build_id].get("room", ""))
	var placeable := DataLibrary.get_placeable(build_id)
	if not placeable.is_empty():
		var allowed: Array = placeable.get("allowed_rooms", [])
		if not allowed.is_empty():
			return str(allowed[0])
	var machine := DataLibrary.get_machine(build_id)
	if not machine.is_empty():
		var allowed: Array = machine.get("allowed_rooms", [])
		if not allowed.is_empty():
			return str(allowed[0])
	return ""

func _find_first_empty_cell(room_id: String, size: Vector2i, rotation: int) -> Dictionary:
	if not ROOM_SIZES.has(room_id):
		return {"ok": false, "message": "Unknown room: %s." % room_id}
	var room_size: Vector2i = ROOM_SIZES[room_id]
	var footprint := _rotated_size(size, rotation)
	for y in range(2, room_size.y - footprint.y + 1):
		for x in range(1, room_size.x - footprint.x + 1):
			var cell := Vector2i(x, y)
			if bool(PlacementService.can_place(room_id, "quick_probe", cell, size, rotation).get("ok", false)):
				return {"ok": true, "cell": cell}
	for y in range(0, room_size.y - footprint.y + 1):
		for x in range(0, room_size.x - footprint.x + 1):
			var cell := Vector2i(x, y)
			if bool(PlacementService.can_place(room_id, "quick_probe", cell, size, rotation).get("ok", false)):
				return {"ok": true, "cell": cell}
	return {"ok": false, "message": "No free cell in %s." % room_id}

func _size_for_build(build_id: String) -> Vector2i:
	if not DataLibrary.get_placeable(build_id).is_empty():
		return DataLibrary.get_placeable_size(build_id)
	if not DataLibrary.get_machine(build_id).is_empty():
		return DataLibrary.get_machine_size(build_id)
	return Vector2i.ONE

func _display_name_for_build(build_id: String) -> String:
	var p := DataLibrary.get_placeable(build_id)
	if not p.is_empty():
		return str(p.get("name", build_id))
	var m := DataLibrary.get_machine(build_id)
	if not m.is_empty():
		return str(m.get("name", build_id))
	return build_id

func _art_id_for_build(build_id: String) -> String:
	return build_id

func _rotated_size(size: Vector2i, rotation: int) -> Vector2i:
	var norm := ((rotation % 360) + 360) % 360
	if norm == 90 or norm == 270:
		return Vector2i(size.y, size.x)
	return size

func _room_at_world_pos(world_pos: Vector2) -> String:
	var grid_pos := Vector2i(int(floor(world_pos.x / PlacementService.CELL_SIZE)), int(floor(world_pos.y / PlacementService.CELL_SIZE)))
	for room_id in ROOM_SIZES:
		var origin: Vector2i = ROOM_ORIGINS[room_id]
		var rsize:  Vector2i = ROOM_SIZES[room_id]
		if grid_pos.x >= origin.x and grid_pos.y >= origin.y and grid_pos.x < origin.x + rsize.x and grid_pos.y < origin.y + rsize.y:
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

func _attach_scene_switcher() -> void:
	var switcher_scene := load("res://scripts/ui/SceneSwitcher.gd")
	if switcher_scene == null:
		return
	var switcher := CanvasLayer.new()
	switcher.set_script(switcher_scene)
	add_child(switcher)
