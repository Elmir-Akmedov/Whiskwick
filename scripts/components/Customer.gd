extends Node2D
class_name Customer
# ─────────────────────────────────────────────────────────────────────────────
# Customer.gd  –  Phase 1 + 2 upgrade
# Uses pixel art sprites via GeneratedArtPresenter.
# Patience counts down; satisfaction drives tip amount.
# ─────────────────────────────────────────────────────────────────────────────

const GeneratedArt := preload("res://scripts/visual/GeneratedArtPresenter.gd")

signal customer_served(customer: Customer)
signal customer_left_unhappy(customer: Customer)

const COZY_NAMES: Array[String] = [
	"Ada", "Milo", "Nora", "Jun", "Elsie",
	"Rowan", "Poppy", "Theo", "Sana", "Finn"
]

@export var customer_name: String = ""
@export var order:         String = ""
@export var patience:      float  = 30.0
@export var tip_amount:    int    = 0
@export var is_served:     bool   = false

var _left:         bool  = false
var _max_patience: float = 30.0
var _art_sprite:   AnimatedSprite2D = null

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	# Pick a random name if not already set
	if customer_name.is_empty():
		customer_name = COZY_NAMES[randi() % COZY_NAMES.size()]

	# Decorate with pixel art sprite
	_art_sprite = GeneratedArt.decorate_customer(self)

	_update_label()

func setup(order_candidates: Array[String]) -> void:
	_max_patience = 30.0
	if get_node_or_null("/root/UpgradeManager") != null:
		_max_patience += float(UpgradeManager.customer_patience_bonus_seconds)
	patience = _max_patience

	if order_candidates.is_empty():
		push_error("Customer.setup: order_candidates is empty.")
		order = ""
	else:
		order = order_candidates[randi() % order_candidates.size()]

	if customer_name.is_empty():
		customer_name = COZY_NAMES[randi() % COZY_NAMES.size()]

	_update_label()

# ─────────────────────────────────────────────────────────────────────────────
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
	is_served  = true
	tip_amount = int(round(lerpf(0.0, 8.0, get_satisfaction())))
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

# ─────────────────────────────────────────────────────────────────────────────
func _update_label() -> void:
	var label: Label = get_node_or_null("Label")
	if label == null:
		return
	var pct: int = int(round(get_satisfaction() * 100.0))
	label.text = "%s\n%s\n%d%%" % [
		customer_name,
		order if not order.is_empty() else "No menu",
		pct
	]
	# Colour the label text to match patience level
	if pct > 60:
		label.modulate = Color(0.3, 0.9, 0.4)
	elif pct > 30:
		label.modulate = Color(1.0, 0.85, 0.1)
	else:
		label.modulate = Color(0.95, 0.25, 0.25)
