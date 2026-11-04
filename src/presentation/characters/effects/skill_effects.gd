@tool
class_name SkillEffects
extends RefCounted
## Looks of the effects that animations switch on and off.


static func swing_arc() -> Array:
	var points := Ink.ellipse(Vector2.ZERO, 46.0, 46.0, -70.0, 50.0, 14)
	points.append_array(Ink.ellipse(Vector2(-6.0, 0.0), 40.0, 42.0, 50.0, -70.0, 14))
	return [[points, Color(1.0, 0.98, 0.85, 0.7), 0.0]]


static func ground_ring() -> Array:
	return [[Ink.ellipse(Vector2.ZERO, 26.0, 9.0), Color(0.75, 0.95, 0.95, 0.5), 0.0]]


## Grows upward from its origin on the ground.
static func water_rise() -> Array:
	var outer := PackedVector2Array([
		Vector2(-13, 0), Vector2(-8, -18), Vector2(-3, -40), Vector2(0, -52), Vector2(3, -40), Vector2(8, -18), Vector2(13, 0)
	])
	var inner := PackedVector2Array([
		Vector2(-6, 0), Vector2(-3, -16), Vector2(0, -34), Vector2(3, -16), Vector2(6, 0)
	])
	return [
		[Ink.ellipse(Vector2(-15, -24), 2.0, 3.2, 0.0, 360.0, 10), Color(0.5, 0.9, 1.0, 0.8), 0.0],
		[Ink.ellipse(Vector2(15, -32), 1.6, 2.8, 0.0, 360.0, 10), Color(0.5, 0.9, 1.0, 0.8), 0.0],
		[outer, Color(0.3, 0.72, 0.9, 0.72), 0.0],
		[inner, Color(0.78, 0.97, 1.0, 0.85), 0.0],
	]


static func spin_disc() -> Array:
	return [[Ink.ellipse(Vector2.ZERO, 24.0, 24.0), Color(0.75, 0.95, 0.95, 0.18), 0.0]]


static func staff_glow() -> Array:
	return [[Ink.ellipse(Vector2.ZERO, 9.0, 9.0), Color(0.6, 1.0, 1.0, 0.55), 0.0]]
