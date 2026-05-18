extends Node

const LOW_STOCK_THRESHOLD := 2

var _ingredients: Dictionary = {
	"flour": 10,
	"butter": 5,
	"sugar": 8
}

func add_ingredient(name: String, amount: int) -> void:
	if amount <= 0:
		push_error("add_ingredient amount must be positive.")
		return
	_ingredients[name] = get_stock(name) + amount

func remove_ingredient(name: String, amount: int) -> bool:
	if amount <= 0:
		push_error("remove_ingredient amount must be positive.")
		return false
	var current := get_stock(name)
	if current < amount:
		return false
	var next := current - amount
	_ingredients[name] = next
	if next < LOW_STOCK_THRESHOLD:
		push_warning("Low stock warning: %s is now %d" % [name, next])
	return true

func get_stock(name: String) -> int:
	return int(_ingredients.get(name, 0))

func is_low_stock(name: String, threshold: int = LOW_STOCK_THRESHOLD) -> bool:
	if threshold < 0:
		push_error("threshold must be >= 0")
		return false
	return get_stock(name) < threshold

func get_all_ingredients() -> Dictionary:
	return _ingredients.duplicate(true)