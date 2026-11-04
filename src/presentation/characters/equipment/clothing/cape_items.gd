@tool
class_name CapeItems
extends RefCounted
## Capes. The rig decides whether a cape hangs behind or over the body.


static func layers(option: int) -> Dictionary:
	if option != 1:
		return {"shapes": {}, "covers": []}
	var shape := PackedVector2Array([Vector2(-7, 0), Vector2(7, 0), Vector2(11, 30), Vector2(-11, 30)])
	return {"shapes": {"Cape": [[shape, Color("8f2f2a")]]}, "covers": []}
