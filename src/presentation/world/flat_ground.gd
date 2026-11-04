class_name FlatGround
extends Node2D
## Quiet ground: big flat masses, almost no texture. The eye should slide over this
## and follow the road to the clearing around the banyan.

const EARTH := Color("b8a57f")
const FIELD := Color("93a16b")
const FIELD_LINE := Color("85935f")
const WATER := Color("6f9c9b")
const ROAD := Color("d3c198")
const CLEARING := Color("e6d6ae")

const FIELDS := [
	[Vector2(0, 0), Vector2(620, 0), Vector2(520, 520), Vector2(0, 620)],
	[Vector2(0, 760), Vector2(520, 700), Vector2(700, 860), Vector2(240, 1160), Vector2(0, 1240)],
	[Vector2(760, 1120), Vector2(1360, 980), Vector2(1560, 1400), Vector2(860, 1400)],
	[Vector2(760, 0), Vector2(1240, 0), Vector2(1160, 300), Vector2(720, 360)],
]
const CANAL := [Vector2(2010, 0), Vector2(1960, 420), Vector2(2060, 820), Vector2(1880, 1120), Vector2(1920, 1400)]
const ROAD_PATH := [
	Vector2(120, 1400), Vector2(420, 1220), Vector2(760, 1000), Vector2(1100, 790),
	Vector2(1250, 720), Vector2(1450, 710),
]
const CLEARING_CENTER := Vector2(1560, 690)


func _draw() -> void:
	draw_rect(Rect2(0, 0, MovementConfig.WORLD_WIDTH, MovementConfig.WORLD_HEIGHT), EARTH)
	for field: Array in FIELDS:
		var points := PackedVector2Array(field)
		draw_colored_polygon(points, FIELD)
		# A few long furrows, only enough to read as a field.
		for t in [0.33, 0.66]:
			draw_line(points[0].lerp(points[3], t), points[1].lerp(points[2], t), FIELD_LINE, 3.0, true)
	_draw_path(CANAL, 64.0, WATER)
	_draw_path(ROAD_PATH, 62.0, ROAD)
	draw_colored_polygon(Ink.ellipse(CLEARING_CENTER, 300.0, 170.0, 0.0, 360.0, 48), CLEARING)


func _draw_path(path: Array, width: float, color: Color) -> void:
	for i in path.size():
		var point: Vector2 = path[i]
		draw_circle(point, width / 2.0, color)
		if i > 0:
			draw_line(path[i - 1], point, color, width)
