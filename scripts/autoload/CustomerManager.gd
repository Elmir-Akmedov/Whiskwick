extends Node

const CUSTOMER_SCENE: PackedScene = preload("res://scenes/Customer.tscn")

@export var max_customers_at_once: int = 3
@export var spawn_interval: float = 15.0

var active_customers: Array[Customer] = []
var _spawn_timer: Timer
var _running: bool = false

var _total_served: int = 0
var _total_coins: int = 0
var _total_visited: int = 0
var _satisfaction_sum: float = 0.0
var _unhappy_count: int = 0

func _ready() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = false
	_spawn_timer.timeout.connect(spawn_customer)
	add_child(_spawn_timer)

func start_day() -> void:
	_running = true
	active_customers.clear()
	_total_served = 0
	_total_coins = 0
	_total_visited = 0
	_satisfaction_sum = 0.0
	_unhappy_count = 0
	var level_delta: int = max(0, GameState.shop_level - 1)
	var effective_interval: float = maxf(5.0, spawn_interval - float(level_delta) * 0.5)
	_spawn_timer.wait_time = effective_interval
	_spawn_timer.start()

func end_day() -> Dictionary:
	_running = false
	_spawn_timer.stop()
	for customer in active_customers:
		if is_instance_valid(customer):
			customer.queue_free()
	active_customers.clear()
	var avg_satisfaction: float = 0.0
	if _total_visited > 0:
		avg_satisfaction = _satisfaction_sum / float(_total_visited)
	return {
		"total_served": _total_served,
		"total_coins": _total_coins,
		"avg_satisfaction": avg_satisfaction,
		"total_visited": _total_visited,
		"unhappy_count": _unhappy_count
	}

func spawn_customer() -> void:
	if not _running:
		return
	if active_customers.size() >= max_customers_at_once:
		return
	var order_candidates: Array[String] = []
	var active_menu: Array = MenuManager.get_active_menu()
	for recipe_name in active_menu:
		order_candidates.append(str(recipe_name))
	if order_candidates.is_empty():
		push_warning("CustomerManager: active menu is empty, using unlocked recipes as fallback.")
		var unlocked: Array = RecipeManager.get_unlocked_recipes()
		for recipe in unlocked:
			if typeof(recipe) == TYPE_DICTIONARY:
				order_candidates.append(str((recipe as Dictionary).get("name", "")))
	if order_candidates.is_empty():
		push_error("CustomerManager: cannot spawn customer without any available recipes.")
		return
	var customer_node: Node = CUSTOMER_SCENE.instantiate()
	if not (customer_node is Customer):
		push_error("Customer scene root is not a Customer instance.")
		return
	var customer: Customer = customer_node as Customer
	customer.setup(order_candidates)
	customer.customer_served.connect(on_customer_served)
	customer.customer_left_unhappy.connect(on_customer_left)
	var host: Node = get_tree().current_scene
	if host == null:
		push_error("CustomerManager: current_scene is null; cannot add customer.")
		return
	host.add_child(customer)
	var idx: int = active_customers.size()
	customer.position = Vector2(150 + idx * 90, 220)
	active_customers.append(customer)
	_total_visited += 1

func on_customer_served(customer: Customer) -> void:
	_total_served += 1
	_total_coins += int(customer.tip_amount)
	_satisfaction_sum += customer.get_satisfaction()
	active_customers.erase(customer)

func on_customer_left(customer: Customer) -> void:
	_satisfaction_sum += 0.0
	_unhappy_count += 1
	active_customers.erase(customer)
