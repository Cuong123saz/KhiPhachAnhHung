class_name VillageProp
extends Node2D
## One object standing on the ground. Its origin is where it touches the ground, so
## Y-sorting decides whether the player walks in front of it or behind it.

const FADE_PER_SECOND := 4.0
const CANOPY_FADED := 0.45

var kind := "bamboo"
var player: Node2D

var _canopy: InkShapes


func _ready() -> void:
	if kind == "banyan":
		_canopy = InkShapes.new()
		_canopy.shapes = _canopy_shapes()
		add_child(_canopy)
	else:
		set_process(false)
	queue_redraw()


## See-through only while the player stands behind the canopy, or they would vanish.
func _process(delta: float) -> void:
	if player == null:
		return
	var offset := player.position - position
	var behind := offset.y < 0.0 and absf(offset.x) < 190.0 and offset.y > -300.0
	var target := CANOPY_FADED if behind else 1.0
	_canopy.modulate.a = move_toward(_canopy.modulate.a, target, FADE_PER_SECOND * delta)


func canopy_alpha() -> float:
	return _canopy.modulate.a if _canopy else 1.0


## Same format as PlacedObject, in world coordinates.
func obstacle() -> Dictionary:
	var at := position
	match kind:
		"banyan":
			return _circle(at, 34.0)
		"shrine":
			return _rect(at + Vector2(-24.0, -14.0), Vector2(48.0, 14.0))
		"house":
			return _rect(at + Vector2(-60.0, -24.0), Vector2(120.0, 24.0))
		"fence":
			return _rect(at + Vector2(-50.0, -6.0), Vector2(100.0, 6.0))
	return _circle(at, 14.0)


func _circle(at: Vector2, radius: float) -> Dictionary:
	return {"kind": "obstacle", "x": at.x, "y": at.y, "shape": {"type": "circle", "radius": radius}}


func _rect(at: Vector2, size: Vector2) -> Dictionary:
	return {"kind": "obstacle", "x": at.x, "y": at.y, "shape": {"type": "rect", "width": size.x, "height": size.y}}


func _draw() -> void:
	match kind:
		"banyan":
			_draw_banyan_trunk()
		"shrine":
			_draw_shrine()
		"house":
			_draw_house()
		"fence":
			_draw_fence()
		_:
			_draw_bamboo()


func _draw_shadow(rx: float, ry: float) -> void:
	draw_colored_polygon(Ink.ellipse(Vector2.ZERO, rx, ry, 0.0, 360.0, 24), Color(0.12, 0.1, 0.05, 0.25))


func _draw_banyan_trunk() -> void:
	_draw_shadow(120.0, 34.0)
	var bark := Color("4b3526")
	Ink.shape(self, PackedVector2Array([Vector2(-78, 6), Vector2(-20, -30), Vector2(-14, 2)]), bark, 2.5)
	Ink.shape(self, PackedVector2Array([Vector2(78, 6), Vector2(20, -30), Vector2(14, 2)]), bark, 2.5)
	Ink.shape(self, PackedVector2Array([Vector2(-36, 4), Vector2(36, 4), Vector2(24, -140), Vector2(-24, -140)]), bark, 2.5)
	# Prayer cloth around the trunk: the warm accent the eye lands on.
	Ink.shape(self, Ink.rect(-31.0, -72.0, 62.0, 13.0), Color("c8372b"), 2.0)


func _canopy_shapes() -> Array:
	var leaf := Color("21492f")
	var root := Color("3b2a1e")
	var shapes: Array = []
	for x in [-118.0, -70.0, 66.0, 112.0]:
		shapes.append([Ink.rect(x, -160.0, 4.0, 120.0 - absf(x) * 0.2), root, 1.0])
	shapes.append([Ink.ellipse(Vector2(-98, -170), 92.0, 62.0), leaf, 2.5])
	shapes.append([Ink.ellipse(Vector2(98, -176), 96.0, 66.0), leaf, 2.5])
	shapes.append([Ink.ellipse(Vector2(0, -212), 150.0, 92.0), leaf, 2.5])
	shapes.append([Ink.ellipse(Vector2(-44, -248), 76.0, 38.0), Color("35693f"), 0.0])
	shapes.append([Ink.ellipse(Vector2(62, -214), 54.0, 26.0), Color("2d5c38"), 0.0])
	return shapes


func _draw_shrine() -> void:
	_draw_shadow(40.0, 11.0)
	Ink.shape(self, Ink.rect(-24.0, -38.0, 48.0, 38.0), Color("a2967e"), 2.0)
	Ink.shape(self, Ink.rect(-9.0, -28.0, 18.0, 28.0), Color("2a211a"), 1.5)
	Ink.shape(self, Ink.ellipse(Vector2(0, -12), 4.0, 6.0, 0.0, 360.0, 12), Color("f4bb46"), 0.0)
	Ink.shape(self, PackedVector2Array([Vector2(-36, -38), Vector2(36, -38), Vector2(22, -60), Vector2(-22, -60)]), Color("a93c2c"), 2.0)


func _draw_house() -> void:
	_draw_shadow(84.0, 16.0)
	Ink.shape(self, Ink.rect(-60.0, -46.0, 120.0, 46.0), Color("a89878"), 1.5)
	Ink.shape(self, Ink.rect(-12.0, -34.0, 24.0, 34.0), Color("6f6049"), 1.5)
	Ink.shape(self, PackedVector2Array([Vector2(-76, -44), Vector2(76, -44), Vector2(48, -96), Vector2(-48, -96)]), Color("8d7c58"), 1.5)


func _draw_fence() -> void:
	var wood := Color("857552")
	Ink.shape(self, Ink.rect(-50.0, -16.0, 100.0, 4.0), wood, 1.0)
	for x in [-48.0, -16.0, 16.0, 44.0]:
		Ink.shape(self, Ink.rect(x, -24.0, 4.0, 24.0), wood, 1.0)


func _draw_bamboo() -> void:
	_draw_shadow(24.0, 8.0)
	var stem := Color("76875a")
	for x in [-11.0, -2.0, 8.0]:
		Ink.shape(self, Ink.rect(x, -92.0 - absf(x) * 1.5, 4.0, 92.0 + absf(x) * 1.5), stem, 1.0)
	var leaf := Color("7f9165")
	Ink.shape(self, Ink.ellipse(Vector2(-16, -58), 15.0, 26.0), leaf, 1.5)
	Ink.shape(self, Ink.ellipse(Vector2(16, -66), 15.0, 28.0), leaf, 1.5)
	Ink.shape(self, Ink.ellipse(Vector2(0, -96), 19.0, 34.0), leaf, 1.5)
