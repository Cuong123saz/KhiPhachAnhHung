@tool
class_name TopItems
extends RefCounted
## Tops: 1 is the cloth shirt, 2 is the long robe.


static func layers(option: int, accent: Color) -> Dictionary:
	var chest: Array = []
	var upper: Array = []
	var lower: Array = []
	var skirt: Array = []
	var covers: Array = []
	if option == 1:
		var color := Color("41608a")
		chest = [[MaleBody.torso_points(8.5, 8.5, 6.0), color], [Ink.rect(-8.5, -1.0, 17.0, 3.0), accent]]
		upper = [Ink.limb(8.5, 7.6, 7.0, color)]
		covers = ["Chest", "ArmNear", "ArmFar"]
	elif option == 2:
		var color := Color("2f8a86")
		chest = [[MaleBody.torso_points(9.0, 9.0, 3.0), color], [Ink.rect(-9.0, -3.0, 18.0, 3.0), accent]]
		upper = [Ink.limb(8.5, 7.8, 7.8, color)]
		lower = [Ink.limb(8.5, 7.4, 7.0, Color("277572"))]
		var hem := PackedVector2Array([Vector2(-8, -3), Vector2(8, -3), Vector2(12, 18), Vector2(-12, 18)])
		skirt = [[hem, color]]
		covers = ["Chest", "ArmNear", "ArmFar", "ForeNear", "ForeFar"]
	return {
		"shapes": {
			"Chest": chest, "Skirt": skirt, "ArmNear": upper, "ArmFar": upper, "ForeNear": lower, "ForeFar": lower,
		},
		"covers": covers,
	}
