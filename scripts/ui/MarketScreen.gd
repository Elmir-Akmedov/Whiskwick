extends Node2D

const ITEMS: Array[Dictionary] = [
	{"id": "flour", "name": "Flour", "price": 5},
	{"id": "butter", "name": "Butter", "price": 8},
	{"id": "sugar", "name": "Sugar", "price": 6},
	{"id": "eggs", "name": "Eggs", "price": 4},
	{"id": "cream", "name": "Cream", "price": 10},
	{"id": "honey", "name": "Honey", "price": 12},
	{"id": "berries", "name": "Berries", "price": 9},
	{"id": "cinnamon", "name": "Cinnamon", "price": 7}
]

@onready var coins_label: Label = $UI/TopBar/CoinsLabel
@onready var list_root: VBoxContainer = $UI/ListPanel/Margin/Scroll/List
@onready var status_label: Label = $UI/StatusLabel
@onready var back_button: Button = $UI/BackButton

var _rows: Dictionary = {}
var _selected_qty: Dictionary = {}

func _ready() -> void:
	_build_rows()
	_refresh()
	back_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	)

func _build_rows() -> void:
	_rows.clear()
	for child in list_root.get_children():
		child.queue_free()
	for item in ITEMS:
		var item_id: String = str(item["id"])
		_selected_qty[item_id] = 1
		var card: PanelContainer = PanelContainer.new()
		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_top", 6)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_bottom", 6)
		card.add_child(margin)

		var stack: VBoxContainer = VBoxContainer.new()
		stack.add_theme_constant_override("separation", 4)
		margin.add_child(stack)

		var name_label: Label = Label.new()
		name_label.text = str(item["name"])
		stack.add_child(name_label)

		var info_row: HBoxContainer = HBoxContainer.new()
		info_row.add_theme_constant_override("separation", 8)
		stack.add_child(info_row)

		var stock_label: Label = Label.new()
		stock_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_row.add_child(stock_label)

		var price_label: Label = Label.new()
		price_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		price_label.text = "%d coins" % int(item["price"])
		info_row.add_child(price_label)

		var control_row: HBoxContainer = HBoxContainer.new()
		control_row.add_theme_constant_override("separation", 6)
		stack.add_child(control_row)

		var minus_button: Button = Button.new()
		minus_button.text = "-"
		minus_button.custom_minimum_size = Vector2(36, 32)
		minus_button.pressed.connect(func() -> void: _change_qty(item_id, -1))
		control_row.add_child(minus_button)

		var qty_label: Label = Label.new()
		qty_label.custom_minimum_size = Vector2(44, 30)
		qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		control_row.add_child(qty_label)

		var plus_button: Button = Button.new()
		plus_button.text = "+"
		plus_button.custom_minimum_size = Vector2(36, 32)
		plus_button.pressed.connect(func() -> void: _change_qty(item_id, 1))
		control_row.add_child(plus_button)

		var buy_button: Button = Button.new()
		buy_button.text = "Buy"
		buy_button.custom_minimum_size = Vector2(90, 34)
		buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy_button.pressed.connect(func() -> void: _buy(item_id))
		control_row.add_child(buy_button)

		list_root.add_child(card)
		_rows[item_id] = {
			"stock": stock_label,
			"qty": qty_label,
			"buy": buy_button
		}

func _refresh() -> void:
	coins_label.text = "Coins: %d" % GameState.coins
	for item in ITEMS:
		var item_id: String = str(item["id"])
		var stock: int = InventoryManager.get_stock(item_id)
		var row: Dictionary = _rows.get(item_id, {})
		if row.is_empty():
			continue
		var stock_label: Label = row["stock"]
		var qty_label: Label = row["qty"]
		stock_label.text = "Stock: %d" % stock
		stock_label.modulate = Color(1.0, 0.55, 0.2, 1.0) if stock < 2 else Color(1.0, 1.0, 1.0, 1.0)
		qty_label.text = str(_selected_qty[item_id])

func _change_qty(item_id: String, delta: int) -> void:
	var current: int = int(_selected_qty.get(item_id, 1))
	var next: int = max(1, current + delta)
	_selected_qty[item_id] = next
	_refresh()

func _buy(item_id: String) -> void:
	var item := _find_item(item_id)
	if item.is_empty():
		status_label.text = "Unknown ingredient."
		return
	var qty: int = int(_selected_qty.get(item_id, 1))
	var price: int = int(item["price"])
	var total: int = qty * price
	if not GameState.spend_money(total):
		status_label.text = "Not enough coins."
		return
	InventoryManager.add_ingredient(item_id, qty)
	status_label.text = "Bought %d %s for %d coins." % [qty, str(item["name"]), total]
	_refresh()

func _find_item(item_id: String) -> Dictionary:
	for item in ITEMS:
		if str(item["id"]) == item_id:
			return item
	return {}
