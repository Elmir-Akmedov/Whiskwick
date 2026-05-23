extends Node2D
# ─────────────────────────────────────────────────────────────────────────────
# UpgradeScreen.gd  –  Phase 2 upgrade
# Shows all upgrades. Purchased ones show a checkmark.
# Buy button bounces on success.
# ─────────────────────────────────────────────────────────────────────────────

@onready var coins_label:  Label         = $UI/TopBar/CoinsLabel
@onready var list_root:    VBoxContainer = $UI/ListPanel/Margin/Scroll/List
@onready var status_label: Label         = $UI/StatusLabel
@onready var back_button:  Button        = $UI/BackButton

func _ready() -> void:
	_render_upgrades()
	_refresh_coins()
	back_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/gameplay/Main.tscn")
	)

# ─────────────────────────────────────────────────────────────────────────────

func _refresh_coins() -> void:
	coins_label.text = "Coins: $%d" % GameState.coins

func _render_upgrades() -> void:
	for child in list_root.get_children():
		child.queue_free()

	for upgrade in UpgradeManager.get_all_upgrades():
		var upgrade_name: String = str(upgrade.get("name", "Upgrade"))
		var purchased:    bool   = bool(upgrade.get("purchased", false))
		var cost:         int    = int(upgrade.get("cost", 0))
		var can_afford:   bool   = GameState.coins >= cost

		var panel  := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left",   10)
		margin.add_theme_constant_override("margin_top",     8)
		margin.add_theme_constant_override("margin_right",  10)
		margin.add_theme_constant_override("margin_bottom",  8)
		panel.add_child(margin)

		var card := VBoxContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_constant_override("separation", 4)
		margin.add_child(card)

		# Title
		var title := Label.new()
		title.text = ("%s  ✓" % upgrade_name) if purchased else upgrade_name
		title.add_theme_font_size_override("font_size", 17)
		if purchased:
			title.modulate = Color(0.4, 0.9, 0.5)
		card.add_child(title)

		# Description
		var desc := Label.new()
		desc.text = str(upgrade.get("description", ""))
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.modulate = Color(0.85, 0.85, 0.85)
		card.add_child(desc)

		# Cost row + button
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)

		var cost_lbl := Label.new()
		cost_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cost_lbl.text = "Cost: $%d" % cost
		if not purchased and not can_afford:
			cost_lbl.modulate = Color(0.9, 0.3, 0.3)
		row.add_child(cost_lbl)

		var buy_btn := Button.new()
		buy_btn.custom_minimum_size = Vector2(100, 36)
		if purchased:
			buy_btn.text     = "Purchased"
			buy_btn.disabled = true
		elif not can_afford:
			buy_btn.text     = "Need $%d" % cost
			buy_btn.disabled = true
		else:
			buy_btn.text     = "Buy"
			buy_btn.disabled = false
			buy_btn.pressed.connect(func() -> void: _buy_upgrade(upgrade_name, buy_btn))
		row.add_child(buy_btn)

		card.add_child(row)
		list_root.add_child(panel)

# ─────────────────────────────────────────────────────────────────────────────

func _buy_upgrade(upgrade_name: String, btn: Button) -> void:
	if UpgradeManager.purchase(upgrade_name):
		status_label.text = "Purchased: %s!" % upgrade_name
		# Bounce animation on the button
		var tween := create_tween()
		tween.tween_property(btn, "scale", Vector2(1.15, 1.15), 0.1)
		tween.tween_property(btn, "scale", Vector2(1.0,  1.0),  0.1)
		await tween.finished
		_render_upgrades()
		_refresh_coins()
	else:
		status_label.text = "Cannot purchase: %s" % upgrade_name
