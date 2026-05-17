extends CanvasLayer

signal buy_starter_ingredients_requested
signal cook_cupcakes_requested
signal complete_first_order_requested
signal pause_orders_toggled
signal skip_time_requested
signal place_table_requested
signal place_oven_requested
signal place_rack_requested
signal rotate_placement_requested

const MAX_LOG_LINES := 3

@onready var clock_label: Label = $Root/TopBar/TopMargin/StatsGrid/ClockLabel
@onready var money_label: Label = $Root/TopBar/TopMargin/StatsGrid/MoneyLabel
@onready var phase_label: Label = $Root/TopBar/TopMargin/StatsGrid/PhaseLabel
@onready var stamina_label: Label = $Root/TopBar/TopMargin/StatsGrid/StaminaLabel
@onready var order_count_label: Label = $Root/TopBar/TopMargin/StatsGrid/OrderCountLabel
@onready var stock_label: Label = $Root/TopBar/TopMargin/StatsGrid/StockLabel
@onready var buy_button: Button = $Root/ActionPanel/ActionMargin/ActionStack/BuyStarterButton
@onready var cook_button: Button = $Root/ActionPanel/ActionMargin/ActionStack/CookCupcakesButton
@onready var complete_order_button: Button = $Root/ActionPanel/ActionMargin/ActionStack/CompleteOrderButton
@onready var pause_button: Button = $Root/ActionPanel/ActionMargin/ActionStack/ControlRow/PauseOrdersButton
@onready var skip_button: Button = $Root/ActionPanel/ActionMargin/ActionStack/ControlRow/SkipTimeButton
@onready var place_table_button: Button = $Root/ActionPanel/ActionMargin/ActionStack/BuildRow/PlaceTableButton
@onready var place_oven_button: Button = $Root/ActionPanel/ActionMargin/ActionStack/BuildRow/PlaceOvenButton
@onready var place_rack_button: Button = $Root/ActionPanel/ActionMargin/ActionStack/BuildRow/PlaceRackButton
@onready var rotate_button: Button = $Root/ActionPanel/ActionMargin/ActionStack/BuildRow/RotateButton
@onready var action_log: RichTextLabel = $Root/BottomPanel/LogMargin/LogStack/ActionLog

var _log_lines: Array[String] = []

func _ready() -> void:
	buy_button.pressed.connect(func() -> void: emit_signal("buy_starter_ingredients_requested"))
	cook_button.pressed.connect(func() -> void: emit_signal("cook_cupcakes_requested"))
	complete_order_button.pressed.connect(func() -> void: emit_signal("complete_first_order_requested"))
	pause_button.pressed.connect(func() -> void: emit_signal("pause_orders_toggled"))
	skip_button.pressed.connect(func() -> void: emit_signal("skip_time_requested"))
	place_table_button.pressed.connect(func() -> void: emit_signal("place_table_requested"))
	place_oven_button.pressed.connect(func() -> void: emit_signal("place_oven_requested"))
	place_rack_button.pressed.connect(func() -> void: emit_signal("place_rack_requested"))
	rotate_button.pressed.connect(func() -> void: emit_signal("rotate_placement_requested"))

func set_clock(value: String) -> void:
	clock_label.text = "Clock: %s" % value

func set_money(value: int) -> void:
	money_label.text = "Money: $%d" % value

func set_phase(value: String) -> void:
	phase_label.text = "Phase: %s" % value

func set_stamina(value: int) -> void:
	stamina_label.text = "Stamina: %d" % value

func set_active_order_count(value: int) -> void:
	order_count_label.text = "Active Orders: %d" % value

func set_cupcake_stock(value: int) -> void:
	stock_label.text = "Cupcakes: %d" % value

func set_orders_paused(value: bool) -> void:
	pause_button.text = "Resume Orders" if value else "Pause Orders"

func log_line(value: String) -> void:
	_log_lines.append(value)
	while _log_lines.size() > MAX_LOG_LINES:
		_log_lines.pop_front()
	var rendered := ""
	for line in _log_lines:
		if not rendered.is_empty():
			rendered += "\n"
		rendered += line
	action_log.text = rendered
