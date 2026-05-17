extends Resource
class_name WorkerDef

@export var id: String
@export var display_name: String
@export var role: String = "baker"
@export var stamina: int = 7
@export var speed_multiplier: float = 1.0
@export var quality_bonus: float = 0.0
@export var known_recipes: Array[String] = []

