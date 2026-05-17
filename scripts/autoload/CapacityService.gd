extends Node

const EXPECTED_CAPACITY_RATIO := 0.75

func estimate_daily_capacity() -> Dictionary:
	var station_points := _estimate_station_workload()
	var worker_points := _estimate_worker_workload()
	var player_points := _estimate_player_workload()
	var max_score := station_points + worker_points + player_points
	var expected := int(round(max_score * EXPECTED_CAPACITY_RATIO))
	return {
		"max_score": max_score,
		"expected_score": expected,
		"bronze": int(round(expected * 0.75)),
		"silver": expected,
		"gold": int(round(expected * 1.2)),
		"legendary": int(round(expected * 1.4))
	}

func order_score(recipe_id: String, quantity: int = 1, urgency_multiplier: float = 1.0) -> int:
	var recipe := DataLibrary.get_recipe(recipe_id)
	if recipe.is_empty():
		return quantity
	var workload := int(recipe.get("workload_points", 1))
	var minutes := int(recipe.get("prep_minutes", 0)) + int(recipe.get("cook_minutes", 0)) + int(recipe.get("assembly_minutes", 0))
	var ingredient_count := 0
	for _item_id in recipe.get("ingredients", {}):
		ingredient_count += 1
	var base_score := workload * 3 + int(ceil(minutes / 10.0)) + ingredient_count
	return int(round(base_score * quantity * urgency_multiplier))

func can_offer_bulk_order(recipe_id: String, quantity: int, deadline_days: int) -> bool:
	var score: int = order_score(recipe_id, quantity)
	var capacity: Dictionary = estimate_daily_capacity()
	var available: int = int(capacity.get("expected_score", 0)) * max(deadline_days, 1)
	return score <= available

func _estimate_station_workload() -> int:
	# Starter graybox: one oven, one prep counter, one display shelf.
	return 18

func _estimate_worker_workload() -> int:
	var total := 0
	for worker in WorkerService.workers:
		total += int(worker.get("stamina", 0))
	return total

func _estimate_player_workload() -> int:
	return int(round(GameState.player_stamina / 8.0))
