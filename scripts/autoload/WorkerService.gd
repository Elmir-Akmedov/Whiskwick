extends Node

signal workers_changed

var workers: Array[Dictionary] = []

func reset() -> void:
	workers.clear()
	emit_signal("workers_changed")

func hire_worker(worker_data: Dictionary) -> void:
	workers.append(worker_data.duplicate(true))
	emit_signal("workers_changed")

func can_worker_make(worker: Dictionary, recipe_id: String) -> bool:
	return recipe_id in worker.get("known_recipes", [])

func spend_worker_stamina(worker_id: int, workload: int) -> bool:
	for worker in workers:
		if worker.get("id") == worker_id:
			var stamina := int(worker.get("stamina", 0))
			if stamina < workload:
				return false
			worker["stamina"] = stamina - workload
			emit_signal("workers_changed")
			return true
	return false

