extends Node2D

@onready var unlocked_list: VBoxContainer = $UI/UnlockedPanel/Margin/Scroll/UnlockedList
@onready var locked_list: VBoxContainer = $UI/LockedPanel/Margin/Scroll/LockedList
@onready var status_label: Label = $UI/StatusLabel
@onready var back_button: Button = $UI/BackButton

func _ready() -> void:
	_render()
	back_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	)

func _render() -> void:
	for child in unlocked_list.get_children():
		child.queue_free()
	for child in locked_list.get_children():
		child.queue_free()

	var all_recipes: Array = RecipeManager.get_all_recipes()
	var lock_idx: int = 0
	for recipe in all_recipes:
		if typeof(recipe) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = recipe
		var name: String = str(item.get("name", "Unknown"))
		var unlocked: bool = bool(item.get("unlocked", false))
		if unlocked:
			unlocked_list.add_child(_build_unlocked_card(name, item))
		else:
			lock_idx += 1
			locked_list.add_child(_build_locked_card(name, 2 + lock_idx))

func _build_unlocked_card(recipe_name: String, recipe: Dictionary) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 4)
	margin.add_child(stack)

	var title: Label = Label.new()
	title.text = recipe_name
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(title)

	var ingredients: Dictionary = recipe.get("ingredients", {})
	var ing_text: Array[String] = []
	for ingredient_id in ingredients.keys():
		ing_text.append("%s x%d" % [str(ingredient_id), int(ingredients[ingredient_id])])
	var ing_label: Label = Label.new()
	ing_label.text = "Ingredients: %s" % ", ".join(ing_text)
	ing_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(ing_label)

	var prep_label: Label = Label.new()
	prep_label.text = "Prep: %.1fs" % float(recipe.get("prep_time", 0.0))
	stack.add_child(prep_label)

	var price_row: HBoxContainer = HBoxContainer.new()
	price_row.add_theme_constant_override("separation", 6)
	var minus_button: Button = Button.new()
	minus_button.text = "-"
	minus_button.custom_minimum_size = Vector2(32, 30)
	minus_button.pressed.connect(func() -> void: _adjust_price(recipe_name, -1))
	price_row.add_child(minus_button)
	var price_label: Label = Label.new()
	price_label.name = "PriceLabel"
	price_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	price_label.text = "Price: %d" % MenuManager.get_price(recipe_name)
	price_row.add_child(price_label)
	var plus_button: Button = Button.new()
	plus_button.text = "+"
	plus_button.custom_minimum_size = Vector2(32, 30)
	plus_button.pressed.connect(func() -> void: _adjust_price(recipe_name, 1))
	price_row.add_child(plus_button)
	stack.add_child(price_row)

	var toggle_button: Button = Button.new()
	var active_now: bool = recipe_name in MenuManager.get_active_menu()
	toggle_button.text = "On Menu" if active_now else "Off Menu"
	toggle_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toggle_button.pressed.connect(func() -> void: _toggle_recipe(recipe_name))
	stack.add_child(toggle_button)

	return panel

func _build_locked_card(recipe_name: String, unlock_level: int) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(stack)

	var title: Label = Label.new()
	title.text = recipe_name
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(title)
	var subtitle: Label = Label.new()
	subtitle.text = "Unlocks at Level %d" % unlock_level
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(subtitle)
	return panel

func _adjust_price(recipe_name: String, delta: int) -> void:
	var recipe: Dictionary = RecipeManager.get_recipe(recipe_name)
	if recipe.is_empty():
		status_label.text = "Recipe not found."
		return
	var base: int = int(recipe.get("base_price", 0))
	var current: int = MenuManager.get_price(recipe_name)
	var next: int = clampi(current + delta, base, base * 3)
	if not MenuManager.set_price(recipe_name, next):
		status_label.text = "Could not set price."
		return
	status_label.text = "Set %s price to %d." % [recipe_name, next]
	_render()

func _toggle_recipe(recipe_name: String) -> void:
	var active_now: bool = recipe_name in MenuManager.get_active_menu()
	if not MenuManager.set_active(recipe_name, not active_now):
		status_label.text = "Cannot activate more items (max reached)."
		return
	status_label.text = "%s is now %s." % [recipe_name, "On Menu" if not active_now else "Off Menu"]
	_render()
