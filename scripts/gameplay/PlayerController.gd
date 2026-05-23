extends ColorRect
# ─────────────────────────────────────────────────────────────────────────────
# PlayerController.gd  –  Phase 1 upgrade
#
# Uses player_4dir.png (64×96, hframes=4 vframes=4) via GeneratedArtPresenter.
# Row 0=South  Row 1=North  Row 2=West  Row 3=East  animation_speed=8.0
# ─────────────────────────────────────────────────────────────────────────────

const GeneratedArt := preload("res://scripts/visual/GeneratedArtPresenter.gd")

@export var speed: float = 200.0

var art_sprite: AnimatedSprite2D = null
var facing: String = "south"
var _is_moving: bool = false

func _ready() -> void:
	art_sprite = GeneratedArt.decorate_player(self)
	if art_sprite == null:
		push_error("PlayerController: player art failed to initialize.")

func _process(delta: float) -> void:
	var direction := _read_input()
	if direction != Vector2.ZERO:
		_update_facing(direction)
		position += direction.normalized() * speed * delta
		_clamp_to_world()
		_play_walk()
		_is_moving = true
	else:
		if _is_moving:
			_stop_walk()
			_is_moving = false

# ── Input ────────────────────────────────────────────────────────────────────

func _read_input() -> Vector2:
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1.0
	return dir

# ── Facing ───────────────────────────────────────────────────────────────────

func _update_facing(direction: Vector2) -> void:
	if absf(direction.x) > absf(direction.y):
		facing = "east" if direction.x > 0.0 else "west"
	else:
		facing = "south" if direction.y > 0.0 else "north"

# ── Animation ────────────────────────────────────────────────────────────────

func _play_walk() -> void:
	if art_sprite == null:
		return
	var anim := "player_walk_%s" % facing
	if art_sprite.animation != anim or not art_sprite.is_playing():
		art_sprite.play(anim)

func _stop_walk() -> void:
	if art_sprite == null:
		return
	art_sprite.stop()
	art_sprite.frame = 0

# ── World bounds ─────────────────────────────────────────────────────────────

func _clamp_to_world() -> void:
	position.x = clamp(position.x, 40.0, 1216.0)
	position.y = clamp(position.y, 72.0, 640.0)
