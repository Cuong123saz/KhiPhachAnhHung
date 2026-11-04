@tool
class_name HairItems
extends RefCounted
## Hair and hats.

const HAIR := Color("2b211c")


static func layers(option: int, view_back: bool, accent: Color) -> Dictionary:
	var center := Vector2(0.0, -11.0)
	var head: Array = []
	var tail: Array = []
	if option == 1:
		head.append([Ink.ellipse(Vector2(-4.0, -25.0), 4.5, 4.5, 0.0, 360.0, 14), HAIR])
		tail = [Ink.limb(11.0, 3.0, 2.2, accent, 1.0)]
	if option != 0:
		if view_back:
			head.append([Ink.ellipse(center, 14.0, 13.0), HAIR])
		else:
			head.append([Ink.ellipse(center, 14.0, 13.0, 125.0, 200.0), HAIR])
			head.append([Ink.ellipse(center, 14.0, 13.0, 185.0, 355.0), HAIR])
	if option == 2:
		var brim := PackedVector2Array([Vector2(-21, -15), Vector2(21, -15), Vector2(0, -33)])
		head.append([brim, Color("d9c284")])
	return {"shapes": {"Head": head, "Tail": tail}, "covers": []}
