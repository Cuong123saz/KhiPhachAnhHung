@tool
class_name SpringMotion
extends RefCounted
## Makes a cape, skirt or ribbon lag behind the body instead of being animated.

const STIFFNESS := 90.0
const DAMPING := 9.0

var angle := 0.0
var velocity := 0.0


func step(delta: float, target: float) -> float:
	var remaining := delta
	while remaining > 0.0:
		var slice := minf(remaining, 1.0 / 120.0)
		velocity += ((target - angle) * STIFFNESS - velocity * DAMPING) * slice
		angle += velocity * slice
		remaining -= slice
	return angle
