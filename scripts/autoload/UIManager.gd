extends Node

func show_toast(message: String) -> void:
	print("UI: %s" % message)

func show_warning(message: String) -> void:
	push_warning(message)