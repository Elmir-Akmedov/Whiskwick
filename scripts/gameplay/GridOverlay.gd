extends Node2D

@export var origin: Vector2 = Vector2(32, 64)
@export var grid_size: Vector2 = Vector2(1216, 608)
@export var cell_size: int = 32
@export var line_color: Color = Color(0.44, 0.44, 0.40, 0.35)

func _draw() -> void:
	var columns := int(grid_size.x / cell_size)
	var rows := int(grid_size.y / cell_size)
	for x in range(columns + 1):
		var px := origin.x + x * cell_size
		draw_line(Vector2(px, origin.y), Vector2(px, origin.y + grid_size.y), line_color, 1.0)
	for y in range(rows + 1):
		var py := origin.y + y * cell_size
		draw_line(Vector2(origin.x, py), Vector2(origin.x + grid_size.x, py), line_color, 1.0)

