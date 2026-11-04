@tool
class_name EquipmentCatalog
extends RefCounted
## Every slot and what can go in it. Gear only changes looks, never collision or combat.
## Each item returns {"shapes": {bone: shapes}, "covers": [bones whose skin it hides]}.

const OPTIONS := {
	"hair": ["Trọc", "Búi tóc", "Nón lá"],
	"top": ["Không", "Áo vải", "Pháp bào"],
	"pants": ["Không", "Quần nâu"],
	"shoes": ["Không", "Giày"],
	"weapon": ["Không", "Kiếm", "Gậy phép"],
	"cape": ["Không", "Áo choàng"],
}
const STAFF_INDEX := 2


static func layers(slot: String, option: int, view_back: bool, accent: Color) -> Dictionary:
	match slot:
		"hair":
			return HairItems.layers(option, view_back, accent)
		"top":
			return TopItems.layers(option, accent)
		"pants":
			return PantsItems.layers(option)
		"shoes":
			return ShoesItems.layers(option)
		"cape":
			return CapeItems.layers(option)
		"weapon":
			return {"shapes": {"Weapon": _weapon_shapes(option)}, "covers": []}
	return {}


static func hold_animation(option: int) -> String:
	match option:
		1:
			return Sword.HOLD_ANIMATION
		2:
			return Staff.HOLD_ANIMATION
	return ""


static func swing_animation(option: int) -> String:
	match option:
		1:
			return Sword.SWING_ANIMATION
		2:
			return Staff.SWING_ANIMATION
	return ""


static func _weapon_shapes(option: int) -> Array:
	match option:
		1:
			return Sword.shapes()
		2:
			return Staff.shapes()
	return []
