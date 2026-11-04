class_name MoveInput
extends RefCounted
## Digital move keys into a direction, as in MainScene.update(). Opposite keys cancel, and
## a diagonal has the same length as a straight line.


static func direction_from_keys(left: bool, right: bool, up: bool, down: bool) -> PackedFloat64Array:
	var x := float(right) - float(left)
	var y := float(down) - float(up)
	var length_sq := x * x + y * y
	if length_sq > 0.0:
		var inverse := 1.0 / sqrt(length_sq)
		x *= inverse
		y *= inverse
	return PackedFloat64Array([x, y])
