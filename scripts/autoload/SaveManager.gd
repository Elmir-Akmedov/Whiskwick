extends Node

const SAVE_PATH := "user://save.json"

func save_game() -> Dictionary:
	var payload := {
		"coins": GameState.coins,
		"xp": GameState.xp,
		"shop_level": GameState.shop_level,
		"reputation": GameState.reputation,
		"current_day": GameState.current_day,
		"menu_state": MenuManager.export_state(),
		"upgrade_state": UpgradeManager.export_state(),
		"last_save_unix": int(Time.get_unix_time_from_system())
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Failed to open save file for writing."}
	file.store_string(JSON.stringify(payload))
	print("Save successful")
	return {"ok": true}

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"ok": false, "message": "Save file not found."}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {"ok": false, "message": "Failed to open save file for reading."}
	var text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "message": "Save payload is invalid."}
	var data: Dictionary = parsed
	GameState.apply_save_data(data)
	if data.has("menu_state") and typeof(data["menu_state"]) == TYPE_DICTIONARY:
		MenuManager.import_state(data["menu_state"])
	if data.has("upgrade_state") and typeof(data["upgrade_state"]) == TYPE_DICTIONARY:
		UpgradeManager.import_state(data["upgrade_state"])
	_apply_idle_earnings(data)
	print("Load successful")
	return {"ok": true}

func test_save_load() -> void:
	var save_result := save_game()
	if not bool(save_result.get("ok", false)):
		push_error(str(save_result.get("message", "Save failed.")))
		return
	var load_result := load_game()
	if not bool(load_result.get("ok", false)):
		push_error(str(load_result.get("message", "Load failed.")))

func _apply_idle_earnings(data: Dictionary) -> void:
	if not UpgradeManager.idle_earning_enabled:
		return
	if not data.has("last_save_unix"):
		return
	var last_save_unix: int = int(data["last_save_unix"])
	if last_save_unix <= 0:
		return
	var now_unix: int = int(Time.get_unix_time_from_system())
	var elapsed_seconds: int = max(0, now_unix - last_save_unix)
	var capped_seconds: int = min(elapsed_seconds, 3600)
	var elapsed_minutes: int = int(floor(float(capped_seconds) / 60.0))
	if elapsed_minutes <= 0:
		return
	var idle_rate: int = max(1, GameState.shop_level * 2)
	var idle_coins: int = elapsed_minutes * idle_rate
	GameState.earn_money(idle_coins)
	UIManager.show_toast("You were away for %d minutes! Earned %d coins while you slept." % [elapsed_minutes, idle_coins])
