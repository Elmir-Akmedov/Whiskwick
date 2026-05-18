extends Node

var _recipes: Dictionary = {
	"Butter Cookie": {
		"name": "Butter Cookie",
		"ingredients": {"flour": 2, "butter": 1},
		"prep_time": 6.0,
		"base_price": 14,
		"unlocked": true
	},
	"Cinnamon Roll": {
		"name": "Cinnamon Roll",
		"ingredients": {"flour": 2, "butter": 1, "sugar": 1},
		"prep_time": 8.0,
		"base_price": 18,
		"unlocked": true
	},
	"Cream Puff": {
		"name": "Cream Puff",
		"ingredients": {"flour": 1, "butter": 1, "sugar": 1},
		"prep_time": 10.0,
		"base_price": 20,
		"unlocked": false
	},
	"Honey Cake": {
		"name": "Honey Cake",
		"ingredients": {"flour": 2, "sugar": 1},
		"prep_time": 12.0,
		"base_price": 24,
		"unlocked": false
	},
	"Berry Tart": {
		"name": "Berry Tart",
		"ingredients": {"flour": 2, "butter": 1, "sugar": 1},
		"prep_time": 14.0,
		"base_price": 26,
		"unlocked": false
	}
}

func get_unlocked_recipes() -> Array:
	var result: Array = []
	for recipe_name in _recipes.keys():
		var recipe: Dictionary = _recipes[recipe_name]
		if bool(recipe.get("unlocked", false)):
			result.append(recipe.duplicate(true))
	return result

func unlock_recipe(name: String) -> void:
	if not _recipes.has(name):
		push_error("Recipe not found: %s" % name)
		return
	var recipe: Dictionary = _recipes[name]
	recipe["unlocked"] = true
	_recipes[name] = recipe

func can_make(name: String) -> bool:
	if not _recipes.has(name):
		return false
	var recipe: Dictionary = _recipes[name]
	if not bool(recipe.get("unlocked", false)):
		return false
	var ingredients: Dictionary = recipe.get("ingredients", {})
	for ingredient_name in ingredients.keys():
		if InventoryManager.get_stock(str(ingredient_name)) < int(ingredients[ingredient_name]):
			return false
	return true

func get_recipe(name: String) -> Dictionary:
	if not _recipes.has(name):
		return {}
	return (_recipes[name] as Dictionary).duplicate(true)

func get_all_recipes() -> Array:
	var result: Array = []
	for recipe_name in _recipes.keys():
		result.append((_recipes[recipe_name] as Dictionary).duplicate(true))
	return result
