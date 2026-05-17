extends Node
class_name CookStation

signal job_started(recipe_id: String)
signal job_finished(recipe_id: String, yield_amount: int)
signal job_failed(recipe_id: String, reason: String)

@export var station_id: String
@export var station_type: String = "oven"
@export var input_layer: String = "raw"
@export var output_layer: String = "finished"
@export var speed_multiplier: float = 1.0

var active_recipe_id: String = ""
var remaining_minutes: int = 0

func can_make(recipe_id: String) -> bool:
	return bool(can_make_result(recipe_id).get("ok", false))

func can_make_result(recipe_id: String) -> Dictionary:
	var recipe := DataLibrary.get_recipe(recipe_id)
	if recipe.is_empty():
		return {"ok": false, "message": "Unknown recipe: %s." % recipe_id}
	if recipe.get("station_type", "") != station_type:
		return {"ok": false, "message": "Wrong station type for %s." % recipe_id, "required_station_type": recipe.get("station_type", ""), "station_type": station_type}
	var recipe_check := DataLibrary.validate_recipe(recipe_id)
	if not bool(recipe_check.get("ok", false)):
		return recipe_check
	return InventoryService.can_craft_recipe(recipe_id)

func start_job(recipe_id: String) -> bool:
	var result := start_job_result(recipe_id)
	if not bool(result.get("ok", false)):
		emit_signal("job_failed", recipe_id, str(result.get("message", "Cooking failed.")))
	return bool(result.get("ok", false))

func start_job_result(recipe_id: String) -> Dictionary:
	if not active_recipe_id.is_empty():
		return {"ok": false, "message": "Station is busy.", "active_recipe_id": active_recipe_id}

	var make_check := can_make_result(recipe_id)
	if not bool(make_check.get("ok", false)):
		return make_check

	var recipe := DataLibrary.get_recipe(recipe_id)
	var consume_result := InventoryService.consume_recipe_ingredients(recipe_id)
	if not bool(consume_result.get("ok", false)):
		return consume_result

	active_recipe_id = recipe_id
	var total_minutes := int(recipe.get("prep_minutes", 0)) + int(recipe.get("cook_minutes", 0)) + int(recipe.get("assembly_minutes", 0))
	remaining_minutes = max(1, int(ceil(total_minutes / speed_multiplier)))
	emit_signal("job_started", recipe_id)
	return {"ok": true, "message": "Started cooking %s." % recipe_id, "recipe_id": recipe_id, "remaining_minutes": remaining_minutes}

func advance_minutes(amount: int) -> void:
	if active_recipe_id.is_empty():
		return
	remaining_minutes -= amount
	if remaining_minutes <= 0:
		_finish_job()

func _finish_job() -> void:
	var recipe := DataLibrary.get_recipe(active_recipe_id)
	var yield_amount := int(recipe.get("batch_yield", 1))
	var output_id := DataLibrary.get_recipe_output_id(active_recipe_id)
	var recipe_output_layer := DataLibrary.get_recipe_output_layer(active_recipe_id)
	InventoryService.add_item(recipe_output_layer, output_id, yield_amount)
	emit_signal("job_finished", active_recipe_id, yield_amount)
	active_recipe_id = ""
	remaining_minutes = 0
