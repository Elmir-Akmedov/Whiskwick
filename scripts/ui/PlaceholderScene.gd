extends Node2D

@export var scene_title: String = "Scene"
@export var show_back_button: bool = true

func _ready() -> void:
	var label := Label.new()
	label.text = scene_title
	label.position = Vector2(32, 24)
	label.add_theme_font_size_override("font_size", 34)
	add_child(label)

	if show_back_button:
		var back := Button.new()
		back.text = "Back To Main"
		back.position = Vector2(32, 80)
		back.custom_minimum_size = Vector2(180, 44)
		back.pressed.connect(_go_main)
		add_child(back)

func _go_main() -> void:
	get_tree().change_scene_to_file("res://scenes/gameplay/Main.tscn")