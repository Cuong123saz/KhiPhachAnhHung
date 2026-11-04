@tool
class_name MaleBody
extends RefCounted
## The bare male base body: what is left with no gear on. Clothing is drawn to fit these
## measurements. Faces live in body/face.

const SKIN := Color("d9b08c")
const SHORTS := Color("7d6a55")


## Bone name to shapes.
static func layers() -> Dictionary:
	var result := {
		"Hips": [[Ink.rect(-7.0, -3.0, 14.0, 7.0), SHORTS]],
		"Chest": [[torso_points(7.5, 7.0, 1.0), SKIN]],
		"Head": [[Ink.ellipse(Vector2(0.0, -11.0), 13.0, 12.0), SKIN]],
	}
	for side in ["Near", "Far"]:
		result["Thigh" + side] = [Ink.limb(10.0, 8.0, 7.0, SKIN)]
		result["Shin" + side] = [Ink.limb(9.0, 7.0, 5.8, SKIN)]
		result["Foot" + side] = [[foot_points(5.5), SKIN]]
		result["Arm" + side] = [Ink.limb(8.0, 6.6, 5.8, SKIN)]
		result["Fore" + side] = [Ink.limb(8.0, 5.8, 4.8, SKIN)]
		result["Hand" + side] = [[Ink.ellipse(Vector2.ZERO, 2.8, 2.8, 0.0, 360.0, 12), SKIN]]
	return result


static func torso_points(shoulder: float, waist: float, bottom: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-shoulder + 2.0, -17.0), Vector2(shoulder - 2.0, -17.0), Vector2(shoulder, -13.0),
		Vector2(waist, bottom), Vector2(-waist, bottom), Vector2(-shoulder, -13.0),
	])


static func foot_points(reach: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(-3.0, -1.0), Vector2(2.5, -1.0), Vector2(reach, 3.0), Vector2(-3.0, 3.0)])
