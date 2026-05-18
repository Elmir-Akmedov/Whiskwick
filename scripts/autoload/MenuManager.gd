extends Node

const DEFAULT_MAX_ACTIVE := 4

var _active_menu: Dictionary = {}
var _custom_prices: Dictionary = {}

func _ready() -> void:
	var unlocked: Array = RecipeManager.get_unlocked_recipes()
	for recipe in unlocked:
		if _active_menu.size() >= _max_active_slots():
			break
		if typeof(recipe) != TYPE_DICTIONARY:
			continue
		var recipe_name: String = str((recipe as Dictionary).get("name", ""))
		if recipe_name.is_empty():
			continue
		_active_menu[recipe_name] = true

func set_active(recipe_name: String, active: bool) -> bool:
	if RecipeManager.get_recipe(recipe_name).is_empty():
		return false
	if active:
		if _active_menu.size() >= _max_active_slots() and not _active_menu.has(recipe_name):
			return false
		_active_menu[recipe_name] = true
	else:
		_active_menu.erase(recipe_name)
	return true

func get_active_menu() -> Array:
	var result: Array = []
	for recipe_name in _active_menu.keys():
		result.append(recipe_name)
	return result

func set_price(recipe_name: String, price: int) -> bool:
	if price <= 0:
		return false
	var recipe := RecipeManager.get_recipe(recipe_name)
	if recipe.is_empty():
		return false
	_custom_prices[recipe_name] = price
	return true

func get_price(recipe_name: String) -> int:
	if _custom_prices.has(recipe_name):
		return int(_custom_prices[recipe_name])
	var recipe := RecipeManager.get_recipe(recipe_name)
	if recipe.is_empty():
		return 0
	return int(recipe.get("base_price", 0))

func export_state() -> Dictionary:
	return {
		"active_menu": get_active_menu(),
		"custom_prices": _custom_prices.duplicate(true)
	}

func import_state(state: Dictionary) -> void:
	_active_menu.clear()
	_custom_prices.clear()
	var menu_items: Array = state.get("active_menu", [])
	for item in menu_items:
		set_active(str(item), true)
	var prices: Dictionary = state.get("custom_prices", {})
	for recipe_name in prices.keys():
		set_price(str(recipe_name), int(prices[recipe_name]))

func _max_active_slots() -> int:
	if get_node_or_null("/root/UpgradeManager") == null:
		return DEFAULT_MAX_ACTIVE
	return max(DEFAULT_MAX_ACTIVE, UpgradeManager.max_active_menu_items)
