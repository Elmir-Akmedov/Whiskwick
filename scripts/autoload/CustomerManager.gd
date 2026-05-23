extends Node
# ─────────────────────────────────────────────────────────────────────────────
# CustomerManager.gd  –  Phase 2 upgrade
# Spawns Customer scenes with pixel art sprites.
# Tracks daily stats for the end-of-day summary.
# ─────────────────────────────────────────────────────────────────────────────

const CUSTOMER_SCENE: PackedScene = preload("res://scenes/gameplay/Customer.tscn")

@export var max_customers_at_once: int   = 3
@export var spawn_interval:        float = 15.0

var active_customers: Array[Customer] = []
var _spawn_timer:     Timer
var _running:         bool = false

# Daily stats
var _total_served:      int   = 0
var _total_coins:       int   = 0
var _total_visited:     int   = 0
var _satisfaction_sum:  float = 0.0
var _unhappy_count:     int   = 0

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = false
	_spawn_timer.timeout.connect(spawn_customer)
	add_child(_spawn_timer)

func start_day() -> void:
	_running = true
	active_customers.clear()
	_total_served     = 0
	_total_coins      = 0
	_total_visited    = 0
	_satisfaction_sum = 0.0
	_unhappy_count    = 0

	# Faster spawns at higher shop levels
	var level_delta: int  = max(0, GameState.shop_level - 1)
	var interval:    float = maxf(5.0, spawn_interval - float(level_delta) * 0.5)
	_spawn_timer.wait_time = interval
	_spawn_timer.start()

func end_day() -> Dictionary:
	_running = false
	_spawn_timer.stop()
	for customer in active_customers:
		if is_instance_valid(customer):
			customer.queue_free()
	active_customers.clear()

	var avg_sat: float = 0.0
	if _total_visited > 0:
		avg_sat = _satisfaction_sum / float(_total_visited)

	return {
		"total_served":      _total_served,
		"total_coins":       _total_coins,
		"avg_satisfaction":  avg_sat,
		"total_visited":     _total_visited,
		"unhappy_count":     _unhappy_count
	}

# ─────────────────────────────────────────────────────────────────────────────
func spawn_customer() -> void:
	if not _running:
		return
	if active_customers.size() >= max_customers_at_once:
		return

	# Build order list from active menu, fall back to all unlocked recipes
	var candidates: Array[String] = []
	for name in MenuManager.get_active_menu():
		candidates.append(str(name))
	if candidates.is_empty():
		for recipe in RecipeManager.get_unlocked_recipes():
			if typeof(recipe) == TYPE_DICTIONARY:
				candidates.append(str((recipe as Dictionary).get("name", "")))
	if candidates.is_empty():
		push_warning("CustomerManager: no recipes available — cannot spawn customer.")
		return

	var customer_node: Node = CUSTOMER_SCENE.instantiate()
	if not (customer_node is Customer):
		push_error("CustomerManager: Customer scene root is not a Customer node.")
		customer_node.queue_free()
		return

	var customer: Customer = customer_node as Customer
	customer.setup(candidates)
	customer.customer_served.connect(on_customer_served)
	customer.customer_left_unhappy.connect(on_customer_left)

	var host: Node = get_tree().current_scene
	if host == null:
		push_error("CustomerManager: current_scene is null.")
		customer.queue_free()
		return
	host.add_child(customer)

	# Space customers out in the queue area
	var idx: int = active_customers.size()
	customer.position = Vector2(120 + idx * 80, 240)
	active_customers.append(customer)
	_total_visited += 1

func on_customer_served(customer: Customer) -> void:
	_total_served  += 1
	_total_coins   += int(customer.tip_amount)
	_satisfaction_sum += customer.get_satisfaction()
	active_customers.erase(customer)

func on_customer_left(customer: Customer) -> void:
	_satisfaction_sum += 0.0
	_unhappy_count    += 1
	active_customers.erase(customer)
