extends Node2D
# ─────────────────────────────────────────────────────────────────────────────
# MenuScreen.gd  –  Phase 2 upgrade
# Manage which recipes are active and their prices.
# Shows unlocked + locked recipes in separate scrollable panels.
# ─────────────────────────────────────────────────────────────────────────────

@onready var unlocked_list: VBoxContainer = $UI/UnlockedPanel/Margin/Scroll/UnlockedList
@onready var locked_list:   VBoxContainer = $UI/LockedPanel/Margin/Scroll/LockedList
@onready var status_label:  Label         = $UI/StatusLabel
@onready var back_button:   Button        = $UI/BackButton

func _ready() -> void:
	_render()
	back_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/gameplay/Main.tscn")
	)

# ─────────────────────────────────────────────────────────────────────────────

func _render() -> void:
	for child in unlocked_list.get_children():
		child.queue_free()
	for child in locked_list.get_children():
		child.queue_free()

	var lock_idx: int = 0
	for recipe in RecipeManager.get_all_recipes():
		if typeof(recipe) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = recipe
		var name: String  = str(item.get("name", "Unknown"))
		var unlocked: bool = bool(item.get("unlocked", false))
		if unlocked:
			unlocked_list.add_child(_build_unlocked_card(name, item))
		else:
			lock_idx += 1
			locked_list.add_child(_build_locked_card(name, 2 + lock_idx))

# ─────────────────────────────────────────────────────────────────────────────
# CARD BUILDERS
# ─────────────────────────────────────────────────────────────────────────────

func _build_unlocked_card(recipe_name: String, recipe: Dictionary) -> PanelContainer:
	var panel  := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   8)
	margin.add_theme_constant_override("margin_top",    6)
	margin.add_theme_constant_override("margin_right",  8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 4)
	margin.add_child(stack)

	# Title
	var title := Label.new()
	title.text = recipe_name
	title.add_theme_font_size_override("font_size", 16)
	stack.add_child(title)

	# Ingredients
	var ingredients: Dictionary = recipe.get("ingredients", {})
	var parts: Array[String]    = []
	for k in ingredients.keys():
		parts.append("%s ×%d" % [str(k), int(ingredients[k])])
	var ing_lbl := Label.new()
	ing_lbl.text = "Needs: %s" % ", ".join(parts)
	ing_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ing_lbl.modulate = Color(0.8, 0.8, 0.8)
	stack.add_child(ing_lbl)

	# Prep time
	var prep_lbl := Label.new()
	prep_lbl.text = "Prep: %.1fs" % float(recipe.get("prep_time", 0.0))
	prep_lbl.modulate = Color(0.8, 0.8, 0.8)
	stack.add_child(prep_lbl)

	# Price row
	var price_row := HBoxContainer.new()
	price_row.add_theme_constant_override("separation", 6)

	var minus_btn := Button.new()
	minus_btn.text = "−"
	minus_btn.custom_minimum_size = Vector2(34, 30)
	minus_btn.pressed.connect(func() -> void: _adjust_price(recipe_name, -1))
	price_row.add_child(minus_btn)

	var price_lbl := Label.new()
	price_lbl.name = "PriceLabel"
	price_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	price_lbl.text = "Price: $%d" % MenuManager.get_price(recipe_name)
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_row.add_child(price_lbl)

	var plus_btn := Button.new()
	plus_btn.text = "+"
	plus_btn.custom_minimum_size = Vector2(34, 30)
	plus_btn.pressed.connect(func() -> void: _adjust_price(recipe_name, 1))
	price_row.add_child(plus_btn)
	stack.add_child(price_row)

	# Toggle on/off menu
	var active_now: bool = recipe_name in MenuManager.get_active_menu()
	var toggle_btn := Button.new()
	toggle_btn.text = "✓ On Menu" if active_now else "Off Menu"
	toggle_btn.modulate = Color(0.4, 0.9, 0.5) if active_now else Color.WHITE
	toggle_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toggle_btn.pressed.connect(func() -> void: _toggle_recipe(recipe_name))
	stack.add_child(toggle_btn)

	return panel

func _build_locked_card(recipe_name: String, unlock_level: int) -> PanelContainer:
	var panel  := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.modulate = Color(0.6, 0.6, 0.6)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   8)
	margin.add_theme_constant_override("margin_top",    6)
	margin.add_theme_constant_override("margin_right",  8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(stack)

	var title := Label.new()
	title.text = "🔒 %s" % recipe_name
	stack.add_child(title)

	var sub := Label.new()
	sub.text = "Unlocks at Level %d" % unlock_level
	sub.modulate = Color(0.7, 0.7, 0.7)
	stack.add_child(sub)

	return panel

# ─────────────────────────────────────────────────────────────────────────────
# ACTIONS
# ─────────────────────────────────────────────────────────────────────────────

func _adjust_price(recipe_name: String, delta: int) -> void:
	var recipe: Dictionary = RecipeManager.get_recipe(recipe_name)
	if recipe.is_empty():
		status_label.text = "Recipe not found."
		return
	var base:    int = int(recipe.get("base_price", 0))
	var current: int = MenuManager.get_price(recipe_name)
	var next:    int = clampi(current + delta, base, base * 3)
	if not MenuManager.set_price(recipe_name, next):
		status_label.text = "Could not set price."
		return
	status_label.text = "Set %s price → $%d." % [recipe_name, next]
	_render()

func _toggle_recipe(recipe_name: String) -> void:
	var active_now: bool = recipe_name in MenuManager.get_active_menu()
	if not MenuManager.set_active(recipe_name, not active_now):
		status_label.text = "Menu is full (max %d items)." % UpgradeManager.max_active_menu_items
		return
	status_label.text = "%s is now %s." % [recipe_name, "On Menu ✓" if not active_now else "Off Menu"]
	_render()
