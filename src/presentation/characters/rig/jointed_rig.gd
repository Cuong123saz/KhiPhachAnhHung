@tool
class_name JointedRig
extends Node2D
## Puts a character together: bones and animation here, the look from body/ and
## equipment/. Two views are drawn, 3/4 front and 3/4 back, and flipped for the other
## side. Base animates the whole body; Action writes over the weapon arm, so a swing
## works while running.

const RADIUS := 12.0
const STEP_SECONDS := 1.0 / 12.0
const BLEND_SECONDS := 0.06
const OPTIONS := EquipmentCatalog.OPTIONS
const FACES := FaceShapes.STYLES
const STAFF_INDEX := EquipmentCatalog.STAFF_INDEX
const FAR_GRIP_OFFSET := TwoHandGrip.OFFSET
const BLINK_EVERY_SECONDS := 3.0
const BLINK_SECONDS := 0.12
# Skills that lock movement use the whole body; the others play over a running body.
const SKILLS := {
	"spin": {"animation": "skill_spin", "locks": false},
	"raise": {"animation": "skill_raise", "locks": true},
	"slam": {"animation": "skill_slam", "locks": true},
}

var world_x := 0.0
var world_y := 0.0
var moving := false
var view_back := false
var flipped := false
var stepped := true
var worn := {"hair": 0, "top": 0, "pants": 0, "shoes": 0, "weapon": 0, "cape": 0}
var face_style := 1
# Belt, sash and ribbon: the colour of the element.
var accent := Color("b5362b")
# Keyed by the animations: 0 is one-handed, 1 has the second hand on the weapon.
var far_grip := 0.0
var face_mood := 0:
	set(value):
		if value != face_mood:
			face_mood = value
			_redraw_face()

var _accumulator := 0.0
var _speed := 0.0
var _body := {}
var _cloth := {}
var _face := InkShapes.new()
var _locked := false
var _blink_timer := BLINK_EVERY_SECONDS
var _far_shoulder := Vector2.ZERO
var _near_shoulder := Vector2.ZERO
var _cape_spring := SpringMotion.new()
var _skirt_spring := SpringMotion.new()
var _tail_spring := SpringMotion.new()

@onready var _flip: Node2D = $Flip
@onready var _hips: Node2D = $Flip/Hips
@onready var _chest: Node2D = $Flip/Hips/Chest
@onready var _head: Node2D = $Flip/Hips/Chest/Head
@onready var _fore_far: Node2D = $Flip/Hips/Chest/ArmFar/ForeFar
@onready var _hand_far: Node2D = $Flip/Hips/Chest/ArmFar/ForeFar/HandFar
@onready var _hand_near: Node2D = $Flip/Hips/Chest/ArmNear/ForeNear/HandNear
@onready var _arm_near: Node2D = $Flip/Hips/Chest/ArmNear
@onready var _arm_far: Node2D = $Flip/Hips/Chest/ArmFar
@onready var _thigh_near: Node2D = $Flip/Hips/ThighNear
@onready var _thigh_far: Node2D = $Flip/Hips/ThighFar
@onready var _cape: Node2D = $Flip/Hips/Cape
@onready var _skirt: Node2D = $Flip/Hips/Skirt
@onready var _tail: Node2D = $Flip/Hips/Chest/Head/Tail
@onready var _base: AnimationPlayer = $Base
@onready var _action: AnimationPlayer = $Action


func _ready() -> void:
	for bone: Node2D in _bones():
		_add_layers(bone)
	# Hair and hats are cloth, so the face goes between the skin and them.
	_head.add_child(_face)
	_head.move_child(_face, 1)
	($Flip/Hips/Chest/SwingArc as InkShapes).shapes = SkillEffects.swing_arc()
	($Flip/GroundRing as InkShapes).shapes = SkillEffects.ground_ring()
	($Flip/WaterRise as InkShapes).shapes = SkillEffects.water_rise()
	(_hand_near.get_node("SpinDisc") as InkShapes).shapes = SkillEffects.spin_disc()
	(_hand_near.get_node("Weapon/Glow") as InkShapes).shapes = SkillEffects.staff_glow()
	_rebuild()
	queue_redraw()
	if Engine.is_editor_hint():
		return
	_base.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	_action.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	_base.play("idle")
	_advance_animation(0.0)


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 10.0 / 28.0))
	draw_circle(Vector2.ZERO, 14.0, Color(0.09, 0.12, 0.09, 0.3))


## The footprint is fixed, so gear cannot change collision.
func tick(dt: float, dir_x: float, dir_y: float, collision: MapCollision) -> void:
	if _locked:
		if is_swinging():
			dir_x = 0.0
			dir_y = 0.0
		else:
			_locked = false
	var moved := collision.move_character(world_x, world_y, dir_x, dir_y, dt, MovementConfig.SPEED, RADIUS)
	var step := Vector2(moved[0] - world_x, moved[1] - world_y)
	world_x = moved[0]
	world_y = moved[1]
	position = Vector2(world_x, world_y)
	moving = step.length() > 0.001
	_speed = step.length() / dt if dt > 0.0 else 0.0
	_update_view(dir_x, dir_y)
	_choose_base()
	if not stepped:
		_advance_animation(dt)
		return
	_accumulator += dt
	if _accumulator >= STEP_SECONDS:
		_advance_animation(_accumulator)
		_accumulator = 0.0


func place(x: float, y: float) -> void:
	world_x = x
	world_y = y
	position = Vector2(x, y)


func next_item(slot: String) -> void:
	var options: Array = OPTIONS[slot]
	worn[slot] = (int(worn[slot]) + 1) % options.size()
	_rebuild()


func equip(items: Dictionary) -> void:
	for slot: String in worn:
		worn[slot] = items.get(slot, 0)
	_rebuild()


func item_name(slot: String) -> String:
	return OPTIONS[slot][worn[slot]]


func swing() -> void:
	var animation := EquipmentCatalog.swing_animation(worn["weapon"])
	if animation != "" and not is_swinging():
		_action.play(animation)
		_action.queue(EquipmentCatalog.hold_animation(worn["weapon"]))


func cast(skill: String) -> void:
	if is_swinging():
		return
	if worn["weapon"] != STAFF_INDEX:
		worn["weapon"] = STAFF_INDEX
		_rebuild()
	var data: Dictionary = SKILLS[skill]
	_locked = data["locks"]
	_action.play(data["animation"])
	_action.queue(EquipmentCatalog.hold_animation(STAFF_INDEX))


func set_accent(color: Color) -> void:
	accent = color
	_rebuild()


func next_face() -> void:
	face_style = (face_style + 1) % FACES.size()
	_redraw_face()


func is_swinging() -> bool:
	if not _action.is_playing():
		return false
	var current: String = _action.current_animation
	return current.begins_with("swing") or current.begins_with("skill")


func is_locked() -> bool:
	return _locked


## Fixes a pose without moving, for the contact sheets.
func show_pose(back: bool, flip: bool, animation: String, time: float, action := "", action_time := 0.0) -> void:
	view_back = back
	flipped = flip
	_rebuild()
	_base.play(animation)
	_base.seek(time, true)
	if action != "":
		_action.play(action)
		_action.seek(action_time, true)
	elif _action.is_playing():
		_action.seek(_action.current_animation_position, true)
	_order_weapon_arm()
	_apply_far_grip()
	_speed = MovementConfig.SPEED if animation == "run" else 0.0
	_update_springs(2.0)


func _bones() -> Array:
	var found: Array = []
	var stack: Array = [$Flip/Hips]
	while not stack.is_empty():
		var bone: Node = stack.pop_back()
		if bone is Node2D and not bone is InkShapes:
			found.append(bone)
		for child in bone.get_children():
			if child.name != "Weapon":
				stack.append(child)
	found.append($Flip/Hips/Chest/ArmNear/ForeNear/HandNear/Weapon)
	return found


func _add_layers(bone: Node2D) -> void:
	var body := InkShapes.new()
	var cloth := InkShapes.new()
	bone.add_child(body)
	bone.add_child(cloth)
	bone.move_child(body, 0)
	bone.move_child(cloth, 1)
	_body[bone.name] = body
	_cloth[bone.name] = cloth


func _update_view(dir_x: float, dir_y: float) -> void:
	var back := view_back
	var flip := flipped
	if dir_y != 0.0:
		back = dir_y < 0.0
	if dir_x != 0.0:
		flip = dir_x < 0.0
	if back != view_back or flip != flipped:
		view_back = back
		flipped = flip
		_rebuild()


func _choose_base() -> void:
	var target := "idle"
	if moving:
		target = "run"
	elif _base.current_animation == "run" or _base.current_animation == "stop":
		target = "stop"
	elif is_swinging():
		target = "stance"
	if _base.current_animation != target:
		_base.play(target, BLEND_SECONDS)
		if target == "stop":
			_base.queue("idle")


func _advance_animation(delta: float) -> void:
	_base.advance(delta)
	_action.advance(delta)
	_order_weapon_arm()
	_apply_far_grip()
	_update_springs(delta)
	_update_blink(delta)


## A raised arm has to read in front of the face, and so does a second hand on the weapon.
func _order_weapon_arm() -> void:
	var last := _chest.get_child_count() - 1
	var gripping := far_grip > 0.5
	# Seen from behind, the far arm passes in front of the chest, out of sight.
	_arm_far.show_behind_parent = not gripping or view_back
	if gripping:
		_chest.move_child(_arm_far, last)
		_chest.move_child(_arm_near, last)
		_chest.move_child(_head, last)
	elif is_swinging():
		_chest.move_child(_arm_near, last)
	elif _arm_near.get_index() > _head.get_index():
		_chest.move_child(_head, last)


func _apply_far_grip() -> void:
	# Arms stretch uniformly for reach. The hands stay full size and carry the weapon.
	var stretch := _arm_near.scale.x
	_hand_near.scale = Vector2.ONE / stretch
	# The body turns toward a two-handed grip.
	_arm_near.position = _near_shoulder.lerp(Vector2(3.0, _near_shoulder.y), far_grip)
	_arm_far.position = _far_shoulder
	_arm_far.scale = _arm_near.scale
	_hand_far.scale = Vector2.ONE / stretch
	if far_grip > 0.0:
		TwoHandGrip.solve(_chest, _hand_near, _arm_far, _fore_far, _hand_far, _far_shoulder, stretch, far_grip)


func _update_blink(delta: float) -> void:
	var was_closed := _blink_timer < 0.0
	_blink_timer -= delta
	if _blink_timer < -BLINK_SECONDS:
		_blink_timer = BLINK_EVERY_SECONDS
	if was_closed != (_blink_timer < 0.0):
		_redraw_face()


func _update_springs(delta: float) -> void:
	var pace := minf(1.0, _speed / MovementConfig.SPEED)
	_cape.rotation = _cape_spring.step(delta, deg_to_rad(26.0) * pace)
	_skirt.rotation = _skirt_spring.step(delta, deg_to_rad(4.0) * pace)
	_tail.rotation = _tail_spring.step(delta, deg_to_rad(25.0) * pace) + deg_to_rad(30.0)
	# A robe billows at speed, so the stride does not push the legs through it.
	_skirt.scale.x = 1.0 + 0.25 * pace


func _rebuild() -> void:
	_flip.scale.x = -1.0 if flipped else 1.0
	# The weapon arm is always the near one; in the back view it sits on the leading side.
	var side := 1.0 if view_back else -1.0
	_near_shoulder = Vector2(8.5 * side, -14.0)
	_arm_near.position = _near_shoulder
	_far_shoulder = Vector2(-7.5 * side, -14.0)
	_arm_far.position = _far_shoulder
	($Flip/Hips/Chest/SwingArc as Node2D).position = _arm_near.position
	_thigh_near.position = Vector2(3.5 * side, 1.0)
	_thigh_far.position = Vector2(-3.5 * side, 1.0)
	_arm_far.modulate = Color(0.82, 0.82, 0.82)
	_thigh_far.modulate = Color(0.82, 0.82, 0.82)
	_arm_far.show_behind_parent = true
	# The cape hangs behind the legs from the front, over the body from behind.
	_hips.move_child(_cape, _hips.get_child_count() - 1 if view_back else 2)
	_tail.position = Vector2(-13.0, -12.0)
	_tail.show_behind_parent = true
	_dress()
	_redraw_face()
	_sync_hold()


## Bare body first, then each worn item on top of it.
func _dress() -> void:
	var bare := MaleBody.layers()
	for bone: StringName in _cloth:
		(_body[bone] as InkShapes).shapes = bare.get(String(bone), [])
		(_body[bone] as InkShapes).visible = true
		(_cloth[bone] as InkShapes).shapes = []
	for slot: String in worn:
		var item := EquipmentCatalog.layers(slot, worn[slot], view_back, accent)
		var shapes: Dictionary = item["shapes"]
		for bone: String in shapes:
			(_cloth[StringName(bone)] as InkShapes).shapes = shapes[bone]
		# Clothes hide the body under them, so skin cannot poke through while moving.
		for bone: String in item["covers"]:
			(_body[StringName(bone)] as InkShapes).visible = false


func _sync_hold() -> void:
	if Engine.is_editor_hint() or is_swinging():
		return
	var hold := EquipmentCatalog.hold_animation(worn["weapon"])
	if hold == "":
		_action.stop()
	elif _action.current_animation != hold:
		_action.play(hold)


func _redraw_face() -> void:
	_face.shapes = [] if view_back else FaceShapes.shapes(face_style, _blink_timer < 0.0, face_mood == 1)
