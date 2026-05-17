extends ColorRect

@export var speed: float = 260.0

func _ready() -> void:
	color = Color(0.18, 0.24, 0.32, 1.0)

func _process(delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta
		position.x = clamp(position.x, 40.0, 1216.0)
		position.y = clamp(position.y, 72.0, 640.0)
