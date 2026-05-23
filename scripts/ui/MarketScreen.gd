extends Node2D
# ─────────────────────────────────────────────────────────────────────────────
# MarketScreen.gd  –  Phase 2 upgrade
# Buys ingredients from InventoryService (layered system) AND InventoryManager
# (legacy RecipeManager system) so both cook paths work simultaneously.
# ─────────────────────────────────────────────────────────────────────────────

# All buyable items — price matches starter_ingredients.json base_price
const ITEMS: Array[Dictionary] = [
	{"id": "flour",    "name": "Flour",    "price": 2},
	{"id": "egg",      "name": "Egg",      "price": 3},
	{"id": "sugar",    "name": "Sugar",    "price": 2},
	{"id": "milk",     "name": "Milk",     "price": 3},
	{"id": "cheese",   "name": "Cheese",   "price": 5},
	{"id": "tomato",   "name": "Tomato",   "price": 4},
	# Legacy names kept so RecipeManager recipes still work
	{"id": "butter",   "name": "Butter",   "price": 8},
	{"id": "cream",    "name": "Cream",    "price": 10},
	{"id": "honey",    "name": "Honey",    "price": 12},
	{"id": "berries",  "name": "Berries",  "price": 9},
	{"id": "cinnamon", "name": "Cinnamon", "price": 7},
]

const LOW_STOCK := 2

@onready var coins_label:  Label         = $UI/TopBar/CoinsLabel
@onready var list_root:    VBoxContainer = $UI/ListPanel/Margin/Scroll/List
@onready var status_label: Label         = $UI/StatusLabel
@onready var back_button:  Button        = $UI/BackButton

var _rows:         Dictionary = {}   # item_id → {stock, qty, buy}
var _selected_qty: Dictionary = {}   # item_id → int

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_rows()
	_refresh()
	back_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/gameplay/Main.tscn")
	)

# ─────────────────────────────────────────────────────────────────────────────
# ROW BUILDER
# ─────────────────────────────────────────────────────────────────────────────

func _build_rows() -> void:
	_rows.clear()
	for child in list_root.get_children():
		child.queue_free()

	for item in ITEMS:
		var item_id: String = str(item["id"])
		_selected_qty[item_id] = 1

		# Card container
		var card    := PanelContainer.new()
		var margin  := MarginContainer.new()
		margin.add_theme_constant_override("margin_left",   10)
		margin.add_theme_constant_override("margin_top",     6)
		margin.add_theme_constant_override("margin_right",  10)
		margin.add_theme_constant_override("margin_bottom",  6)
		card.add_child(margin)

		var stack := VBoxContainer.new()
		stack.add_theme_constant_override("separation", 4)
		margin.add_child(stack)

		# Name row
		var name_lbl := Label.new()
		name_lbl.text = str(item["name"])
		name_lbl.add_theme_font_size_override("font_size", 16)
		stack.add_child(name_lbl)

		# Info row: stock + price
		var info_row := HBoxContainer.new()
		info_row.add_theme_constant_override("separation", 10)
		stack.add_child(info_row)

		var stock_lbl := Label.new()
		stock_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_row.add_child(stock_lbl)

		var price_lbl := Label.new()
		price_lbl.text = "$%d each" % int(item["price"])
		info_row.add_child(price_lbl)

		# Control row: − qty + Buy
		var ctrl_row := HBoxContainer.new()
		ctrl_row.add_theme_constant_override("separation", 6)
		stack.add_child(ctrl_row)

		var minus_btn := Button.new()
		minus_btn.text = "−"
		minus_btn.custom_minimum_size = Vector2(40, 36)
		minus_btn.pressed.connect(func() -> void: _change_qty(item_id, -1))
		ctrl_row.add_child(minus_btn)

		var qty_lbl := Label.new()
		qty_lbl.custom_minimum_size = Vector2(40, 36)
		qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		qty_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		ctrl_row.add_child(qty_lbl)

		var plus_btn := Button.new()
		plus_btn.text = "+"
		plus_btn.custom_minimum_size = Vector2(40, 36)
		plus_btn.pressed.connect(func() -> void: _change_qty(item_id, 1))
		ctrl_row.add_child(plus_btn)

		var buy_btn := Button.new()
		buy_btn.text = "Buy"
		buy_btn.custom_minimum_size = Vector2(80, 36)
		buy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy_btn.pressed.connect(func() -> void: _buy(item_id))
		ctrl_row.add_child(buy_btn)

		list_root.add_child(card)
		_rows[item_id] = {"stock": stock_lbl, "qty": qty_lbl, "buy": buy_btn}

# ─────────────────────────────────────────────────────────────────────────────
# REFRESH
# ─────────────────────────────────────────────────────────────────────────────

func _refresh() -> void:
	coins_label.text = "Coins: $%d" % GameState.coins

	for item in ITEMS:
		var item_id: String  = str(item["id"])
		var row: Dictionary  = _rows.get(item_id, {})
		if row.is_empty():
			continue

		# Pull stock from both systems (show the higher value so display is honest)
		var stock_legacy: int = InventoryManager.get_stock(item_id)
		var stock_service: int = InventoryService.get_count("raw", item_id)
		var stock: int = max(stock_legacy, stock_service)

		var stock_lbl: Label  = row["stock"]
		var qty_lbl:   Label  = row["qty"]

		stock_lbl.text = "Stock: %d" % stock
		stock_lbl.modulate = Color(1.0, 0.5, 0.2) if stock < LOW_STOCK else Color.WHITE
		qty_lbl.text   = str(_selected_qty[item_id])

# ─────────────────────────────────────────────────────────────────────────────
# ACTIONS
# ─────────────────────────────────────────────────────────────────────────────

func _change_qty(item_id: String, delta: int) -> void:
	_selected_qty[item_id] = max(1, int(_selected_qty.get(item_id, 1)) + delta)
	_refresh()

func _buy(item_id: String) -> void:
	var item := _find_item(item_id)
	if item.is_empty():
		status_label.text = "Unknown ingredient."
		return

	var qty:   int = int(_selected_qty.get(item_id, 1))
	var price: int = int(item["price"])
	var total: int = qty * price

	if not GameState.spend_money(total):
		status_label.text = "Not enough coins! (need $%d)" % total
		return

	# Add to BOTH inventory systems so all recipes work
	InventoryManager.add_ingredient(item_id, qty)
	InventoryService.add_item("raw", item_id, qty)

	status_label.text = "Bought %d %s for $%d." % [qty, str(item["name"]), total]
	_refresh()

func _find_item(item_id: String) -> Dictionary:
	for item in ITEMS:
		if str(item["id"]) == item_id:
			return item
	return {}
