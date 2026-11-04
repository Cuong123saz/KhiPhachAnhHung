@tool
class_name FaceShapes
extends RefCounted
## Face styles, drawn between the skin and the hair. Only the front view has a face.

const STYLES := ["Mắt chấm", "Mắt to", "Nét mực", "Rối gỗ"]
const DARK := Color("2b211c")


static func shapes(style: int, closed: bool, shouting: bool) -> Array:
	var result: Array = []
	if style == 3:
		for x: float in [-3.0, 9.0]:
			result.append([Ink.ellipse(Vector2(x, -4.0), 2.4, 1.8, 0.0, 360.0, 12), Color("e79a84"), 0.0])
	# The far eye is narrower: this is what turns the head 3/4.
	_add_eye(result, style, Vector2(-0.5, -7.5), 1.0, closed)
	_add_eye(result, style, Vector2(7.0, -7.5), 0.8, closed)
	_add_mouth(result, style, shouting)
	return result


static func _add_eye(result: Array, style: int, at: Vector2, width: float, closed: bool) -> void:
	if closed:
		result.append(_stroke(at + Vector2(-2.4 * width, 0.0), at + Vector2(2.4 * width, 0.0), 1.1))
		return
	match style:
		0:
			result.append([Ink.ellipse(at, 1.8 * width, 2.7, 0.0, 360.0, 12), DARK, 0.0])
		1:
			result.append([Ink.ellipse(at, 2.9 * width, 3.6, 0.0, 360.0, 14), Color("fdf6e8"), 0.0])
			result.append([Ink.ellipse(at + Vector2(0.6, 0.3), 1.9 * width, 2.9, 0.0, 360.0, 12), DARK, 0.0])
			result.append([Ink.ellipse(at + Vector2(0.0, -1.0), 0.7, 0.8, 0.0, 360.0, 8), Color.WHITE, 0.0])
			result.append(_stroke(at + Vector2(-2.6 * width, -4.3), at + Vector2(2.6 * width, -4.6), 0.9))
		2:
			result.append(_stroke(at + Vector2(-3.0 * width, -1.2), at + Vector2(3.0 * width, -1.8), 1.5))
			result.append([Ink.ellipse(at + Vector2(0.3, 0.1), 1.3 * width, 1.7, 0.0, 360.0, 10), DARK, 0.0])
			result.append(_stroke(at + Vector2(-3.0 * width, -4.6), at + Vector2(3.0 * width, -3.8), 1.2))
		3:
			result.append([Ink.ellipse(at, 2.0 * width, 1.3, 0.0, 360.0, 12), DARK, 0.0])
			result.append(_stroke(at + Vector2(-2.6 * width, -3.0), at + Vector2(0.0, -4.2), 0.8))
			result.append(_stroke(at + Vector2(0.0, -4.2), at + Vector2(2.6 * width, -3.0), 0.8))


static func _add_mouth(result: Array, style: int, shouting: bool) -> void:
	var at := Vector2(3.8, -2.6)
	if shouting:
		result.append([Ink.ellipse(at, 1.9, 2.3, 0.0, 360.0, 12), Color("5a2320"), 0.0])
	elif style == 3:
		result.append([Ink.ellipse(at, 1.5, 1.0, 0.0, 360.0, 10), Color("b5362b"), 0.0])
	else:
		result.append(_stroke(at + Vector2(-1.5, 0.0), at + Vector2(1.5, -0.2), 0.8))


static func _stroke(from: Vector2, to: Vector2, thickness: float) -> Array:
	var side := (to - from).orthogonal().normalized() * thickness / 2.0
	return [PackedVector2Array([from + side, to + side, to - side, from - side]), DARK, 0.0]
