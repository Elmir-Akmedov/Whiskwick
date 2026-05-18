extends Node

signal money_changed(value: int)
signal stamina_changed(value: int)
signal day_changed(day: int)

var day: int = 1
var money: int = 120
var reputation: float = 0.0
var player_stamina: int = 100
var xp: int = 0
var level: int = 1
var shop_level: int = 1
var coins: int = 120
var current_day: int = 1
var daily_stats: Dictionary = {}

func start_new_game() -> void:
	day = 1
	money = 120
	reputation = 0.0
	player_stamina = 100
	xp = 0
	level = 1
	shop_level = 1
	daily_stats = {}
	_sync_public_aliases()
	emit_signal("money_changed", money)
	emit_signal("stamina_changed", player_stamina)

func add_xp(amount: int) -> void:
	if amount <= 0:
		return
	xp += amount
	level = max(1, int(floor(float(xp) / 100.0)) + 1)
	emit_signal("day_changed", day)

func spend_money(amount: int) -> bool:
	if amount > money:
		return false
	money -= amount
	_sync_public_aliases()
	emit_signal("money_changed", money)
	return true

func can_spend_money(amount: int) -> bool:
	return amount >= 0 and amount <= money

func spend_money_result(amount: int) -> Dictionary:
	if amount < 0:
		return {"ok": false, "message": "Amount must not be negative.", "money": money}
	if not can_spend_money(amount):
		return {"ok": false, "message": "Not enough money.", "amount": amount, "money": money}
	spend_money(amount)
	return {"ok": true, "message": "Spent %s money." % amount, "amount": amount, "money": money}

func earn_money(amount: int) -> void:
	money += amount
	_sync_public_aliases()
	emit_signal("money_changed", money)

func spend_stamina(amount: int) -> bool:
	if player_stamina < amount:
		return false
	player_stamina -= amount
	emit_signal("stamina_changed", player_stamina)
	return true

func restore_stamina(amount: int) -> void:
	if amount <= 0:
		return
	player_stamina = min(100, player_stamina + amount)
	emit_signal("stamina_changed", player_stamina)

func start_next_day() -> void:
	day += 1
	player_stamina = 100
	TimeService.reset_day()
	OrderService.reset_day()
	_sync_public_aliases()
	emit_signal("day_changed", day)
	emit_signal("stamina_changed", player_stamina)

func apply_save_data(data: Dictionary) -> void:
	if not data.has("coins") or not data.has("xp") or not data.has("shop_level") or not data.has("reputation") or not data.has("current_day"):
		push_error("Save payload is missing required fields.")
		return
	var loaded_coins := int(data["coins"])
	var loaded_xp := int(data["xp"])
	var loaded_shop_level := int(data["shop_level"])
	var loaded_reputation := float(data["reputation"])
	var loaded_day := int(data["current_day"])
	if loaded_coins < 0 or loaded_xp < 0 or loaded_shop_level < 1 or loaded_day < 1:
		push_error("Save payload contains invalid numeric ranges.")
		return
	money = loaded_coins
	xp = loaded_xp
	shop_level = loaded_shop_level
	reputation = clampf(loaded_reputation, 0.0, 5.0)
	day = loaded_day
	_sync_public_aliases()
	emit_signal("money_changed", money)
	emit_signal("day_changed", day)

func _sync_public_aliases() -> void:
	coins = money
	current_day = day
