@tool
class_name Staff
extends RefCounted
## Staff. (0, 0) is where the hand grips; negative y points to the head. The grip pose
## HOLD_STAFF and the skill moves are in moves/mage/water/. If the head moves, also update
## the Glow position in rig/tools/build_rig.gd.

const HOLD_ANIMATION := "hold_staff"
const SWING_ANIMATION := "swing_staff"


static func shapes() -> Array:
	return [
		# Cán trượng ngắn, màu xanh đậm
		[Ink.rect(-1.6, -23.0, 3.2, 32.0), Color("263d59")],

		# Viền vàng trên cán
		[Ink.rect(-1.8, -20.0, 3.6, 2.5), Color("e9ba65")],
		[Ink.rect(-1.8, 3.0, 3.6, 2.5), Color("e9ba65")],

		# Chóp cán dưới
		[Ink.ellipse(Vector2(0.0, 9.0), 2.6, 3.0, 0.0, 360.0, 16), Color("d9a64b")],

		# Khớp nối đầu trượng
		[Ink.ellipse(Vector2(0.0, -23.0), 4.2, 3.2, 0.0, 360.0, 20), Color("e9ba65")],

		# Hai cánh trang trí ôm ngọc
		[Ink.ellipse(Vector2(-5.0, -28.0), 2.4, 6.0, 0.0, 360.0, 20), Color("d9a64b")],
		[Ink.ellipse(Vector2(5.0, -28.0), 2.4, 6.0, 0.0, 360.0, 20), Color("d9a64b")],

		# Lõi ngọc Thủy
		[Ink.ellipse(Vector2(0.0, -30.0), 6.0, 6.0, 0.0, 360.0, 24), Color("176f91")],
		[Ink.ellipse(Vector2(0.0, -30.0), 4.8, 4.8, 0.0, 360.0, 24), Color("55d8e8")],

		# Điểm sáng trên ngọc
		[Ink.ellipse(Vector2(-1.8, -32.0), 1.5, 1.1, 0.0, 360.0, 16), Color("d8ffff")],

		# Giọt nước nhỏ phía trên
		[Ink.ellipse(Vector2(0.0, -38.0), 1.7, 2.5, 0.0, 360.0, 16), Color("88f5fa")],
	]
