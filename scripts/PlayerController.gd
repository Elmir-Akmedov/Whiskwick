extends ColorRect

const GeneratedArt := preload("res://scripts/visual/GeneratedArtPresenter.gd")

@export var speed: float = 260.0

var art_sprite: AnimatedSprite2D = null
var facing: String = "south"

func _ready() -> void:
	art_sprite = GeneratedArt.decorate_player(self)
	if art_sprite == null:
		push_error("Player art failed to initialize.")

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
		_update_facing(direction)
		position += direction.normalized() * speed * delta
		position.x = clamp(position.x, 40.0, 1216.0)
		position.y = clamp(position.y, 72.0, 640.0)
		_play_walk_animation()
	elif art_sprite != null:
		art_sprite.stop()
		art_sprite.frame = 0

func _update_facing(direction: Vector2) -> void:
	if absf(direction.x) > absf(direction.y):
		facing = "east" if direction.x > 0.0 else "west"
	else:
		facing = "south" if direction.y > 0.0 else "north"

func _play_walk_animation() -> void:
	if art_sprite == null:
		return
	var animation_name := "player_walk_%s" % facing
	if art_sprite.animation != animation_name:
		art_sprite.play(animation_name)
	elif not art_sprite.is_playing():
		art_sprite.play(animation_name)
