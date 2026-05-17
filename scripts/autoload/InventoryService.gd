extends Node

signal inventory_changed

var raw: Dictionary = {}
var prep: Dictionary = {}
var finished: Dictionary = {}

func reset() -> void:
	raw.clear()
	prep.clear()
	finished.clear()
	emit_signal("inventory_changed")

func add_item(layer: String, item_id: String, amount: int) -> void:
	if amount <= 0:
		return
	var target := _layer(layer)
	target[item_id] = target.get(item_id, 0) + amount
	emit_signal("inventory_changed")

func add_item_result(layer: String, item_id: String, amount: int) -> Dictionary:
	if amount <= 0:
		return {"ok": false, "message": "Amount must be positive."}
	var layer_check := _validate_layer(layer)
	if not bool(layer_check.get("ok", false)):
		return layer_check
	add_item(layer, item_id, amount)
	return {"ok": true, "message": "Added %sx %s to %s." % [amount, item_id, layer], "layer": layer, "item_id": item_id, "amount": amount}

func get_count(layer: String, item_id: String) -> int:
	return int(_layer(layer).get(item_id, 0))

func has_items(layer: String, costs: Dictionary) -> bool:
	var target := _layer(layer)
	for item_id in costs:
		if target.get(item_id, 0) < int(costs[item_id]):
			return false
	return true

func has_layered_items(costs_by_layer: Dictionary) -> bool:
	for layer in costs_by_layer:
		if not has_items(str(layer), costs_by_layer[layer]):
			return false
	return true

func missing_layered_items(costs_by_layer: Dictionary) -> Dictionary:
	var missing := {}
	for layer in costs_by_layer:
		var layer_missing := {}
		var target := _layer(str(layer))
		var layer_costs: Dictionary = costs_by_layer[layer]
		for item_id in layer_costs:
			var needed := int(layer_costs[item_id])
			var available := int(target.get(item_id, 0))
			if available < needed:
				layer_missing[str(item_id)] = {"needed": needed, "available": available}
		if not layer_missing.is_empty():
			missing[str(layer)] = layer_missing
	return missing

func consume_items(layer: String, costs: Dictionary) -> bool:
	if not has_items(layer, costs):
		return false
	var target := _layer(layer)
	for item_id in costs:
		target[item_id] -= int(costs[item_id])
	emit_signal("inventory_changed")
	return true

func consume_layered_items(costs_by_layer: Dictionary) -> bool:
	if not has_layered_items(costs_by_layer):
		return false
	for layer in costs_by_layer:
		var target := _layer(str(layer))
		var layer_costs: Dictionary = costs_by_layer[layer]
		for item_id in layer_costs:
			target[item_id] -= int(layer_costs[item_id])
	emit_signal("inventory_changed")
	return true

func buy_ingredient(ingredient_id: String, amount: int = 1) -> Dictionary:
	if amount <= 0:
		return {"ok": false, "message": "Amount must be positive."}

	var ingredient := DataLibrary.get_ingredient(ingredient_id)
	if ingredient.is_empty():
		return {"ok": false, "message": "Unknown ingredient: %s." % ingredient_id}

	var layer := DataLibrary.get_ingredient_layer(ingredient_id)
	var layer_check := _validate_layer(layer)
	if not bool(layer_check.get("ok", false)):
		return layer_check

	var total_price := DataLibrary.get_ingredient_price(ingredient_id, amount)
	if total_price <= 0:
		return {"ok": false, "message": "Ingredient %s has no valid price." % ingredient_id}
	if not GameState.spend_money(total_price):
		return {"ok": false, "message": "Not enough money to buy %sx %s." % [amount, ingredient_id], "price": total_price, "money": GameState.money}

	add_item(layer, ingredient_id, amount)
	return {
		"ok": true,
		"message": "Bought %sx %s." % [amount, ingredient_id],
		"ingredient_id": ingredient_id,
		"amount": amount,
		"layer": layer,
		"price": total_price,
		"money": GameState.money
	}

func can_craft_recipe(recipe_id: String) -> Dictionary:
	var recipe_check := DataLibrary.validate_recipe(recipe_id)
	if not bool(recipe_check.get("ok", false)):
		return recipe_check

	var costs: Dictionary = recipe_check.get("ingredients", {})
	var missing := missing_layered_items(costs)
	if not missing.is_empty():
		return {"ok": false, "message": "Missing ingredients for %s." % recipe_id, "missing": missing, "ingredients": costs}

	return {"ok": true, "message": "Recipe can be crafted.", "recipe_id": recipe_id, "ingredients": costs}

func consume_recipe_ingredients(recipe_id: String) -> Dictionary:
	var craft_check := can_craft_recipe(recipe_id)
	if not bool(craft_check.get("ok", false)):
		return craft_check
	var costs: Dictionary = craft_check.get("ingredients", {})
	if not consume_layered_items(costs):
		return {"ok": false, "message": "Missing ingredients for %s." % recipe_id}
	return {"ok": true, "message": "Consumed ingredients for %s." % recipe_id, "recipe_id": recipe_id, "ingredients": costs}

func craft_recipe(recipe_id: String) -> Dictionary:
	var consume_result := consume_recipe_ingredients(recipe_id)
	if not bool(consume_result.get("ok", false)):
		return consume_result

	var output_layer := DataLibrary.get_recipe_output_layer(recipe_id)
	var output_id := DataLibrary.get_recipe_output_id(recipe_id)
	var yield_amount := DataLibrary.get_recipe_yield(recipe_id)
	add_item(output_layer, output_id, yield_amount)

	return {
		"ok": true,
		"message": "Crafted %sx %s." % [yield_amount, output_id],
		"recipe_id": recipe_id,
		"output_layer": output_layer,
		"output_id": output_id,
		"amount": yield_amount
	}

func _layer(layer: String) -> Dictionary:
	match layer:
		"raw":
			return raw
		"prep":
			return prep
		"finished":
			return finished
		_:
			push_warning("Unknown inventory layer: %s" % layer)
			return raw

func _validate_layer(layer: String) -> Dictionary:
	if DataLibrary.has_inventory_layer(layer):
		return {"ok": true, "message": "Layer is valid."}
	return {"ok": false, "message": "Unknown inventory layer: %s." % layer}
