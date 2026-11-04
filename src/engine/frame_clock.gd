class_name FrameClock
extends RefCounted
## Port of smoothDelta() in Phaser's TimeStep. The game moves by this value, not
## by the raw frame time, so a hitch is spread over 10 frames.
##
## Kept as Phaser has it: for 120 frames after start or refocus, and while the
## window is unfocused, each frame is capped at 1/60 s. Below 60 FPS the game
## therefore runs slow during those periods, in both engines.

const TARGET_MS := 1000.0 / 60.0
const MAX_MS := 200.0 # fps.min defaults to 5.
const SMOOTHING_FRAMES := 10
const PANIC_FRAMES := 120

var cool_down := PANIC_FRAMES
var in_focus := true

var _history := PackedFloat64Array()
var _index := 0


func _init() -> void:
	_history.resize(SMOOTHING_FRAMES)
	_history.fill(TARGET_MS)


func reset() -> void:
	for i in SMOOTHING_FRAMES:
		_history[i] = minf(TARGET_MS, _history[i])
	_index = 0
	cool_down = PANIC_FRAMES


func blur() -> void:
	in_focus = false


func focus() -> void:
	in_focus = true
	reset()


func set_history(values: Array) -> void:
	for i in SMOOTHING_FRAMES:
		_history[i] = values[i]


func step(raw_ms: float) -> float:
	var delta := raw_ms
	if cool_down > 0 or not in_focus:
		cool_down -= 1
		delta = minf(delta, TARGET_MS)
	if delta > MAX_MS:
		# Probably a stall: reuse the last sane value.
		delta = minf(_history[_index], MAX_MS)
	_history[_index] = delta
	_index = (_index + 1) % SMOOTHING_FRAMES
	var total := 0.0
	for value in _history:
		total += value
	return total / SMOOTHING_FRAMES
