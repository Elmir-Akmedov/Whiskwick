extends Node
class_name WorkerAgent

signal stamina_changed(value: int)
signal task_failed(reason: String)

@export var worker_id: String
@export var display_name: String
@export var role: String = "baker"
@export var max_stamina: int = 7
@export var known_recipes: Array[String] = []

var stamina: int = 7
var on_break: bool = false

func _ready() -> void:
	stamina = max_stamina

func can_make(recipe_id: String) -> bool:
	return recipe_id in known_recipes and not on_break and stamina > 0

func spend_workload(recipe_id: String) -> bool:
	var recipe := DataLibrary.get_recipe(recipe_id)
	var workload := int(recipe.get("workload_points", 1))
	if workload > stamina:
		emit_signal("task_failed", "Not enough stamina.")
		return false
	stamina -= workload
	emit_signal("stamina_changed", stamina)
	return true

func start_break() -> void:
	on_break = true

func finish_break() -> void:
	on_break = false
	stamina = min(max_stamina, stamina + int(ceil(max_stamina * 0.5)))
	emit_signal("stamina_changed", stamina)
