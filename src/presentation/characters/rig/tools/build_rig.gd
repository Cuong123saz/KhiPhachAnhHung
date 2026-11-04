extends SceneTree
## Writes JointedRig.tscn and rig_animations.tres from the tables in moves/. Running this
## overwrites edits made to those two files in the editor.
##
## godot --headless --path VietPhachDesktop -s res://src/presentation/characters/rig/tools/build_rig.gd

const OUT_DIR := "res://src/presentation/characters/rig/"
const HIPS_Y := MoveBuilder.HIPS_Y


func _initialize() -> void:
	_build.call_deferred()


func _build() -> void:
	var library := AnimationLibrary.new()
	# Add a new class or element's moves here.
	for moves: Dictionary in [CommonMoves.all(), WaterMageMoves.all(), MetalSwordsmanMoves.all()]:
		for move_name: String in moves:
			library.add_animation(move_name, moves[move_name])
	var library_path := OUT_DIR + "rig_animations.tres"
	var error := ResourceSaver.save(library, library_path)
	if error != OK:
		printerr("could not save library: ", error)
		quit(1)
		return
	error = _save_scene(load(library_path))
	print("built rig, error code ", error)
	quit(error)


func _save_scene(library: AnimationLibrary) -> int:
	var root := Node2D.new()
	root.name = "JointedRig"
	root.set_script(load(OUT_DIR + "jointed_rig.gd"))
	var flip := _bone(root, root, "Flip", Vector2.ZERO)
	var hips := _bone(flip, root, "Hips", Vector2(0.0, HIPS_Y))
	for leg: String in ["Far", "Near"]:
		var thigh := _bone(hips, root, "Thigh" + leg, Vector2(0.0, 1.0))
		var shin := _bone(thigh, root, "Shin" + leg, Vector2(0.0, 10.0))
		_bone(shin, root, "Foot" + leg, Vector2(0.0, 9.0))
	_bone(hips, root, "Skirt", Vector2(0.0, 2.0))
	var chest := _bone(hips, root, "Chest", Vector2(0.0, -1.0))
	_bone(hips, root, "Cape", Vector2(0.0, -15.0))
	for arm: String in ["Far", "Near"]:
		var upper := _bone(chest, root, "Arm" + arm, Vector2.ZERO)
		var fore := _bone(upper, root, "Fore" + arm, Vector2(0.0, 8.0))
		var hand := _bone(fore, root, "Hand" + arm, Vector2(0.0, 8.0))
		if arm == "Near":
			var weapon := _bone(hand, root, "Weapon", Vector2.ZERO)
			weapon.show_behind_parent = true
			_effect(weapon, root, "Glow", Vector2(0.0, -30.0))
			_effect(hand, root, "SpinDisc", Vector2.ZERO)
	var head := _bone(chest, root, "Head", Vector2(0.0, -16.5))
	_bone(head, root, "Tail", Vector2.ZERO)
	_effect(chest, root, "SwingArc", Vector2(4.0, -12.0))
	var ring := _effect(flip, root, "GroundRing", Vector2(12.0, 0.0))
	flip.move_child(ring, 0)
	_effect(flip, root, "WaterRise", Vector2(12.0, 0.0))
	flip.move_child(flip.get_node("WaterRise"), 1)
	for player_name: String in ["Base", "Action"]:
		var player := AnimationPlayer.new()
		player.name = player_name
		root.add_child(player)
		player.owner = root
		player.add_animation_library("", library)
	var scene := PackedScene.new()
	var error := scene.pack(root)
	if error == OK:
		error = ResourceSaver.save(scene, OUT_DIR + "JointedRig.tscn")
	root.free()
	return error


## A hidden shape that animations switch on; the rig script gives it its look.
func _effect(parent: Node, owner_node: Node, effect_name: String, at: Vector2) -> Node2D:
	var effect := InkShapes.new()
	effect.name = effect_name
	effect.position = at
	effect.visible = false
	parent.add_child(effect)
	effect.owner = owner_node
	return effect


func _bone(parent: Node, owner_node: Node, bone_name: String, at: Vector2) -> Node2D:
	var bone := Node2D.new()
	bone.name = bone_name
	bone.position = at
	parent.add_child(bone)
	bone.owner = owner_node
	return bone
