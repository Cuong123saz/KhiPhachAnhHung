extends Node2D
## The development sandbox: the jointed character in a test corner of the village, set
## up as the Water Mage. Tests in tests/rig_test_runner.gd are the baseline for this.

const SPAWN := Vector2(1240.0, 680.0)
const PROPS := [
	["banyan", 1560.0, 660.0],
	["shrine", 1700.0, 740.0],
	["fence", 1400.0, 600.0],
	["fence", 1730.0, 580.0],
	["house", 1120.0, 520.0],
	["house", 1860.0, 880.0],
	["house", 980.0, 1040.0],
	["bamboo", 1280.0, 520.0],
	["bamboo", 1830.0, 550.0],
	["bamboo", 880.0, 660.0],
	["bamboo", 560.0, 880.0],
	["bamboo", 1500.0, 1000.0],
]
const SLOT_KEYS := {
	KEY_1: "hair", KEY_2: "top", KEY_3: "pants", KEY_4: "shoes", KEY_5: "weapon", KEY_6: "cape",
}

var collision := MapCollision.new(MovementConfig.WORLD_WIDTH, MovementConfig.WORLD_HEIGHT)
var clock := FrameClock.new()
var banyan: VillageProp
var job := Job.MAGE
var element: String = CharacterCatalog.FLAGSHIP_ELEMENT[Job.MAGE]

@onready var rig: JointedRig = $Entities/Rig
@onready var entities: Node2D = $Entities
@onready var camera: CameraController = $Camera
@onready var hint: Label = $Ui/Hint


func _ready() -> void:
	for data: Array in PROPS:
		var prop := VillageProp.new()
		prop.kind = data[0]
		prop.position = Vector2(data[1], data[2])
		prop.player = rig
		entities.add_child(prop)
		collision.obstacles.append(prop.obstacle())
		if prop.kind == "banyan":
			banyan = prop
	rig.place(SPAWN.x, SPAWN.y)
	camera.make_current()
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()
	_start_as_character()
	_update_hint()


func _process(delta: float) -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED:
		return
	var direction := MoveInput.direction_from_keys(
		Input.is_action_pressed("move_left"),
		Input.is_action_pressed("move_right"),
		Input.is_action_pressed("move_up"),
		Input.is_action_pressed("move_down")
	)
	advance(clock.step(delta * 1000.0), direction[0], direction[1])


func advance(delta_ms: float, dir_x: float, dir_y: float) -> void:
	var dt := minf(delta_ms / 1000.0, MovementConfig.MAX_FRAME_SECONDS)
	rig.tick(dt, dir_x, dir_y, collision)
	camera.follow(dt, rig.world_x, rig.world_y)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		clock.blur()
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		clock.focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	var code := (event as InputEventKey).physical_keycode
	if SLOT_KEYS.has(code):
		rig.next_item(SLOT_KEYS[code])
	match code:
		KEY_0:
			rig.equip({})
		KEY_7:
			rig.next_face()
		KEY_Q:
			rig.cast("raise")
		KEY_E:
			rig.cast("spin")
		KEY_R:
			rig.cast("slam")
		KEY_SPACE:
			rig.swing()
		KEY_T:
			rig.stepped = not rig.stepped
		KEY_ESCAPE:
			get_tree().quit()
	_update_hint()


func _start_as_character() -> void:
	var weapon: String = Job.DEFINITIONS[job]["weapon"]
	rig.equip({"hair": 1, "top": 2, "shoes": 1, "weapon": CharacterStyle.WEAPON_ITEMS[weapon]})
	rig.set_accent(CharacterStyle.ELEMENT_COLORS[element])


func _update_hint() -> void:
	hint.text = "\n".join([
		"%s %s (%s)" % [
			CharacterStyle.JOB_NAMES[job], CharacterStyle.ELEMENT_NAMES[element],
			CharacterStyle.STATUS_NAMES[CharacterCatalog.status(job, element)],
		],
		"WASD: đi   Space: vung   Q: niệm rồi vung   E: xoay trượng   R: cắm trượng",
		"7 Mặt: %s   0: cởi hết   T: nhịp %s   Esc: thoát" % [
			JointedRig.FACES[rig.face_style], "12 hình/giây" if rig.stepped else "trơn"
		],
		"1 Tóc: %s   2 Áo: %s   3 Quần: %s   4 Giày: %s   5 Vũ khí: %s   6 Choàng: %s" % [
			rig.item_name("hair"), rig.item_name("top"), rig.item_name("pants"),
			rig.item_name("shoes"), rig.item_name("weapon"), rig.item_name("cape"),
		],
	])


func _on_viewport_resized() -> void:
	var size := get_viewport().get_visible_rect().size
	camera.set_view_size(size.x, size.y)
	camera.center_on(rig.world_x, rig.world_y)
