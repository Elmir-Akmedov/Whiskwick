extends Node

signal data_loaded

const INVENTORY_LAYERS = ["raw", "prep", "finished"]

var ingredients: Dictionary = {}
var recipes: Dictionary = {}
var starter_workers: Dictionary = {}
var day_themes: Dictionary = {}
var rooms: Dictionary = {}
var machines: Dictionary = {}
var placeables: Dictionary = {}
var worker_roles: Dictionary = {}
var item_categories: Dictionary = {}

func _ready() -> void:
	load_all()

func load_all() -> void:
	ingredients = _load_indexed_json("res://data/ingredients/starter_ingredients.json")
	recipes = _load_indexed_json("res://data/recipes/starter_recipes.json")
	starter_workers = _load_indexed_json("res://data/workers/starter_workers.json")
	day_themes = _load_indexed_json("res://data/day_themes.json")
	rooms = _load_indexed_json("res://data/rooms/room_definitions.json")
	machines = _load_indexed_json("res://data/machines/starter_machines.json")
	placeables = _load_indexed_json("res://data/placeables/starter_placeables.json")
	worker_roles = _load_indexed_json("res://data/workers/worker_roles.json")
	item_categories = _load_indexed_json("res://data/items/item_categories.json")
	emit_signal("data_loaded")

func get_recipe(recipe_id: String) -> Dictionary:
	return recipes.get(recipe_id, {})

func get_ingredient(ingredient_id: String) -> Dictionary:
	return ingredients.get(ingredient_id, {})

func has_inventory_layer(layer: String) -> bool:
	return layer in INVENTORY_LAYERS

func get_ingredient_layer(ingredient_id: String) -> String:
	var ingredient := get_ingredient(ingredient_id)
	return str(ingredient.get("layer", "raw"))

func get_ingredient_price(ingredient_id: String, amount: int = 1) -> int:
	var ingredient := get_ingredient(ingredient_id)
	if ingredient.is_empty() or amount <= 0:
		return 0
	return int(ingredient.get("base_price", 0)) * amount

func get_recipe_input_layer(recipe_id: String) -> String:
	var recipe := get_recipe(recipe_id)
	return str(recipe.get("input_layer", "raw"))

func get_recipe_output_layer(recipe_id: String) -> String:
	var recipe := get_recipe(recipe_id)
	return str(recipe.get("output_layer", "finished"))

func get_recipe_output_id(recipe_id: String) -> String:
	var recipe := get_recipe(recipe_id)
	return str(recipe.get("output_id", recipe_id))

func get_recipe_yield(recipe_id: String) -> int:
	var recipe := get_recipe(recipe_id)
	return max(1, int(recipe.get("batch_yield", 1)))

func get_recipe_ingredients_by_layer(recipe_id: String) -> Dictionary:
	var recipe := get_recipe(recipe_id)
	if recipe.is_empty():
		return {}
	return _normalize_layered_costs(recipe.get("ingredients", {}), get_recipe_input_layer(recipe_id))

func validate_recipe(recipe_id: String) -> Dictionary:
	var recipe := get_recipe(recipe_id)
	if recipe.is_empty():
		return {"ok": false, "message": "Unknown recipe: %s." % recipe_id}

	var input_layer := get_recipe_input_layer(recipe_id)
	var output_layer := get_recipe_output_layer(recipe_id)
	if not has_inventory_layer(input_layer):
		return {"ok": false, "message": "Recipe %s has unknown input layer: %s." % [recipe_id, input_layer]}
	if not has_inventory_layer(output_layer):
		return {"ok": false, "message": "Recipe %s has unknown output layer: %s." % [recipe_id, output_layer]}

	var costs := get_recipe_ingredients_by_layer(recipe_id)
	if costs.is_empty():
		return {"ok": false, "message": "Recipe %s has no ingredients." % recipe_id}

	for layer in costs:
		if not has_inventory_layer(layer):
			return {"ok": false, "message": "Recipe %s uses unknown layer: %s." % [recipe_id, layer]}
		var layer_costs: Dictionary = costs[layer]
		for item_id in layer_costs:
			var amount := int(layer_costs[item_id])
			if amount <= 0:
				return {"ok": false, "message": "Recipe %s has invalid amount for %s." % [recipe_id, item_id]}
			if layer != "finished" and get_ingredient(str(item_id)).is_empty():
				return {"ok": false, "message": "Recipe %s uses unknown ingredient: %s." % [recipe_id, item_id]}

	return {"ok": true, "message": "Recipe is valid.", "recipe": recipe, "ingredients": costs}

func get_day_theme(theme_id: String) -> Dictionary:
	return day_themes.get(theme_id, {})

func get_room(room_id: String) -> Dictionary:
	return rooms.get(room_id, {})

func get_machine(machine_id: String) -> Dictionary:
	return machines.get(machine_id, {})

func get_placeable(placeable_id: String) -> Dictionary:
	return placeables.get(placeable_id, {})

func get_worker_role(role_id: String) -> Dictionary:
	return worker_roles.get(role_id, {})

func get_item_category(category_id: String) -> Dictionary:
	return item_categories.get(category_id, {})

func get_machine_size(machine_id: String) -> Vector2i:
	var machine := get_machine(machine_id)
	return _parse_size(machine.get("footprint", machine.get("size", [1, 1])))

func get_placeable_size(placeable_id: String) -> Vector2i:
	var placeable := get_placeable(placeable_id)
	return _parse_size(placeable.get("footprint", placeable.get("size", [1, 1])))

func get_room_size(room_id: String) -> Vector2i:
	var room := get_room(room_id)
	return _parse_size(room.get("starter_size", room.get("size", [1, 1])))

func get_room_min_size(room_id: String) -> Vector2i:
	var room := get_room(room_id)
	return _parse_size(room.get("min_size", [1, 1]))

func get_room_max_size(room_id: String) -> Vector2i:
	var room := get_room(room_id)
	return _parse_size(room.get("max_size", [1, 1]))

func size_array_to_vector2i(size_data: Array, default_size: Vector2i = Vector2i.ONE) -> Vector2i:
	if size_data.size() < 2:
		return default_size
	return Vector2i(int(size_data[0]), int(size_data[1]))

func _load_indexed_json(path: String) -> Dictionary:
	var rows := _load_json_array(path)
	var indexed := {}
	for row in rows:
		var id := str(row.get("id", ""))
		if id.is_empty():
			push_warning("Data row in %s is missing an id." % path)
			continue
		indexed[id] = row
	return indexed

func _load_json_array(path: String) -> Array:
	if not FileAccess.file_exists(path):
		push_warning("Missing data file: %s" % path)
		return []
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		return parsed
	push_warning("Expected JSON array in %s." % path)
	return []

func _parse_size(size_data: Variant, default_size: Vector2i = Vector2i.ONE) -> Vector2i:
	if size_data is Array:
		return size_array_to_vector2i(size_data, default_size)
	if size_data is Dictionary:
		var size_dict: Dictionary = size_data
		return Vector2i(int(size_dict.get("width", default_size.x)), int(size_dict.get("height", default_size.y)))
	return default_size

func _normalize_layered_costs(costs: Variant, default_layer: String) -> Dictionary:
	var normalized := {}
	if not (costs is Dictionary):
		return normalized

	var costs_dict: Dictionary = costs
	var has_layer_keys := false
	for key in costs_dict:
		if has_inventory_layer(str(key)):
			has_layer_keys = true
			break

	if has_layer_keys:
		for layer_key in costs_dict:
			var layer := str(layer_key)
			if not (costs_dict[layer_key] is Dictionary):
				continue
			normalized[layer] = _clean_costs(costs_dict[layer_key])
	else:
		normalized[default_layer] = _clean_costs(costs_dict)

	return normalized

func _clean_costs(costs: Dictionary) -> Dictionary:
	var clean := {}
	for item_id in costs:
		var amount := int(costs[item_id])
		if amount > 0:
			clean[str(item_id)] = amount
	return clean
