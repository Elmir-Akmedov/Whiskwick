extends Resource
class_name RecipeDef

@export var id: String
@export var display_name: String
@export var station_type: String = "oven"
@export var input_layer: String = "raw"
@export var output_layer: String = "finished"
@export var ingredients: Dictionary = {}
@export var prep_minutes: int = 0
@export var cook_minutes: int = 0
@export var assembly_minutes: int = 0
@export var workload_points: int = 1
@export var batch_yield: int = 1
@export var sell_price: int = 1
@export var unlock_level: int = 1

func total_minutes() -> int:
	return prep_minutes + cook_minutes + assembly_minutes

