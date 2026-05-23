extends Node2D
# ─────────────────────────────────────────────────────────────────────────────
# DaySummaryScreen.gd  –  Phase 2 upgrade
# Shows end-of-day results with animated coin counter, satisfaction emoji,
# reputation change, XP gain, level-up popup, then routes to Market/Upgrade.
# ─────────────────────────────────────────────────────────────────────────────

@onready var heading_label:      Label  = $UI/Panel/Margin/Stack/Heading
@onready var coins_label:        Label  = $UI/Panel/Margin/Stack/CoinsEarned
@onready var served_label:       Label  = $UI/Panel/Margin/Stack/Served
@onready var satisfaction_label: Label  = $UI/Panel/Margin/Stack/Satisfaction
@onready var reputation_label:   Label  = $UI/Panel/Margin/Stack/ReputationChange
@onready var xp_label:           Label  = $UI/Panel/Margin/Stack/XPGained
@onready var total_coins_label:  Label  = $UI/Panel/Margin/Stack/TotalCoins
@onready var levelup_label:      Label  = $UI/Panel/Margin/Stack/LevelUpLabel
@onready var go_market_button:   Button = $UI/Panel/Margin/Stack/ButtonRow/GoMarketButton
@onready var go_upgrade_button:  Button = $UI/Panel/Margin/Stack/ButtonRow/GoUpgradeButton

func _ready() -> void:
	levelup_label.visible = false
	_apply_daily_results()

	go_market_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/screens/MarketScreen.tscn")
	)
	go_upgrade_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/screens/UpgradeScreen.tscn")
	)

# ─────────────────────────────────────────────────────────────────────────────

func _apply_daily_results() -> void:
	var stats:          Dictionary = GameState.daily_stats
	var served:         int        = int(stats.get("total_served",   0))
	var total_visited:  int        = int(stats.get("total_visited",  served))
	var coins_earned:   int        = int(stats.get("total_coins",    0))
	var avg_sat:        float      = float(stats.get("avg_satisfaction", 0.0))

	heading_label.text      = "Day %d Complete!" % GameState.current_day
	served_label.text       = "Customers served: %d / %d" % [served, total_visited]
	satisfaction_label.text = "Satisfaction: %s" % _sat_emoji(avg_sat)

	# ── Reputation
	var rep_delta: float = 0.0
	if avg_sat >= 0.75:
		rep_delta = 0.1
	elif avg_sat <= 0.35:
		rep_delta = -0.1
	if get_node_or_null("/root/UpgradeManager") != null and rep_delta > 0.0:
		rep_delta += UpgradeManager.reputation_daily_bonus
	GameState.reputation = clampf(GameState.reputation + rep_delta, 0.0, 5.0)
	reputation_label.text = "Reputation: %+.1f  (now %.1f ★)" % [rep_delta, GameState.reputation]

	# ── XP + level
	var xp_gain:   int = served * 10
	var old_level: int = GameState.level
	GameState.add_xp(xp_gain)
	xp_label.text = "XP gained: +%d  (total %d)" % [xp_gain, GameState.xp]

	# ── Animate coin counter
	coins_label.text      = "Coins earned: $0"
	total_coins_label.text = "Total coins: $%d" % GameState.coins
	_animate_coins(coins_earned)

	# ── Level-up popup
	if GameState.level > old_level:
		_show_levelup(old_level, GameState.level)

	# ── Auto-save
	var save_result: Dictionary = SaveManager.save_game()
	if not bool(save_result.get("ok", false)):
		push_error(str(save_result.get("message", "Save failed.")))

# ─────────────────────────────────────────────────────────────────────────────
# ANIMATIONS
# ─────────────────────────────────────────────────────────────────────────────

func _animate_coins(target: int) -> void:
	# Count up from 0 → target over 1 second
	var elapsed := 0.0
	var duration := 1.0
	var start    := 0
	# Use a tween to drive a fake property on this node
	var tween := create_tween()
	tween.tween_method(
		func(value: float) -> void:
			coins_label.text = "Coins earned: $%d" % int(value),
		float(start), float(target), duration
	)

func _show_levelup(old_level: int, new_level: int) -> void:
	levelup_label.text    = "⭐ Level Up!  %d → %d ⭐" % [old_level, new_level]
	levelup_label.visible = true
	levelup_label.scale   = Vector2(0.5, 0.5)
	levelup_label.modulate = Color(1, 1, 1, 0)

	var tween := create_tween()
	tween.tween_property(levelup_label, "scale",          Vector2(1.1, 1.1), 0.25)
	tween.parallel().tween_property(levelup_label, "modulate", Color(1, 1, 1, 1), 0.25)
	tween.tween_property(levelup_label, "scale",          Vector2(1.0, 1.0), 0.1)
	# Fade out after 2.5 s
	tween.tween_interval(2.5)
	tween.tween_property(levelup_label, "modulate", Color(1, 1, 1, 0), 0.4)

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

func _sat_emoji(avg: float) -> String:
	if avg >= 0.75:
		return "Great 😊"
	if avg <= 0.35:
		return "Bad 😞"
	return "Ok 😐"
