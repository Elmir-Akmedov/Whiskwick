extends Node

var _upgrades: Dictionary = {
	"Better Oven": {
		"name": "Better Oven",
		"description": "Reduces all prep times by 20%",
		"cost": 100,
		"purchased": false
	},
	"Cozy Decor": {
		"name": "Cozy Decor",
		"description": "Increases daily reputation gain by 0.05",
		"cost": 80,
		"purchased": false
	},
	"Extra Staff": {
		"name": "Extra Staff",
		"description": "Enables idle earning",
		"cost": 150,
		"purchased": false
	},
	"Larger Kitchen": {
		"name": "Larger Kitchen",
		"description": "Increases max active menu items from 4 to 6",
		"cost": 120,
		"purchased": false
	},
	"Speed Training": {
		"name": "Speed Training",
		"description": "Increases customer patience by +10 seconds",
		"cost": 90,
		"purchased": false
	}
}

var prep_time_multiplier: float = 1.0
var reputation_daily_bonus: float = 0.0
var idle_earning_enabled: bool = false
var max_active_menu_items: int = 4
var customer_patience_bonus_seconds: float = 0.0

func _ready() -> void:
	apply_all_effects()

func get_available_upgrades() -> Array:
	var result: Array = []
	for name in _upgrades.keys():
		var upgrade: Dictionary = _upgrades[name]
		if not bool(upgrade.get("purchased", false)):
			result.append(upgrade.duplicate(true))
	return result

func get_all_upgrades() -> Array:
	var result: Array = []
	for name in _upgrades.keys():
		result.append((_upgrades[name] as Dictionary).duplicate(true))
	return result

func purchase(name: String) -> bool:
	if not _upgrades.has(name):
		return false
	var upgrade: Dictionary = _upgrades[name]
	if bool(upgrade.get("purchased", false)):
		return false
	var cost: int = int(upgrade.get("cost", 0))
	if not GameState.spend_money(cost):
		return false
	upgrade["purchased"] = true
	_upgrades[name] = upgrade
	apply_all_effects()
	return true

func apply_all_effects() -> void:
	prep_time_multiplier = 0.8 if _is_purchased("Better Oven") else 1.0
	reputation_daily_bonus = 0.05 if _is_purchased("Cozy Decor") else 0.0
	idle_earning_enabled = _is_purchased("Extra Staff")
	max_active_menu_items = 6 if _is_purchased("Larger Kitchen") else 4
	customer_patience_bonus_seconds = 10.0 if _is_purchased("Speed Training") else 0.0

func export_state() -> Dictionary:
	var purchased: Array[String] = []
	for name in _upgrades.keys():
		if bool((_upgrades[name] as Dictionary).get("purchased", false)):
			purchased.append(str(name))
	return {"purchased": purchased}

func import_state(state: Dictionary) -> void:
	for name in _upgrades.keys():
		var upgrade: Dictionary = _upgrades[name]
		upgrade["purchased"] = false
		_upgrades[name] = upgrade
	var purchased: Array = state.get("purchased", [])
	for name_value in purchased:
		var key: String = str(name_value)
		if not _upgrades.has(key):
			continue
		var upgrade: Dictionary = _upgrades[key]
		upgrade["purchased"] = true
		_upgrades[key] = upgrade
	apply_all_effects()

func _is_purchased(name: String) -> bool:
	if not _upgrades.has(name):
		return false
	return bool((_upgrades[name] as Dictionary).get("purchased", false))
