extends CanvasLayer

const TEST_SCENES := [
	{"label": "Main", "path": "res://scenes/Main.tscn"},
	{"label": "ShopFloor", "path": "res://scenes/ShopFloor.tscn"},
	{"label": "MarketScreen", "path": "res://scenes/MarketScreen.tscn"},
	{"label": "UpgradeScreen", "path": "res://scenes/UpgradeScreen.tscn"},
	{"label": "MenuScreen", "path": "res://scenes/MenuScreen.tscn"},
	{"label": "DaySummaryScreen", "path": "res://scenes/DaySummaryScreen.tscn"}
]

func _ready() -> void:
	layer = 50
	var panel := PanelContainer.new()
	panel.position = Vector2(12, 100)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 6)
	margin.add_child(stack)

	var title := Label.new()
	title.text = "Scene Test Switcher"
	stack.add_child(title)

	for item in TEST_SCENES:
		var button := Button.new()
		button.text = str(item.get("label", "Scene"))
		button.custom_minimum_size = Vector2(180, 36)
		button.pressed.connect(func() -> void:
			var path := str(item.get("path", ""))
			if path.is_empty():
				return
			if get_tree().current_scene != null and get_tree().current_scene.scene_file_path == path:
				return
			get_tree().change_scene_to_file(path)
		)
		stack.add_child(button)