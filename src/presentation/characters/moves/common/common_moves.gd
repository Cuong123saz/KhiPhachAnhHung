class_name CommonMoves
extends RefCounted
## Moves every class shares: run, idle, stopping and the standing stance.

# 2 strides per second.
const RUN_SECONDS := 0.5
# One half of the stride, near leg leading. The other half swaps near and far.
const STRIDE := [
	{ # Contact: front foot lands, far arm reaches forward.
		"NT": -38.0, "NS": 12.0, "NF": 5.0, "FT": 34.0, "FS": 40.0, "FF": 20.0,
		"NU": 28.0, "NL": -35.0, "FU": -35.0, "FL": -55.0,
	},
	{ # Down: weight drops onto the front leg.
		"NT": -18.0, "NS": 22.0, "NF": 0.0, "FT": 18.0, "FS": 78.0, "FF": 15.0,
		"NU": 14.0, "NL": -45.0, "FU": -18.0, "FL": -60.0,
	},
	{ # Pass: back leg swings through under the body.
		"NT": 8.0, "NS": 12.0, "NF": 0.0, "FT": -22.0, "FS": 80.0, "FF": 10.0,
		"NU": -6.0, "NL": -55.0, "FU": 6.0, "FL": -65.0,
	},
	{ # Up: push off, body at its highest.
		"NT": 30.0, "NS": 20.0, "NF": 20.0, "FT": -40.0, "FS": 40.0, "FF": -5.0,
		"NU": -24.0, "NL": -55.0, "FU": 22.0, "FL": -50.0,
	},
]
const STRIDE_BODY := [
	{"HP": 0.0, "CH": 9.0, "HD": -4.0, "CS": Vector2(1.0, 0.98)},
	{"HP": 1.5, "CH": 11.0, "HD": -5.0, "CS": Vector2(1.03, 0.96)},
	{"HP": -1.0, "CH": 9.0, "HD": -3.0, "CS": Vector2(1.0, 1.0)},
	{"HP": -3.0, "CH": 8.0, "HD": -2.0, "CS": Vector2(0.98, 1.03)},
]
const REST := {
	"NT": -4.0, "NS": 6.0, "NF": 0.0, "FT": 6.0, "FS": 5.0, "FF": 0.0,
	"NU": 8.0, "NL": -12.0, "FU": -6.0, "FL": -14.0, "HD": 0.0,
}


static func all() -> Dictionary:
	return {"run": _run(), "idle": _idle(), "stop": _stop(), "stance": _stance()}


static func _run() -> Animation:
	var poses: Array = []
	var quarter := RUN_SECONDS / 8.0
	for half in 2:
		for i in STRIDE.size():
			var pose: Dictionary = STRIDE[i].duplicate()
			if half == 1:
				pose = _swap_sides(pose)
			pose.merge(STRIDE_BODY[i])
			poses.append([quarter * (half * 4 + i), pose])
	return MoveBuilder.animation(RUN_SECONDS, true, poses)


static func _swap_sides(pose: Dictionary) -> Dictionary:
	var swapped := {}
	for key: String in pose:
		var side := "F" if key[0] == "N" else "N"
		swapped[side + key[1]] = pose[key]
	return swapped


static func _idle() -> Animation:
	var settled: Dictionary = REST.duplicate()
	settled.merge({"HP": 0.0, "CH": 1.0, "CS": Vector2(1.0, 1.0)})
	var breath: Dictionary = REST.duplicate()
	breath.merge({"HP": 0.5, "CH": 2.0, "CS": Vector2(1.0, 1.02)})
	return MoveBuilder.animation(1.6, true, [[0.0, settled], [0.8, breath]])


## Weight carries forward for a moment after the player lets go.
static func _stop() -> Animation:
	var settled: Dictionary = REST.duplicate()
	settled.merge({"HP": 0.0, "CH": 1.0, "CS": Vector2(1.0, 1.0)})
	var carried := {
		"NT": -14.0, "NS": 14.0, "NF": 0.0, "FT": 14.0, "FS": 22.0, "FF": 0.0,
		"NU": -14.0, "NL": -30.0, "FU": 16.0, "FL": -30.0, "HD": -4.0,
		"HP": 1.5, "CH": 14.0, "CS": Vector2(1.02, 0.97),
	}
	return MoveBuilder.animation(0.25, false, [[0.0, carried], [0.25, settled]])


static func _stance() -> Animation:
	var pose := {
		"NT": -22.0, "NS": 18.0, "NF": 0.0, "FT": 18.0, "FS": 12.0, "FF": 0.0,
		"FU": 24.0, "FL": -35.0, "HP": 1.2, "CS": Vector2(1.0, 1.0),
	}
	return MoveBuilder.animation(0.1, true, [[0.0, pose]])
