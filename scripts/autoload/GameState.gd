extends Node

signal money_changed(value: int)
signal stamina_changed(value: int)
signal day_changed(day: int)

var day: int = 1
var money: int = 120
var reputation: int = 0
var player_stamina: int = 100
var xp: int = 0
var level: int = 1

func start_new_game() -> void:
	day = 1
	money = 120
	reputation = 0
	player_stamina = 100
	xp = 0
	level = 1
	emit_signal("money_changed", money)
	emit_signal("stamina_changed", player_stamina)
	emit_signal("day_changed", day)

func spend_money(amount: int) -> bool:
	if amount > money:
		return false
	money -= amount
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
	emit_signal("day_changed", day)
	emit_signal("stamina_changed", player_stamina)
