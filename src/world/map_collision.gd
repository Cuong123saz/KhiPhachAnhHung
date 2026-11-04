class_name MapCollision
extends RefCounted
## Port of movePlayer() and overlaps() from src/world/collision.ts, plus
## moveCharacter() from src/gameplay/characters/core/movement.ts.
##
## This replaces CharacterBody2D.move_and_slide() on purpose. The TypeScript
## solver sub-steps and retries each axis separately, so walking straight into a
## slanted wall stops the player, while move_and_slide() would project the motion
## along the surface. Coordinates stay in GDScript floats (64-bit) rather than
## Vector2 (32-bit) so results match the Phaser game.

var world_width: float
var world_height: float
## Same shape as PlacedObject in src/world/definitions.ts.
var obstacles: Array = []


func _init(width: float, height: float) -> void:
	world_width = width
	world_height = height


func move_character(
	x: float, y: float, dir_x: float, dir_y: float, seconds: float, speed: float, radius: float
) -> PackedFloat64Array:
	var scale := speed * seconds / maxf(1.0, sqrt(dir_x * dir_x + dir_y * dir_y))
	return move_player(x, y, dir_x * scale, dir_y * scale, radius)


func move_player(x: float, y: float, dx: float, dy: float, radius: float) -> PackedFloat64Array:
	# Small steps prevent crossing thin fences at low frame rates.
	var steps := maxi(1, ceili(sqrt(dx * dx + dy * dy) / (radius / 2.0)))
	var next_x := x
	var next_y := y
	var min_x := radius
	var max_x := world_width - radius
	var min_y := radius
	var max_y := world_height - radius
	for _i in steps:
		var try_x := maxf(min_x, minf(max_x, next_x + dx / steps))
		var try_y := maxf(min_y, minf(max_y, next_y + dy / steps))
		if is_clear(try_x, try_y, radius):
			next_x = try_x
			next_y = try_y
		else:
			# Order matters: the Y retry sees the X result. This is the wall slide.
			if is_clear(try_x, next_y, radius):
				next_x = try_x
			if is_clear(next_x, try_y, radius):
				next_y = try_y
	return PackedFloat64Array([next_x, next_y])


func is_clear(x: float, y: float, radius: float) -> bool:
	for object: Dictionary in obstacles:
		if overlaps(x, y, radius, object):
			return false
	return true


static func overlaps(px: float, py: float, radius: float, object: Dictionary) -> bool:
	var shape: Dictionary = object["shape"]
	var ox: float = object["x"]
	var oy: float = object["y"]
	match shape["type"]:
		"circle":
			var cx := px - ox
			var cy := py - oy
			return sqrt(cx * cx + cy * cy) < radius + float(shape["radius"])
		"rect":
			var ex := px - maxf(ox, minf(ox + float(shape["width"]), px))
			var ey := py - maxf(oy, minf(oy + float(shape["height"]), py))
			return sqrt(ex * ex + ey * ey) < radius
	var points: Array = shape["points"]
	var x := px - ox
	var y := py - oy
	var inside := false
	var j := points.size() - 1
	for i in points.size():
		var ax: float = points[i]["x"]
		var ay: float = points[i]["y"]
		var bx: float = points[j]["x"]
		var by: float = points[j]["y"]
		if (ay > y) != (by > y) and x < (bx - ax) * (y - ay) / (by - ay) + ax:
			inside = not inside
		var dx := bx - ax
		var dy := by - ay
		var length_sq := dx * dx + dy * dy
		if length_sq == 0.0:
			length_sq = 1.0
		var t := maxf(0.0, minf(1.0, ((x - ax) * dx + (y - ay) * dy) / length_sq))
		var near_x := x - ax - t * dx
		var near_y := y - ay - t * dy
		if sqrt(near_x * near_x + near_y * near_y) < radius:
			return true
		j = i
	return inside
