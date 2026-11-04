@tool
class_name PantsItems
extends RefCounted
## Trousers.


static func layers(option: int) -> Dictionary:
	if option != 1:
		return {"shapes": {}, "covers": []}
	var color := Color("6b5a44")
	var thigh := [Ink.limb(10.5, 8.8, 7.8, color)]
	var shin := [Ink.limb(9.0, 7.8, 6.6, color)]
	return {
		"shapes": {
			"Hips": [[Ink.rect(-7.5, -3.0, 15.0, 8.0), color]],
			"ThighNear": thigh, "ThighFar": thigh, "ShinNear": shin, "ShinFar": shin,
		},
		"covers": ["ThighNear", "ThighFar", "ShinNear", "ShinFar"],
	}
