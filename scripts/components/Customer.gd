extends Node2D
class_name Customer

const GeneratedArt := preload("res://scripts/visual/GeneratedArtPresenter.gd")

signal customer_served(customer: Customer)
signal customer_left_unhappy(customer: Customer)

const COZY_NAMES: Array[String] = [
	"Ada", "Milo", "Nora", "Jun", "Elsie",
	"Rowan", "Poppy", "Theo", "Sana", "Finn"
]

@export var customer_name: String = ""
@export var order: String = ""
@export var patience: float = 30.0
@export var tip_amount: int = 0
@export var is_served: bool = false

var _left: bool = false
var _max_patience: float = 30.0

func _ready() -> void:
	GeneratedArt.decorate_customer(self)
	if customer_name.is_empty():
		customer_name = COZY_NAMES[randi() % COZY_NAMES.size()]
	_update_label()

func setup(order_candidates: Array[String]) -> void:
	_max_patience = 30.0
	if get_node_or_null("/root/UpgradeManager") != null:
		_max_patience += float(UpgradeManager.customer_patience_bonus_seconds)
	patience = _max_patience
	if order_candidates.is_empty():
		push_error("Customer setup failed: order_candidates is empty.")
		order = ""
	else:
		order = order_candidates[randi() % order_candidates.size()]
	if customer_name.is_empty():
		customer_name = COZY_NAMES[randi() % COZY_NAMES.size()]
	_update_label()

func _process(delta: float) -> void:
	if is_served or _left:
		return
	patience = maxf(0.0, patience - delta)
	if patience <= 0.0:
		leave()
	else:
		_update_label()

func serve(dish_name: String) -> bool:
	if is_served or _left:
		return false
	if dish_name != order:
		return false
	is_served = true
	var satisfaction: float = get_satisfaction()
	tip_amount = int(round(lerpf(0.0, 8.0, satisfaction)))
	emit_signal("customer_served", self)
	queue_free()
	return true

func leave() -> void:
	if is_served or _left:
		return
	_left = true
	emit_signal("customer_left_unhappy", self)
	queue_free()

func get_satisfaction() -> float:
	return clampf(patience / _max_patience, 0.0, 1.0)

func _update_label() -> void:
	var label: Label = get_node_or_null("Label")
	if label == null:
		return
	var patience_pct: int = int(round(clampf(patience / _max_patience, 0.0, 1.0) * 100.0))
	label.text = "%s\n%s\n%d%%" % [customer_name, order if not order.is_empty() else "No Menu", patience_pct]
