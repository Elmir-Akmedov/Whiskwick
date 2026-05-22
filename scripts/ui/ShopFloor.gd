extends Node2D
# ─────────────────────────────────────────────────────────────────────────────
# ShopFloor.gd  –  Phase 2 upgrade
# Full active-day loop: customers arrive, player taps dish buttons, serves,
# patience bars update, day ends automatically at 19:00.
# ─────────────────────────────────────────────────────────────────────────────

const MAX_QUEUE_SLOTS: int = 3

@onready var coins_label:      Label         = $UI/TopBar/Row/CoinsLabel
@onready var xp_label:         Label         = $UI/TopBar/Row/XPLabel
@onready var reputation_label: Label         = $UI/TopBar/Row/ReputationLabel
@onready var day_label:        Label         = $UI/TopBar/Row/DayLabel
@onready var queue_slots: Array[PanelContainer] = [
	$UI/QueueArea/QueueStack/Slot1,
	$UI/QueueArea/QueueStack/Slot2,
	$UI/QueueArea/QueueStack/Slot3
]
@onready var dish_buttons_root: VBoxContainer = $UI/DishArea/Margin/Scroll/DishStack
@onready var end_day_button:    Button        = $UI/EndDayButton
@onready var open_popup:        Label         = $UI/OpenPopup
@onready var status_label:      Label         = $UI/StatusLabel

var _dish_buttons:    Dictionary = {}
var _day_ended:       bool       = false
var _warned_empty:    bool       = false

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	CustomerManager.start_day()
	_show_open_popup()
	_build_dish_buttons()
	_refresh_top_bar()
	_refresh_queue_ui()
	end_day_button.pressed.connect(_on_end_day_pressed)

	if MenuManager.get_active_menu().is_empty():
		_warned_empty = true
		status_label.text = "Add items to your menu first!"
	else:
		status_label.text = "Shop is open — serve your customers!"

func _process(_delta: float) -> void:
	_refresh_top_bar()
	_refresh_queue_ui()
	_refresh_dish_button_states()

# ─────────────────────────────────────────────────────────────────────────────
# UI BUILDERS
# ─────────────────────────────────────────────────────────────────────────────

func _show_open_popup() -> void:
	open_popup.visible = true
	await get_tree().create_timer(2.0).timeout
	open_popup.visible = false

func _build_dish_buttons() -> void:
	_dish_buttons.clear()
	for child in dish_buttons_root.get_children():
		child.queue_free()

	var active_menu: Array = MenuManager.get_active_menu()
	for recipe_item in active_menu:
		var recipe_name: String = str(recipe_item)
		var recipe: Dictionary  = RecipeManager.get_recipe(recipe_name)
		if recipe.is_empty():
			continue

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 48)
		btn.text = "%s  (%.1fs — $%d)" % [
			recipe_name,
			float(recipe.get("prep_time", 0.0)),
			MenuManager.get_price(recipe_name)
		]
		btn.pressed.connect(func() -> void: _on_dish_pressed(recipe_name))
		dish_buttons_root.add_child(btn)
		_dish_buttons[recipe_name] = btn

# ─────────────────────────────────────────────────────────────────────────────
# REFRESH HELPERS
# ─────────────────────────────────────────────────────────────────────────────

func _refresh_top_bar() -> void:
	coins_label.text      = "Coins: %d" % GameState.coins
	xp_label.text         = "XP: %d"    % GameState.xp
	reputation_label.text = "Rep: %.1f" % GameState.reputation
	day_label.text        = "Day: %d"   % GameState.current_day

func _refresh_queue_ui() -> void:
	for idx in range(MAX_QUEUE_SLOTS):
		var slot: PanelContainer = queue_slots[idx]
		var name_lbl:    Label       = slot.get_node("Margin/Stack/Name")    as Label
		var order_lbl:   Label       = slot.get_node("Margin/Stack/Order")   as Label
		var patience_bar: ProgressBar = slot.get_node("Margin/Stack/Patience") as ProgressBar

		if idx >= CustomerManager.active_customers.size():
			name_lbl.text    = "Waiting…"
			order_lbl.text   = "Order: —"
			patience_bar.value = 0.0
			patience_bar.modulate = Color.WHITE
			continue

		var customer: Customer = CustomerManager.active_customers[idx]
		if not is_instance_valid(customer):
			continue

		var sat: float = customer.get_satisfaction()
		name_lbl.text    = customer.customer_name
		order_lbl.text   = "Wants: %s" % customer.order
		patience_bar.value = sat * 100.0

		# Colour patience bar green → yellow → red
		if sat > 0.6:
			patience_bar.modulate = Color(0.3, 0.9, 0.4)
		elif sat > 0.3:
			patience_bar.modulate = Color(1.0, 0.85, 0.1)
		else:
			patience_bar.modulate = Color(0.95, 0.25, 0.25)

func _refresh_dish_button_states() -> void:
	for recipe_name in _dish_buttons.keys():
		var btn: Button = _dish_buttons[recipe_name]
		if btn == null:
			continue
		btn.disabled = _day_ended or not RecipeManager.can_make(str(recipe_name))

# ─────────────────────────────────────────────────────────────────────────────
# DISH HANDLING
# ─────────────────────────────────────────────────────────────────────────────

func _on_dish_pressed(recipe_name: String) -> void:
	if _day_ended:
		return
	if not RecipeManager.can_make(recipe_name):
		status_label.text = "Not enough ingredients for %s." % recipe_name
		return

	var recipe: Dictionary = RecipeManager.get_recipe(recipe_name)
	if recipe.is_empty():
		status_label.text = "Recipe not found: %s." % recipe_name
		return

	# Deduct ingredients with rollback on failure
	var ingredients: Dictionary = recipe.get("ingredients", {})
	var deducted:    Dictionary = {}
	for ingredient_id in ingredients.keys():
		var amount: int = int(ingredients[ingredient_id])
		if not InventoryManager.remove_ingredient(str(ingredient_id), amount):
			for rollback_id in deducted.keys():
				InventoryManager.add_ingredient(str(rollback_id), int(deducted[rollback_id]))
			status_label.text = "Missing: %s" % ingredient_id
			return
		deducted[ingredient_id] = amount

	# Apply prep-time multiplier from upgrades
	var prep_time: float = float(recipe.get("prep_time", 0.0))
	if get_node_or_null("/root/UpgradeManager") != null:
		prep_time *= UpgradeManager.prep_time_multiplier

	status_label.text = "Preparing %s…" % recipe_name
	_set_buttons_busy(true)

	await get_tree().create_timer(prep_time).timeout
	_set_buttons_busy(false)
	_finish_dish(recipe_name)

func _finish_dish(recipe_name: String) -> void:
	# Serve the first waiting customer whose order matches
	for customer in CustomerManager.active_customers:
		if not is_instance_valid(customer):
			continue
		if customer.order != recipe_name:
			continue
		if customer.serve(recipe_name):
			var payout: int = MenuManager.get_price(recipe_name) + customer.tip_amount
			GameState.earn_money(payout)
			status_label.text = "Served %s! +$%d" % [recipe_name, payout]
			return

	status_label.text = "No one waiting for %s." % recipe_name

func _set_buttons_busy(busy: bool) -> void:
	for recipe_name in _dish_buttons.keys():
		var btn: Button = _dish_buttons[recipe_name]
		if btn != null:
			btn.disabled = busy or _day_ended

# ─────────────────────────────────────────────────────────────────────────────
# END DAY
# ─────────────────────────────────────────────────────────────────────────────

func _on_end_day_pressed() -> void:
	if _day_ended:
		return
	_day_ended = true
	end_day_button.disabled = true
	_set_buttons_busy(true)

	var stats: Dictionary = CustomerManager.end_day()
	GameState.daily_stats = stats
	status_label.text = "Day ended. Tallying results…"

	await get_tree().create_timer(1.2).timeout
	get_tree().change_scene_to_file("res://scenes/DaySummaryScreen.tscn")
