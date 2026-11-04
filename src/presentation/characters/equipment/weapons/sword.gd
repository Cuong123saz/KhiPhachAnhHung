@tool
class_name Sword
extends RefCounted
## Sword. (0, 0) is where the hand grips; negative y points to the tip. The grip pose
## HOLD_SWORD is in moves/swordsman/metal/.

const HOLD_ANIMATION := "hold_sword"
const SWING_ANIMATION := "swing_sword"


static func shapes() -> Array:
	var blade := PackedVector2Array([
		Vector2(-1.6, -3.0), Vector2(1.6, -3.0), Vector2(1.6, -25.0), Vector2(0.0, -29.0), Vector2(-1.6, -25.0)
	])
	return [
		[Ink.rect(-1.1, -2.0, 2.2, 6.0), Color("4a3524")],
		[blade, Color("d7dde0")],
		[Ink.rect(-4.0, -4.0, 8.0, 2.6), Color("c29a3f")],
	]
