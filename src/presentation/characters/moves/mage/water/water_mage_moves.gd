class_name WaterMageMoves
extends RefCounted
## Pháp Sư hệ Thủy: staff grip and skill moves. Add a sibling folder for another element.

const STANCE_START := {
	"NU": -32.0, "NL": -40.0, "NH": 112.0, "CH": 2.0, "HD": 0.0, "HP": 1.2,
	"NT": -22.0, "NS": 18.0, "NF": 0.0, "FT": 18.0, "FS": 12.0, "FF": 0.0,
	"AS": 1.0, "GRIP": 0.0, "WP": 0.0,
}
const HOLD_STAFF := {"NU": -32.0, "NL": -40.0, "NH": 112.0}


static func all() -> Dictionary:
	return {
		"hold_staff": MoveBuilder.animation(0.1, true, [[0.0, HOLD_STAFF]]),
		"swing_staff": _swing_staff(),
		"skill_spin": _skill_spin(),
		"skill_raise": _skill_raise(),
		"skill_slam": _skill_slam(),
	}


## A sideways sweep: charge -> wide horizontal release -> short recoil.
## GLOW is a visual cue only; the real water projectile must be spawned by combat code.
static func _swing_staff() -> Animation:
	return MoveBuilder.animation(0.52, false, [
		[0.0, {"NU": -32.0, "NL": -40.0, "NH": 112.0, "CH": 2.0, "HD": 0.0,
			"WP": 0.0, "GLOW": false, "GS": 0.5}],
		# Wind-up: draw the head of the staff across the body
		[0.12, {"NU": -54.0, "NL": -58.0, "NH": 72.0, "CH": -7.0, "HD": 4.0,
			"WP": -4.0, "GS": 0.8}],
		# Fast lateral swipe, strongest pose at ~0.24s
		[0.24, {"NU": -113.0, "NL": -10.0, "NH": 164.0, "CH": 8.0, "HD": -4.0,
			"WP": 9.0, "GLOW": true, "GS": 1.6}],
		# Hold release a fraction; gameplay should fire water at this moment
		[0.28, {"NU": -118.0, "NL": -7.0, "NH": 170.0, "CH": 8.0, "HD": -4.0,
			"WP": 10.0, "GS": 1.7}],
		[0.30, {"GLOW": false}],
		# Recover, avoiding an instant snap
		[0.40, {"NU": -72.0, "NL": -26.0, "NH": 135.0, "CH": 3.0, "HD": 0.0,
			"WP": 3.0, "GS": 0.8}],
		[0.52, {"NU": -32.0, "NL": -40.0, "NH": 112.0, "CH": 2.0, "HD": 0.0,
			"WP": 0.0, "GS": 0.5}],
	])


## E: a fast whirl. The staff stays centred in the hand (WP 14), so it turns about its
## middle. The hand rotation is raw degrees past 360, which is why NH is linear.
static func _skill_spin() -> Animation:
	return MoveBuilder.animation(0.95, false, [
		[0.0, {"NU": -32.0, "NL": -40.0, "NH": 112.0, "WP": 0.0,
			"FU": -6.0, "FL": -14.0, "DISC": false, "AS": 1.0, "CH": 2.0}],
		[0.09, {"NU": -60.0, "NL": -30.0, "NH": 145.0, "WP": 14.0,
			"FU": 24.0, "FL": -24.0, "AS": 1.2, "CH": -5.0}],
		[0.12, {"DISC": true}],
		[0.32, {"NU": -98.0, "NL": -5.0, "NH": 505.0, "FU": 40.0, "FL": -38.0, "CH": 6.0}],
		[0.54, {"NU": -72.0, "NL": -22.0, "NH": 865.0, "FU": 14.0, "FL": -34.0, "CH": -8.0}],
		[0.72, {"NU": -110.0, "NL": -8.0, "NH": 1010.0, "WP": 14.0, "FU": 30.0, "FL": -20.0, "CH": 8.0}],
		[0.75, {"DISC": false}],
		[0.95, {"NU": -32.0, "NL": -40.0, "NH": 1192.0, "WP": 0.0,
			"FU": -6.0, "FL": -14.0, "AS": 1.0, "CH": 2.0}],
	], ["NH"])


## Q: both hands higher up the shaft, raise and chant, then swing hard at the enemy.
## The hit itself belongs to gameplay code, at about 1.1 s.
static func _skill_raise() -> Animation:
	var start: Dictionary = STANCE_START.duplicate()
	start.merge({"GLOW": false, "GS": 0.5, "MOOD": 0, "ARC": false})
	# WP above 0 slides the staff down through the hands: the grip sits nearer the head.
	var chant := {"NU": -118.0, "NL": -16.0, "NH": 150.0, "AS": 1.15, "GRIP": 1.0, "WP": 6.0, "HP": -2.0, "CH": -4.0, "HD": -8.0}
	var rise: Dictionary = chant.duplicate()
	rise.merge({"NT": -8.0, "NS": 6.0, "NF": -15.0, "FT": 8.0, "FS": 6.0, "FF": 15.0})
	var strike := {"NU": -72.0, "NL": -6.0, "NH": 172.0, "AS": 1.25, "WP": 10.0, "HP": 3.0, "CH": 18.0, "HD": 2.0,
		"NT": -34.0, "NS": 34.0, "NF": 0.0, "FT": 30.0, "FS": 22.0, "FF": 10.0}
	return MoveBuilder.animation(1.65, false, [
		[0.0, start],
		[0.18, {"NU": -58.0, "NL": -47.0, "NH": 105.0, "GRIP": 1.0, "AS": 1.0, "WP": 6.0, "HP": 6.0, "CH": 14.0, "HD": 8.0,
			"NT": -32.0, "NS": 48.0, "NF": 0.0, "FT": 22.0, "FS": 48.0, "FF": 0.0}],
		[0.38, rise],
		[0.39, {"GLOW": true}],
		[0.7, {"GS": 1.5, "NU": -116.0, "HP": -2.5, "CH": -4.0}],
		[0.92, chant.merged({"GS": 1.7})],
		# Draw back a little further, then let it go.
		[1.02, {"NU": -140.0, "NL": -12.0, "NH": 150.0, "CH": -10.0, "HD": -4.0}],
		[1.03, {"MOOD": 1}],
		[1.06, {"ARC": true, "GLOW": false}],
		[1.12, strike],
		[1.2, {"ARC": false}],
		[1.3, strike.merged({"CH": 16.0})],
		[1.31, {"MOOD": 0}],
		[1.65, STANCE_START],
	])


## R: drive the staff down and stop dead, then the water rises, slowly growing stronger.
## The real ground impact and damage still belong to gameplay code.
static func _skill_slam() -> Animation:
	var start: Dictionary = STANCE_START.duplicate()
	start.merge({"RING": false, "RS": 0.5, "MOOD": 0, "WATER": false, "WS": 0.2})
	var strike := {"NU": -78.0, "NL": -4.0, "NH": 90.0, "AS": 1.15, "GRIP": 1.0, "HP": 4.0, "CH": 12.0, "HD": 2.0,
		"NT": -36.0, "NS": 62.0, "NF": 20.0, "FT": 28.0, "FS": 56.0, "FF": 10.0, "WP": 12.0}
	return MoveBuilder.animation(1.75, false, [
		[0.0, start],
		[0.18, {"NU": -130.0, "NL": -5.0, "NH": 140.0, "AS": 1.3, "GRIP": 1.0, "HP": -4.0, "CH": -5.0, "HD": -6.0,
			"NT": -10.0, "NS": 10.0, "FT": 5.0, "FS": 15.0, "WP": -6.0}],
		# Very fast down, then the exact same pose: this is the dead stop.
		[0.25, strike],
		[0.26, {"RING": true, "MOOD": 1}],
		[0.42, strike],
		[0.43, {"WATER": true, "MOOD": 0}],
		[0.8, {"WS": 0.6, "RS": 1.0}],
		[1.15, {"WS": 1.0, "RS": 1.4}],
		[1.45, strike.merged({"WS": 1.5, "RS": 1.8})],
		[1.46, {"WATER": false, "RING": false}],
		[1.75, STANCE_START],
	])
