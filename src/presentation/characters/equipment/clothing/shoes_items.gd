@tool
class_name ShoesItems
extends RefCounted
## Shoes.


static func layers(option: int) -> Dictionary:
	if option != 1:
		return {"shapes": {}, "covers": []}
	var shoe := [[MaleBody.foot_points(6.5), Color("33291f")]]
	return {"shapes": {"FootNear": shoe, "FootFar": shoe}, "covers": []}
