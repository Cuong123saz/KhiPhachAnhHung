class_name MetalSwordsmanMoves
extends RefCounted
## Kiếm Khách hệ Kim: sword grip and swing.

const HOLD_SWORD := {"NU": -28.0, "NL": -52.0, "NH": 115.0}


static func all() -> Dictionary:
	return {
		"hold_sword": MoveBuilder.animation(0.1, true, [[0.0, HOLD_SWORD]]),
		"swing_sword": _swing_sword(),
	}


static func _swing_sword() -> Animation:
	return MoveBuilder.animation(0.45, false, [
		[0.0, {"NU": -28.0, "NL": -52.0, "NH": 115.0, "CH": 2.0, "HD": 0.0, "ARC": false}],
		[0.12, {"NU": -165.0, "NL": -25.0, "NH": 170.0, "CH": -10.0, "HD": 6.0}],
		[0.13, {"ARC": true}],
		[0.2, {"NU": -45.0, "NL": -12.0, "NH": 175.0, "CH": 16.0, "HD": -6.0}],
		[0.25, {"ARC": false}],
		[0.3, {"NU": -40.0, "NL": -15.0, "NH": 170.0, "CH": 14.0, "HD": -5.0}],
		[0.45, {"NU": -28.0, "NL": -52.0, "NH": 115.0, "CH": 2.0, "HD": 0.0}],
	])
