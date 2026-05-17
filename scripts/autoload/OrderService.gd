extends Node

signal order_created(order: Dictionary)
signal order_completed(order: Dictionary)
signal order_failed(order: Dictionary)
signal orders_paused_changed(paused: bool)

var active_orders: Array[Dictionary] = []
var orders_paused: bool = false
var spawn_interval_minutes: int = 35
var _minutes_until_next_order: int = 0
var _last_time_checked: int = 0

func reset_day() -> void:
	active_orders.clear()
	orders_paused = false
	_minutes_until_next_order = spawn_interval_minutes
	_last_time_checked = TimeService.current_minutes
	emit_signal("orders_paused_changed", orders_paused)

func tick(_delta: float) -> void:
	if not TimeService.is_shop_open() or orders_paused:
		_last_time_checked = TimeService.current_minutes
		return
	var elapsed := TimeService.current_minutes - _last_time_checked
	if elapsed <= 0:
		return
	_last_time_checked = TimeService.current_minutes
	_minutes_until_next_order -= elapsed
	if _minutes_until_next_order <= 0:
		create_test_order()
		_minutes_until_next_order = spawn_interval_minutes

func set_orders_paused(value: bool) -> void:
	if orders_paused == value:
		return
	orders_paused = value
	emit_signal("orders_paused_changed", orders_paused)

func create_test_order() -> void:
	var order := {
		"id": active_orders.size() + 1,
		"recipe_id": "cupcake_batch",
		"quantity": 1,
		"patience_minutes": 45,
		"created_at": TimeService.current_minutes,
		"score": 4
	}
	active_orders.append(order)
	emit_signal("order_created", order)

func complete_order(order_id: int) -> bool:
	for order in active_orders:
		if order.get("id") == order_id:
			active_orders.erase(order)
			GameState.earn_money(12)
			emit_signal("order_completed", order)
			return true
	return false

