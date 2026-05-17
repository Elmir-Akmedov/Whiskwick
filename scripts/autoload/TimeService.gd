extends Node

signal time_changed(minutes: int)
signal phase_changed(phase: String)

const PHASE_PREP := "Morning Prep"
const PHASE_OPEN := "Shop Open"
const PHASE_CLOSED := "Closed / Night Prep"
const PHASE_EXHAUSTED := "Exhausted Night"

const START_MINUTES := 7 * 60
const OPEN_MINUTES := 10 * 60
const CLOSE_MINUTES := 19 * 60
const EXHAUSTED_MINUTES := 22 * 60
const END_MINUTES := 24 * 60

var current_minutes: int = START_MINUTES
var current_phase: String = PHASE_PREP
var seconds_per_game_minute: float = 0.35
var _accumulator: float = 0.0

func reset_day() -> void:
	current_minutes = START_MINUTES
	current_phase = PHASE_PREP
	_accumulator = 0.0
	emit_signal("time_changed", current_minutes)
	emit_signal("phase_changed", current_phase)

func tick(delta: float) -> void:
	_accumulator += delta
	while _accumulator >= seconds_per_game_minute:
		_accumulator -= seconds_per_game_minute
		advance_minutes(1)

func advance_minutes(amount: int) -> void:
	current_minutes = min(current_minutes + amount, END_MINUTES)
	emit_signal("time_changed", current_minutes)
	_update_phase()

func skip_to_next_milestone() -> void:
	var target := END_MINUTES
	if current_minutes < OPEN_MINUTES:
		target = OPEN_MINUTES
	elif current_minutes < CLOSE_MINUTES:
		target = CLOSE_MINUTES
	elif current_minutes < EXHAUSTED_MINUTES:
		target = EXHAUSTED_MINUTES
	current_minutes = target
	emit_signal("time_changed", current_minutes)
	_update_phase()

func is_shop_open() -> bool:
	return current_minutes >= OPEN_MINUTES and current_minutes < CLOSE_MINUTES

func format_minutes(minutes: int) -> String:
	var hour := int(minutes / 60)
	var minute := minutes % 60
	return "%02d:%02d" % [hour, minute]

func _update_phase() -> void:
	var next_phase := PHASE_PREP
	if current_minutes >= EXHAUSTED_MINUTES:
		next_phase = PHASE_EXHAUSTED
	elif current_minutes >= CLOSE_MINUTES:
		next_phase = PHASE_CLOSED
	elif current_minutes >= OPEN_MINUTES:
		next_phase = PHASE_OPEN
	if next_phase != current_phase:
		current_phase = next_phase
		emit_signal("phase_changed", current_phase)
