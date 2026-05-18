extends Node2D

@onready var coins_label: Label = $UI/TopBar/CoinsLabel
@onready var list_root: VBoxContainer = $UI/ListPanel/Margin/Scroll/List
@onready var status_label: Label = $UI/StatusLabel
@onready var back_button: Button = $UI/BackButton

func _ready() -> void:
	_render_upgrades()
	_refresh_coins()
	back_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	)

func _refresh_coins() -> void:
	coins_label.text = "Coins: %d" % GameState.coins

func _render_upgrades() -> void:
	for child in list_root.get_children():
		child.queue_free()
	for upgrade in UpgradeManager.get_all_upgrades():
		var panel: PanelContainer = PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_top", 6)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_bottom", 6)
		panel.add_child(margin)

		var card: VBoxContainer = VBoxContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_constant_override("separation", 4)
		margin.add_child(card)

		var title: Label = Label.new()
		var name: String = str(upgrade.get("name", "Upgrade"))
		var purchased: bool = bool(upgrade.get("purchased", false))
		title.text = "%s%s" % [name, " (Bought)" if purchased else ""]
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(title)

		var description: Label = Label.new()
		description.text = str(upgrade.get("description", ""))
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(description)

		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var cost_label: Label = Label.new()
		cost_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cost_label.text = "Cost: %d" % int(upgrade.get("cost", 0))
		row.add_child(cost_label)

		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(96, 34)
		button.text = "Bought" if purchased else "Buy"
		button.disabled = purchased or GameState.coins < int(upgrade.get("cost", 0))
		button.pressed.connect(func() -> void:
			_buy_upgrade(name)
		)
		row.add_child(button)

		card.add_child(row)
		list_root.add_child(panel)

func _buy_upgrade(name: String) -> void:
	if UpgradeManager.purchase(name):
		status_label.text = "Purchased: %s" % name
		_render_upgrades()
		_refresh_coins()
	else:
		status_label.text = "Cannot purchase: %s" % name
