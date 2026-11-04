@tool
class_name TwoHandGrip
extends RefCounted
## Two-hand grips are solved rather than keyed: the second arm finds the shaft wherever
## the first hand took it, so a new two-handed move needs only the first arm animated.

# Second hand sits this far down the shaft from the first.
const OFFSET := 6.0
const MAX_STRETCH := 1.6


## Short chibi arms: the far arm stretches just enough to arrive.
static func solve(
	chest: Node2D, near_hand: Node2D, far_arm: Node2D, far_fore: Node2D, far_hand: Node2D,
	far_shoulder: Vector2, near_stretch: float, grip: float
) -> void:
	# The body turns toward the grip, bringing the far shoulder to the centre.
	far_arm.position = far_shoulder.lerp(Vector2(0.0, far_shoulder.y), grip)
	var target := chest.to_local(near_hand.to_global(Vector2(0.0, OFFSET)))
	var reach := target - far_arm.position
	var stretch := clampf(reach.length() / 16.0 * 1.001, near_stretch, MAX_STRETCH)
	far_arm.scale = Vector2(stretch, stretch)
	far_hand.scale = Vector2.ONE / stretch
	var segment := 8.0 * stretch
	var distance := minf(reach.length(), segment * 2.0 * 0.999)
	var bend := acos(distance / (segment * 2.0))
	far_arm.rotation = lerp_angle(far_arm.rotation, atan2(-reach.x, reach.y) + bend, grip)
	far_fore.rotation = lerp_angle(far_fore.rotation, -2.0 * bend, grip)
