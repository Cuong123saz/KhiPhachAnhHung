class_name MoveBuilder
extends RefCounted
## Turns tables of key poses into animations. Only the build tool uses this.
##
## Angles are degrees, positive clockwise. A hanging limb swings forward (+x) at negative
## angles, a knee bends at positive angles, an elbow at negative ones.
##
## Track codes: N = near side, F = far side. T thigh, S shin, F foot, U upper arm, L forearm,
## H hand. CH chest, HD head, HP hips height, CS chest scale, AS arm stretch, WP weapon
## slide in the hand, GRIP second hand on the weapon, MOOD face.

const HIPS_Y := -22.0
const TRACKS := {
	"NT": "Flip/Hips/ThighNear:rotation", "NS": "Flip/Hips/ThighNear/ShinNear:rotation",
	"NF": "Flip/Hips/ThighNear/ShinNear/FootNear:rotation",
	"FT": "Flip/Hips/ThighFar:rotation", "FS": "Flip/Hips/ThighFar/ShinFar:rotation",
	"FF": "Flip/Hips/ThighFar/ShinFar/FootFar:rotation",
	"NU": "Flip/Hips/Chest/ArmNear:rotation", "NL": "Flip/Hips/Chest/ArmNear/ForeNear:rotation",
	"NH": "Flip/Hips/Chest/ArmNear/ForeNear/HandNear:rotation",
	"FU": "Flip/Hips/Chest/ArmFar:rotation", "FL": "Flip/Hips/Chest/ArmFar/ForeFar:rotation",
	"CH": "Flip/Hips/Chest:rotation", "HD": "Flip/Hips/Chest/Head:rotation",
	"HP": "Flip/Hips:position", "CS": "Flip/Hips/Chest:scale",
	"ARC": "Flip/Hips/Chest/SwingArc:visible",
	"AS": "Flip/Hips/Chest/ArmNear:scale",
	"WP": "Flip/Hips/Chest/ArmNear/ForeNear/HandNear/Weapon:position",
	"DISC": "Flip/Hips/Chest/ArmNear/ForeNear/HandNear/SpinDisc:visible",
	"GLOW": "Flip/Hips/Chest/ArmNear/ForeNear/HandNear/Weapon/Glow:visible",
	"GS": "Flip/Hips/Chest/ArmNear/ForeNear/HandNear/Weapon/Glow:scale",
	"RING": "Flip/GroundRing:visible",
	"RS": "Flip/GroundRing:scale",
	"WATER": "Flip/WaterRise:visible",
	"WS": "Flip/WaterRise:scale",
	"GRIP": ".:far_grip",
	"MOOD": ".:face_mood",
}

# Tracks by how they interpolate; every other track is a rotation.
const DISCRETE := ["ARC", "DISC", "GLOW", "RING", "WATER", "MOOD"]
const LINEAR := ["GRIP", "WP", "AS", "GS", "RS", "WS"]
const VECTOR_FROM_NUMBER := ["AS", "GS", "RS", "WS"]

## poses: [[seconds, {track code: value}], ...]
static func animation(length: float, looped: bool, poses: Array, raw_rotation: Array = []) -> Animation:
	var result := Animation.new()
	result.length = length
	result.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	var indices := {}
	for entry: Array in poses:
		var pose: Dictionary = entry[1]
		for code: String in pose:
			if not indices.has(code):
				var track := result.add_track(Animation.TYPE_VALUE)
				result.track_set_path(track, NodePath(TRACKS[code]))
				if code in DISCRETE:
					result.value_track_set_update_mode(track, Animation.UPDATE_DISCRETE)
					result.track_set_interpolation_type(track, Animation.INTERPOLATION_NEAREST)
				elif code in LINEAR or code in raw_rotation:
					result.track_set_interpolation_type(track, Animation.INTERPOLATION_LINEAR)
				elif code == "HP" or code == "CS":
					result.track_set_interpolation_type(track, Animation.INTERPOLATION_CUBIC)
				else:
					result.track_set_interpolation_type(track, Animation.INTERPOLATION_CUBIC_ANGLE)
				indices[code] = track
			result.track_insert_key(indices[code], entry[0], _key_value(code, pose[code]))
	return result


static func _key_value(code: String, value: Variant) -> Variant:
	match code:
		"HP":
			return Vector2(0.0, HIPS_Y + float(value))
		"WP":
			return Vector2(0.0, float(value))
		"GRIP":
			return float(value)
		"CS", "ARC", "DISC", "GLOW", "RING", "WATER", "MOOD":
			return value
	if code in VECTOR_FROM_NUMBER:
		return Vector2(float(value), float(value))
	return deg_to_rad(float(value))
