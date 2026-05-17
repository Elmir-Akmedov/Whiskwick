extends Node
class_name GridPlacementService

const CELL_SIZE := 32

var room_bounds: Dictionary = {}
var placed_objects: Dictionary = {}
var _next_instance_id: int = 1

func set_room_bounds(room_id: String, origin: Vector2i, size: Vector2i) -> void:
	room_bounds[room_id] = {
		"origin": origin,
		"size": size
	}

func can_place(room_id: String, object_id: String, cell: Vector2i, size: Vector2i, rotation: int = 0) -> Dictionary:
	if not room_bounds.has(room_id):
		return {"ok": false, "message": "Unknown room: %s." % room_id}
	var footprint := _rotated_size(size, rotation)
	if not _inside_room(room_id, cell, footprint):
		return {"ok": false, "message": "%s does not fit in %s." % [object_id, room_id]}
	for existing_id in placed_objects:
		var existing: Dictionary = placed_objects[existing_id]
		if existing.get("room_id") != room_id:
			continue
		if _rects_overlap(cell, footprint, existing.get("cell"), existing.get("size")):
			return {"ok": false, "message": "%s overlaps %s." % [object_id, existing_id]}
	return {"ok": true, "message": "Can place %s." % object_id}

func is_cell_occupied(room_id: String, cell: Vector2i) -> bool:
	for existing_id in placed_objects:
		var existing: Dictionary = placed_objects[existing_id]
		if existing.get("room_id") != room_id:
			continue
		var existing_cell: Vector2i = existing.get("cell")
		var existing_size: Vector2i = existing.get("size")
		if (
			cell.x >= existing_cell.x and
			cell.y >= existing_cell.y and
			cell.x < existing_cell.x + existing_size.x and
			cell.y < existing_cell.y + existing_size.y
		):
			return true
	return false

func occupied_cells(room_id: String) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for existing_id in placed_objects:
		var existing: Dictionary = placed_objects[existing_id]
		if existing.get("room_id") != room_id:
			continue
		var base: Vector2i = existing.get("cell")
		var size: Vector2i = existing.get("size")
		for x in range(base.x, base.x + size.x):
			for y in range(base.y, base.y + size.y):
				cells.append(Vector2i(x, y))
	return cells

func find_nearest_empty_cell(room_id: String, start_cell: Vector2i, size: Vector2i = Vector2i.ONE, rotation: int = 0, max_radius: int = 8) -> Dictionary:
	for radius in range(0, max_radius + 1):
		for x in range(start_cell.x - radius, start_cell.x + radius + 1):
			for y in range(start_cell.y - radius, start_cell.y + radius + 1):
				var candidate := Vector2i(x, y)
				var check := can_place(room_id, "probe", candidate, size, rotation)
				if bool(check.get("ok", false)):
					return {"ok": true, "message": "Found empty cell.", "cell": candidate}
	return {"ok": false, "message": "No empty cell found nearby."}

func place_object(room_id: String, object_id: String, cell: Vector2i, size: Vector2i, rotation: int = 0) -> Dictionary:
	var check := can_place(room_id, object_id, cell, size, rotation)
	if not bool(check.get("ok", false)):
		return check
	var instance_id := "%s_%03d" % [object_id, _next_instance_id]
	_next_instance_id += 1
	placed_objects[instance_id] = {
		"object_id": object_id,
		"room_id": room_id,
		"cell": cell,
		"size": _rotated_size(size, rotation),
		"rotation": rotation
	}
	return {"ok": true, "message": "Placed %s." % object_id, "instance_id": instance_id}

func can_place_placeable(room_id: String, placeable_id: String, cell: Vector2i, rotation: int = 0) -> Dictionary:
	var placeable := _get_placeable(placeable_id)
	if placeable.is_empty():
		return {"ok": false, "message": "Unknown placeable: %s." % placeable_id}
	if not _is_room_allowed(placeable, room_id):
		return {"ok": false, "message": "%s cannot be placed in %s." % [placeable_id, room_id]}
	var size := _size_from_data(placeable.get("size", [1, 1]))
	return can_place(room_id, placeable_id, cell, size, rotation)

func place_placeable(room_id: String, placeable_id: String, cell: Vector2i, rotation: int = 0) -> Dictionary:
	var check := can_place_placeable(room_id, placeable_id, cell, rotation)
	if not bool(check.get("ok", false)):
		return check
	var placeable := _get_placeable(placeable_id)
	var size := _size_from_data(placeable.get("size", [1, 1]))
	return place_object(room_id, placeable_id, cell, size, rotation)

func remove_object(object_id: String) -> bool:
	return placed_objects.erase(object_id)

func cell_to_world(room_id: String, cell: Vector2i) -> Vector2:
	var room: Dictionary = room_bounds.get(room_id, {})
	var origin: Vector2i = room.get("origin", Vector2i.ZERO)
	return Vector2(origin + cell) * CELL_SIZE

func _inside_room(room_id: String, cell: Vector2i, size: Vector2i) -> bool:
	var room: Dictionary = room_bounds[room_id]
	var room_size: Vector2i = room.get("size", Vector2i.ZERO)
	return cell.x >= 0 and cell.y >= 0 and cell.x + size.x <= room_size.x and cell.y + size.y <= room_size.y

func _rotated_size(size: Vector2i, rotation: int) -> Vector2i:
	var normalized := ((rotation % 360) + 360) % 360
	if normalized == 90 or normalized == 270:
		return Vector2i(size.y, size.x)
	return size

func _rects_overlap(a_pos: Vector2i, a_size: Vector2i, b_pos: Vector2i, b_size: Vector2i) -> bool:
	return (
		a_pos.x < b_pos.x + b_size.x and
		a_pos.x + a_size.x > b_pos.x and
		a_pos.y < b_pos.y + b_size.y and
		a_pos.y + a_size.y > b_pos.y
	)

func _get_placeable(placeable_id: String) -> Dictionary:
	if has_node("/root/DataLibrary") and DataLibrary.has_method("get_placeable"):
		return DataLibrary.get_placeable(placeable_id)
	return {}

func _is_room_allowed(placeable: Dictionary, room_id: String) -> bool:
	var allowed: Array = placeable.get("allowed_rooms", [])
	return allowed.is_empty() or room_id in allowed

func _size_from_data(size_data: Variant) -> Vector2i:
	if size_data is Array and size_data.size() >= 2:
		return Vector2i(int(size_data[0]), int(size_data[1]))
	if size_data is Dictionary:
		return Vector2i(int(size_data.get("x", 1)), int(size_data.get("y", 1)))
	return Vector2i.ONE
