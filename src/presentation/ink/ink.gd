@tool
class_name Ink
extends RefCounted
## Flat fill plus a dark outline: the placeholder look for this prototype.

const OUTLINE := Color("1c1712")


static func shape(canvas: CanvasItem, points: PackedVector2Array, fill: Color, width := 1.5) -> void:
	canvas.draw_colored_polygon(points, fill)
	if width <= 0.0:
		return
	var loop := points.duplicate()
	loop.append(points[0])
	canvas.draw_polyline(loop, OUTLINE, width, true)


static func rect(x: float, y: float, w: float, h: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x, y), Vector2(x + w, y), Vector2(x + w, y + h), Vector2(x, y + h)])


## Angles in degrees with y pointing down: 90 is bottom, 180 left, 270 top.
static func ellipse(
	center: Vector2, rx: float, ry: float, from_deg := 0.0, to_deg := 360.0, count := 28
) -> PackedVector2Array:
	var points := PackedVector2Array()
	var whole := is_equal_approx(to_deg - from_deg, 360.0)
	var steps := count if whole else count + 1
	for i in steps:
		var angle := deg_to_rad(lerpf(from_deg, to_deg, float(i) / float(count)))
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	return points


## A rounded limb hanging down from its joint at the origin. The top end has no
## outline, so the part above it reads as one continuous limb instead of two pieces.
static func limb(length: float, top_width: float, bottom_width: float, fill: Color, width := 1.5) -> Array:
	var top := top_width / 2.0
	var bottom := bottom_width / 2.0
	var end_cap := ellipse(Vector2(0.0, length), bottom, bottom, 0.0, 180.0, 8)
	var outline := PackedVector2Array([Vector2(top, 0.0)])
	outline.append_array(end_cap)
	outline.append(Vector2(-top, 0.0))
	var polygon := ellipse(Vector2.ZERO, top, top, 180.0, 360.0, 8)
	polygon.append_array(end_cap)
	return [polygon, fill, width, outline]
