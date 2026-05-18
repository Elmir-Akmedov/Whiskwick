extends Node2D

@onready var heading_label: Label = $UI/Panel/Margin/Stack/Heading
@onready var coins_label: Label = $UI/Panel/Margin/Stack/CoinsEarned
@onready var served_label: Label = $UI/Panel/Margin/Stack/Served
@onready var satisfaction_label: Label = $UI/Panel/Margin/Stack/Satisfaction
@onready var reputation_label: Label = $UI/Panel/Margin/Stack/ReputationChange
@onready var xp_label: Label = $UI/Panel/Margin/Stack/XPGained
@onready var total_coins_label: Label = $UI/Panel/Margin/Stack/TotalCoins
@onready var levelup_label: Label = $UI/Panel/Margin/Stack/LevelUpLabel
@onready var go_market_button: Button = $UI/Panel/Margin/Stack/ButtonRow/GoMarketButton
@onready var go_upgrade_button: Button = $UI/Panel/Margin/Stack/ButtonRow/GoUpgradeButton

func _ready() -> void:
	_apply_daily_results()
	go_market_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/MarketScreen.tscn")
	)
	go_upgrade_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/UpgradeScreen.tscn")
	)

func _apply_daily_results() -> void:
	var stats: Dictionary = GameState.daily_stats
	var served: int = int(stats.get("total_served", 0))
	var total_visited: int = int(stats.get("total_visited", served))
	var coins_earned: int = int(stats.get("total_coins", 0))
	var avg_satisfaction: float = float(stats.get("avg_satisfaction", 0.0))

	heading_label.text = "Day %d Complete!" % GameState.current_day
	coins_label.text = "Coins earned today: %d" % coins_earned
	served_label.text = "Customers served: %d / %d" % [served, total_visited]
	satisfaction_label.text = "Average satisfaction: %s" % _satisfaction_emoji(avg_satisfaction)

	var rep_delta: float = 0.0
	if avg_satisfaction >= 0.75:
		rep_delta = 0.1
	elif avg_satisfaction <= 0.35:
		rep_delta = -0.1
	if get_node_or_null("/root/UpgradeManager") != null and rep_delta > 0.0:
		rep_delta += UpgradeManager.reputation_daily_bonus
	GameState.reputation = clampf(GameState.reputation + rep_delta, 0.0, 5.0)
	reputation_label.text = "Reputation change: %+.1f (Now %.1f)" % [rep_delta, GameState.reputation]

	var xp_gain: int = served * 10
	var old_level: int = GameState.level
	GameState.add_xp(xp_gain)
	xp_label.text = "XP gained: %d (Total %d)" % [xp_gain, GameState.xp]
	total_coins_label.text = "Total coins: %d" % GameState.coins

	if GameState.level > old_level:
		levelup_label.visible = true
		levelup_label.text = "Level Up! %d -> %d" % [old_level, GameState.level]
	else:
		levelup_label.visible = false

	var save_result: Dictionary = SaveManager.save_game()
	if not bool(save_result.get("ok", false)):
		push_error(str(save_result.get("message", "Save failed on summary screen.")))

func _satisfaction_emoji(avg_satisfaction: float) -> String:
	if avg_satisfaction >= 0.75:
		return "Great :)"
	if avg_satisfaction <= 0.35:
		return "Bad :("
	return "Ok :|"
