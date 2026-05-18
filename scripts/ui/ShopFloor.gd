extends Node2D

const MAX_QUEUE_SLOTS: int = 3

@onready var coins_label: Label = $UI/TopBar/Row/CoinsLabel
@onready var xp_label: Label = $UI/TopBar/Row/XPLabel
@onready var reputation_label: Label = $UI/TopBar/Row/ReputationLabel
@onready var day_label: Label = $UI/TopBar/Row/DayLabel
@onready var queue_slots: Array[PanelContainer] = [
	$UI/QueueArea/QueueStack/Slot1,
	$UI/QueueArea/QueueStack/Slot2,
	$UI/QueueArea/QueueStack/Slot3
]
@onready var dish_buttons_root: VBoxContainer = $UI/DishArea/Margin/Scroll/DishStack
@onready var end_day_button: Button = $UI/EndDayButton
@onready var open_popup: Label = $UI/OpenPopup
@onready var status_label: Label = $UI/StatusLabel

var _dish_buttons: Dictionary = {}
var _day_ended: bool = false
var _warned_empty_menu: bool = false

func _ready() -> void:
	CustomerManager.start_day()
	_show_open_popup()
	_build_dish_buttons()
	_refresh_top_bar()
	_refresh_queue_ui()
	end_day_button.pressed.connect(_on_end_day_pressed)
	if MenuManager.get_active_menu().is_empty():
		_warned_empty_menu = true
		status_label.text = "Add items to your menu first!"
		UIManager.show_warning("Add items to your menu first!")
	else:
		status_label.text = "Shop is open."

func _process(_delta: float) -> void:
	_refresh_top_bar()
	_refresh_queue_ui()
	_refresh_dish_button_states()

func _show_open_popup() -> void:
	open_popup.visible = true
	var timer: SceneTreeTimer = get_tree().create_timer(2.0)
	timer.timeout.connect(func() -> void:
		open_popup.visible = false
	)

func _build_dish_buttons() -> void:
	_dish_buttons.clear()
	for child in dish_buttons_root.get_children():
		child.queue_free()
	var active_menu: Array = MenuManager.get_active_menu()
	for recipe_item in active_menu:
		var recipe_name: String = str(recipe_item)
		var recipe: Dictionary = RecipeManager.get_recipe(recipe_name)
		if recipe.is_empty():
			continue
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(0, 44)
		button.text = "%s (%.1fs)" % [recipe_name, float(recipe.get("prep_time", 0.0))]
		button.pressed.connect(func() -> void: _on_dish_pressed(recipe_name))
		dish_buttons_root.add_child(button)
		_dish_buttons[recipe_name] = button

func _refresh_top_bar() -> void:
	coins_label.text = "Coins: %d" % GameState.coins
	xp_label.text = "XP: %d" % GameState.xp
	reputation_label.text = "Rep: %.1f" % GameState.reputation
	day_label.text = "Day: %d" % GameState.current_day

func _refresh_queue_ui() -> void:
	for idx in range(MAX_QUEUE_SLOTS):
		var slot: PanelContainer = queue_slots[idx]
		var name_label: Label = slot.get_node("Margin/Stack/Name") as Label
		var order_label: Label = slot.get_node("Margin/Stack/Order") as Label
		var patience_bar: ProgressBar = slot.get_node("Margin/Stack/Patience") as ProgressBar
		if idx >= CustomerManager.active_customers.size():
			name_label.text = "Empty"
			order_label.text = "Order: -"
			patience_bar.value = 0.0
			continue
		var customer: Customer = CustomerManager.active_customers[idx]
		name_label.text = customer.customer_name
		order_label.text = "Order: %s" % customer.order
		patience_bar.value = customer.get_satisfaction() * 100.0

func _refresh_dish_button_states() -> void:
	for recipe_name in _dish_buttons.keys():
		var button: Button = _dish_buttons[recipe_name]
		if button == null:
			continue
		button.disabled = _day_ended or not RecipeManager.can_make(str(recipe_name))

func _on_dish_pressed(recipe_name: String) -> void:
	if _day_ended:
		return
	if not RecipeManager.can_make(recipe_name):
		status_label.text = "Not enough ingredients for %s." % recipe_name
		return
	var recipe: Dictionary = RecipeManager.get_recipe(recipe_name)
	if recipe.is_empty():
		status_label.text = "Recipe missing: %s" % recipe_name
		return
	var ingredients: Dictionary = recipe.get("ingredients", {})
	var deducted: Dictionary = {}
	for ingredient_id in ingredients.keys():
		var ingredient_name: String = str(ingredient_id)
		var amount: int = int(ingredients[ingredient_id])
		if not InventoryManager.remove_ingredient(ingredient_name, amount):
			for rollback_id in deducted.keys():
				InventoryManager.add_ingredient(str(rollback_id), int(deducted[rollback_id]))
			status_label.text = "Missing ingredient: %s" % ingredient_name
			return
		deducted[ingredient_name] = amount
	var prep_time: float = float(recipe.get("prep_time", 0.0))
	if get_node_or_null("/root/UpgradeManager") != null:
		prep_time *= UpgradeManager.prep_time_multiplier
	var timer: SceneTreeTimer = get_tree().create_timer(prep_time)
	status_label.text = "Preparing %s..." % recipe_name
	timer.timeout.connect(func() -> void:
		_finish_dish(recipe_name)
	)

func _finish_dish(recipe_name: String) -> void:
	var served: bool = false
	for customer in CustomerManager.active_customers:
		if customer == null or not is_instance_valid(customer):
			continue
		if customer.order != recipe_name:
			continue
		if customer.serve(recipe_name):
			var payout: int = MenuManager.get_price(recipe_name) + customer.tip_amount
			GameState.earn_money(payout)
			status_label.text = "Served %s (+%d coins)." % [recipe_name, payout]
			served = true
			break
	if not served:
		status_label.text = "No waiting customer for %s." % recipe_name

func _on_end_day_pressed() -> void:
	if _day_ended:
		return
	_day_ended = true
	end_day_button.disabled = true
	for recipe_name in _dish_buttons.keys():
		var button: Button = _dish_buttons[recipe_name]
		if button != null:
			button.disabled = true
	var stats: Dictionary = CustomerManager.end_day()
	GameState.daily_stats = stats
	status_label.text = "Day ended. Preparing summary..."
	var timer: SceneTreeTimer = get_tree().create_timer(1.0)
	timer.timeout.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/DaySummaryScreen.tscn")
	)
