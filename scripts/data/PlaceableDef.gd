extends Resource
class_name PlaceableDef

@export var id: String
@export var display_name: String
@export var category: String = "machine"
@export var allowed_rooms: Array[String] = []
@export var size: Vector2i = Vector2i.ONE
@export var cost: int = 0
@export var can_rotate: bool = true
@export var requires_wall: bool = false
@export var blocks_movement: bool = true
@export var unlock_level: int = 1

