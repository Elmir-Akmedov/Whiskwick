extends Node
class_name Stockpile

signal stockpile_changed

@export var layer: String = "raw"
@export var capacity: int = 20

var contents: Dictionary = {}

func free_space() -> int:
	var used := 0
	for item_id in contents:
		used += int(contents[item_id])
	return max(0, capacity - used)

func add_item(item_id: String, amount: int) -> bool:
	if amount > free_space():
		return false
	contents[item_id] = contents.get(item_id, 0) + amount
	emit_signal("stockpile_changed")
	return true

func remove_item(item_id: String, amount: int) -> bool:
	if contents.get(item_id, 0) < amount:
		return false
	contents[item_id] -= amount
	if contents[item_id] <= 0:
		contents.erase(item_id)
	emit_signal("stockpile_changed")
	return true

