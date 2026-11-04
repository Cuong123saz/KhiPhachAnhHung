@tool
class_name InkShapes
extends Node2D
## One body part or prop layer. In the real art each of these becomes a Sprite2D
## showing one drawn image; the rig around it stays the same.

var shapes: Array = []:
	set(value):
		shapes = value
		queue_redraw()


func _draw() -> void:
	for entry: Array in shapes:
		var width: float = entry[2] if entry.size() > 2 else 1.5
		if entry.size() > 3:
			# Open outline, see Ink.limb().
			draw_colored_polygon(entry[0], entry[1])
			draw_polyline(entry[3], Ink.OUTLINE, width, false)
		else:
			Ink.shape(self, entry[0], entry[1], width)
