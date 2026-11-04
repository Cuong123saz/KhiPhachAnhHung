extends Node
## Checks the jointed rig scene and renders contact sheets for review.
##
## godot --path VietPhachDesktop res://tests/RigTestRunner.tscn

const RESULTS_DIR := "res://tests/results/rig_test"
const FRAME_MS := 1000.0 / 60.0
const TILE := Vector2i(300, 360)
const OUTFITS := [
	{},
	{"hair": 1, "top": 1, "pants": 1, "shoes": 1, "weapon": 1},
	{"hair": 2, "top": 2, "shoes": 1, "weapon": 2},
	{"hair": 1, "top": 1, "pants": 1, "shoes": 1, "weapon": 1, "cape": 1},
]

var world: Node2D
var failures := 0


func _ready() -> void:
	world = load("res://src/dev/sandbox/RigTest.tscn").instantiate()
	add_child(world)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RESULTS_DIR))
	# Keep the editor from importing test output.
	FileAccess.open(RESULTS_DIR.get_base_dir() + "/.gdignore", FileAccess.WRITE).close()
	# The sandbox is not processed here, so nothing moves until a test moves it.
	_run.call_deferred()


func _run() -> void:
	world.set_process(false)
	_test_starts_as_mage()
	_test_elements()
	_test_catalog()
	_test_boundaries()
	_test_camera()
	_test_collision()
	_test_gear_changes_nothing_physical()
	_test_every_item_draws_something()
	_test_stepped_playback()
	_test_foot_slip()
	_test_secondary_motion()
	_test_skills()
	_test_face_keeps_collision()
	await _test_keys()
	await _test_speed_through_real_input()
	await _shots()
	await _sheets()
	print("RESULT: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	get_tree().quit(0 if failures == 0 else 1)


func _check(ok: bool, message: String) -> void:
	print("%s %s" % ["ok  " if ok else "FAIL", message])
	if not ok:
		failures += 1


func _walk(start: Vector2, direction: Vector2, frames: int) -> Vector2:
	var rig: JointedRig = world.rig
	rig.place(start.x, start.y)
	world.camera.center_on(start.x, start.y)
	for _i in frames:
		world.advance(FRAME_MS, direction.x, direction.y)
	return Vector2(rig.world_x, rig.world_y)


func _test_starts_as_mage() -> void:
	var rig: JointedRig = world.rig
	_check(rig.worn["top"] == 2 and rig.worn["weapon"] == JointedRig.STAFF_INDEX, "starts in the robe with the staff")
	_check(rig.accent == CharacterStyle.ELEMENT_COLORS[Element.WATER], "starts with the water colour")
	_check(world.hint.text.contains("Pháp Sư Thủy"), "hint names the Water Mage")


func _test_elements() -> void:
	var counts := {}
	var table := PackedStringArray()
	for source: String in Element.ALL:
		for target: String in Element.ALL:
			var relation := Element.relation(source, target)
			counts[relation] = counts.get(relation, 0) + 1
			table.append("%s %s %s %.2f" % [source, target, relation, Element.multiplier(relation)])
	var file := FileAccess.open(RESULTS_DIR + "/element_table.txt", FileAccess.WRITE)
	file.store_string("\n".join(table) + "\n")
	file.close()
	for relation: String in [Element.SAME, Element.OVERCOMES, Element.OVERCOME_BY, Element.GENERATES, Element.GENERATED_BY]:
		_check(counts.get(relation, 0) == 5, "5 element pairs are %s" % relation)
	_check(Element.relation(Element.WATER, Element.FIRE) == Element.OVERCOMES, "water overcomes fire")
	_check(is_equal_approx(Element.multiplier(Element.relation(Element.WATER, Element.FIRE)), 1.25), "overcoming deals x1.25")
	_check(is_equal_approx(Element.multiplier(Element.relation(Element.FIRE, Element.WATER)), 0.8), "being overcome deals x0.80")
	_check(is_equal_approx(Element.multiplier(Element.relation(Element.WATER, Element.WOOD)), 1.0), "generating changes no damage")


func _test_catalog() -> void:
	var counts := {}
	for job: String in Job.ALL:
		_check(Job.DEFINITIONS.has(job) and CharacterStyle.JOB_NAMES.has(job), "job %s is defined and named" % job)
		for element: String in Element.ALL:
			var status := CharacterCatalog.status(job, element)
			counts[status] = counts.get(status, 0) + 1
	_check(counts.get(CharacterCatalog.PLAYABLE_IN_PHASER, 0) == 2, "2 characters have Phaser gameplay")
	_check(counts.get(CharacterCatalog.MODEL_ONLY, 0) == 3, "3 characters have only a model")
	_check(counts.get(CharacterCatalog.NOT_BUILT, 0) == 20, "20 of the 25 characters are unbuilt")


## Keeps rules portable: they never touch the scene tree, input or the screen.
func _test_boundaries() -> void:
	const FORBIDDEN := [
		"extends Node", "extends Sprite", "extends Camera", "extends CanvasItem", "extends Label", "get_tree(",
		"Input.", "DisplayServer", "res://src/presentation", "res://src/dev", "res://assets",
		"CameraController", "JointedRig", "CharacterStyle", "InkShapes", "Color(",
	]
	var scanned := 0
	for folder: String in ["res://src/gameplay", "res://src/world", "res://src/config", "res://src/engine"]:
		for path: String in _scripts_in(folder):
			scanned += 1
			var source := FileAccess.get_file_as_string(path)
			for token: String in FORBIDDEN:
				if source.contains(token):
					_check(false, "%s must not use %s" % [path, token])
	_check(scanned >= 7, "rule scripts stay free of engine and presentation code, %d scanned" % scanned)


func _scripts_in(folder: String) -> Array[String]:
	var found: Array[String] = []
	for file: String in DirAccess.get_files_at(folder):
		if file.ends_with(".gd"):
			found.append(folder.path_join(file))
	for child: String in DirAccess.get_directories_at(folder):
		found.append_array(_scripts_in(folder.path_join(child)))
	return found


## Expected numbers were measured from the Phaser camera the owner wants to keep.
func _test_camera() -> void:
	var camera: CameraController = world.camera
	var sizes := [
		[1280.0, 720.0, 1.16129, 551.11, 310.0], [1600.0, 900.0, 1.45161, 551.11, 310.0],
		[1920.0, 1080.0, 1.74194, 551.11, 310.0], [1440.0, 900.0, 1.45161, 496.0, 310.0],
		[3840.0, 1000.0, 1.74545, 1100.0, 286.46],
	]
	for size: Array in sizes:
		camera.set_view_size(size[0], size[1])
		camera.center_on(12.0, 12.0)
		_check(absf(camera.zoom_value - size[2]) < 0.0001, "zoom at %dx%d is %.5f" % [size[0], size[1], camera.zoom_value])
		_check(absf(camera.center_x - size[3]) < 0.01 and absf(camera.center_y - size[4]) < 0.01,
			"corner stops the camera at %.2f, %.2f" % [camera.center_x, camera.center_y])
	camera.set_view_size(1280.0, 720.0)
	camera.center_on(660.0, 800.0)
	camera.follow(1.0 / 60.0, 760.0, 800.0)
	_check(absf(camera.center_x - (660.0 + 100.0 * (1.0 - exp(-8.0 / 60.0)))) < 0.0001, "follow uses 1 - exp(-8 dt)")
	world._on_viewport_resized()


func _test_collision() -> void:
	var trunk := _walk(Vector2(1440.0, 660.0), Vector2.RIGHT, 90)
	_check(trunk.x <= 1514.0 and trunk.x > 1510.0, "trunk stops the player at x=%.2f" % trunk.x)
	var free := _walk(Vector2(1240.0, 680.0), Vector2.DOWN, 60)
	_check(absf(free.y - 830.0) < 0.001, "open ground moves 150 units in 1 s, y=%.3f" % free.y)


func _test_gear_changes_nothing_physical() -> void:
	var rig: JointedRig = world.rig
	rig.equip({})
	var reference := _walk(Vector2(1440.0, 660.0), Vector2.RIGHT, 90)
	for outfit: Dictionary in OUTFITS:
		rig.equip(outfit)
		var result := _walk(Vector2(1440.0, 660.0), Vector2.RIGHT, 90)
		_check(result == reference, "gear %s collides the same" % outfit)
	rig.equip({})


func _test_every_item_draws_something() -> void:
	var rig: JointedRig = world.rig
	for slot: String in JointedRig.OPTIONS:
		rig.equip({})
		var bare := _count_shapes(rig)
		for option in range(1, rig.OPTIONS[slot].size()):
			rig.equip({slot: option})
			_check(_count_shapes(rig) > bare, "%s: %s adds shapes" % [slot, rig.item_name(slot)])
	rig.equip({"top": 2, "pants": 1})
	_check(not _layer(rig, "Chest").visible and not _layer(rig, "ThighNear").visible, "clothes hide the body under them")
	rig.equip({})
	_check(_layer(rig, "Chest").visible and _layer(rig, "ThighNear").visible, "taking clothes off shows the body again")


func _layer(rig: JointedRig, bone: String) -> InkShapes:
	return rig._body[bone]


func _count_shapes(rig: JointedRig) -> int:
	var total := 0
	for bone: String in rig._cloth:
		total += (rig._cloth[bone] as InkShapes).shapes.size()
	return total


func _distinct_poses(stepped: bool) -> int:
	var rig: JointedRig = world.rig
	rig.stepped = stepped
	var seen := {}
	var thigh: Node2D = rig.get_node("Flip/Hips/ThighNear")
	rig.place(300.0, 1250.0)
	for i in 120:
		world.advance(FRAME_MS, 1.0, 0.0)
		if i >= 60:
			seen[snappedf(thigh.rotation, 0.0001)] = true
	return seen.size()


func _test_stepped_playback() -> void:
	var held := _distinct_poses(true)
	var smooth := _distinct_poses(false)
	# One stride takes 0.5 s and repeats, so 12 per second shows 6 different poses.
	_check(held == 6, "12 per second mode shows %d distinct poses per stride" % held)
	_check(smooth > 25, "smooth mode shows %d distinct poses per stride" % smooth)
	world.rig.stepped = true


## How far the planted foot skids across the ground during its stance.
func _test_foot_slip() -> void:
	var rig: JointedRig = world.rig
	var foot: Node2D = rig.get_node("Flip/Hips/ThighNear/ShinNear/FootNear")
	var base: AnimationPlayer = rig.get_node("Base")
	rig.equip({})
	rig.place(300.0, 1250.0)
	rig.show_pose(false, false, "run", 0.0)
	var samples := []
	var step := 0.005
	var t := 0.0
	while t < 0.5:
		base.seek(t, true)
		samples.append([t, foot.global_position.x - rig.global_position.x, foot.global_position.y - rig.global_position.y])
		t += step
	var lowest: float = -INF
	for sample: Array in samples:
		lowest = maxf(lowest, sample[2])
	var distance := 0.0
	var duration := 0.0
	for i in range(1, samples.size()):
		if samples[i][2] > lowest - 2.0 and samples[i - 1][2] > lowest - 2.0:
			distance += samples[i - 1][1] - samples[i][1]
			duration += step
	var foot_speed: float = distance / maxf(duration, 0.001)
	print("info foot backward speed during stance %.1f units/s against 150 ground speed, stance %.3f s" % [foot_speed, duration])
	_check(foot_speed > 0.0 and duration > 0.0, "foot travels backward while planted")


func _test_secondary_motion() -> void:
	var rig: JointedRig = world.rig
	var cape: Node2D = rig.get_node("Flip/Hips/Cape")
	rig.equip({"cape": 1})
	rig.place(300.0, 1250.0)
	for _i in 60:
		world.advance(FRAME_MS, 1.0, 0.0)
	var running := cape.rotation
	for _i in 90:
		world.advance(FRAME_MS, 0.0, 0.0)
	_check(running > 0.3 and absf(cape.rotation) < 0.05, "cape trails at %.2f rad, settles to %.2f" % [running, cape.rotation])
	rig.equip({})


func _play_until_done(rig: JointedRig) -> void:
	for _i in 200:
		world.advance(FRAME_MS, 0.0, 0.0)
		if not rig.is_swinging():
			return


func _test_skills() -> void:
	var rig: JointedRig = world.rig
	var far_hand: Node2D = rig.get_node("Flip/Hips/Chest/ArmFar/ForeFar/HandFar")
	var near_hand: Node2D = rig.get_node("Flip/Hips/Chest/ArmNear/ForeNear/HandNear")
	for back: bool in [false, true]:
		for skill: String in ["raise", "slam"]:
			rig.equip({"top": 2})
			rig.place(600.0, 1200.0)
			# Face the requested way before casting.
			world.advance(FRAME_MS, 0.0, -1.0 if back else 1.0)
			rig.cast(skill)
			_check(rig.worn["weapon"] == JointedRig.STAFF_INDEX, "%s equips the staff" % skill)
			var x := rig.world_x
			var worst := 0.0
			var gripped := 0
			for _i in 90:
				world.advance(FRAME_MS, 1.0, 0.0)
				if rig.far_grip > 0.99:
					gripped += 1
					var target := near_hand.to_global(Vector2(0.0, JointedRig.FAR_GRIP_OFFSET))
					worst = maxf(worst, far_hand.global_position.distance_to(target))
			_check(gripped > 0 and worst < 1.5, "%s back=%s: second hand stays on the staff, off by at most %.2f" % [skill, back, worst])
			_check(rig.world_x == x or not rig.is_locked(), "%s locks movement while casting" % skill)
			_play_until_done(rig)
			_check(not rig.is_swinging() and rig.far_grip == 0.0, "%s finishes and lets go" % skill)
			var arm: Node2D = rig.get_node("Flip/Hips/Chest/ArmNear")
			_check(is_equal_approx(arm.scale.x, 1.0), "%s returns the arm to normal length" % skill)
	rig.equip({"top": 1})
	rig.place(600.0, 1200.0)
	rig.cast("spin")
	var start_x := rig.world_x
	for _i in 30:
		world.advance(FRAME_MS, 1.0, 0.0)
	_check(rig.is_swinging() and rig.world_x > start_x + 60.0, "spin plays while running, moved %.1f" % (rig.world_x - start_x))
	_play_until_done(rig)
	var hand := "Flip/Hips/Chest/ArmNear/ForeNear/HandNear/"
	for path: String in [hand + "SpinDisc", hand + "Weapon/Glow", "Flip/GroundRing", "Flip/WaterRise", "Flip/Hips/Chest/SwingArc"]:
		_check(not rig.get_node(path).visible, "%s is off after the skills" % path.get_file())
	rig.equip({})


func _test_face_keeps_collision() -> void:
	var rig: JointedRig = world.rig
	var reference := _walk(Vector2(1440.0, 660.0), Vector2.RIGHT, 90)
	for _i in JointedRig.FACES.size():
		rig.next_face()
		_check(_walk(Vector2(1440.0, 660.0), Vector2.RIGHT, 90) == reference, "face %s collides the same" % JointedRig.FACES[rig.face_style])


func _press(code: Key) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		await get_tree().process_frame


func _test_keys() -> void:
	var rig: JointedRig = world.rig
	var slots := {KEY_1: "hair", KEY_2: "top", KEY_3: "pants", KEY_4: "shoes", KEY_5: "weapon", KEY_6: "cape"}
	for code: Key in slots:
		await _press(code)
		_check(rig.worn[slots[code]] == 1, "key puts on %s: %s" % [slots[code], rig.item_name(slots[code])])
	await _press(KEY_SPACE)
	_check(rig.is_swinging(), "Space starts a swing")
	_check(world.hint.text.contains("Kiếm"), "hint names the worn weapon")
	for _i in 60:
		world.advance(FRAME_MS, 0.0, 0.0)
	_check(not rig.is_swinging(), "swing finishes")
	await _press(KEY_0)
	var empty := true
	for slot: String in rig.worn:
		empty = empty and rig.worn[slot] == 0
	_check(empty, "0 takes everything off")
	await _press(KEY_T)
	_check(not rig.stepped, "T switches to smooth")
	await _press(KEY_T)
	var face := rig.face_style
	await _press(KEY_7)
	_check(rig.face_style != face, "7 changes the face")
	await _press(KEY_Q)
	_check(rig.is_swinging() and rig.is_locked(), "Q starts the two-handed raise")
	_play_until_done(rig)
	await _press(KEY_R)
	_check(rig.is_swinging() and rig.is_locked(), "R starts the slam")
	_play_until_done(rig)
	await _press(KEY_E)
	_check(rig.is_swinging() and not rig.is_locked(), "E starts the spin without locking movement")
	_play_until_done(rig)
	await _press(KEY_0)
	rig.face_style = face


func _test_speed_through_real_input() -> void:
	world.set_process(true)
	var rig: JointedRig = world.rig
	var best := 0.0
	for _attempt in 4:
		rig.place(600.0, 1300.0)
		world.clock.focus()
		while world.clock.cool_down > 0:
			await get_tree().process_frame
		var event := InputEventKey.new()
		event.physical_keycode = KEY_D
		event.pressed = true
		Input.parse_input_event(event)
		await get_tree().create_timer(0.3).timeout
		var start_x := rig.world_x
		var start_time := Time.get_ticks_usec()
		await get_tree().create_timer(1.5).timeout
		best = (rig.world_x - start_x) / ((Time.get_ticks_usec() - start_time) / 1e6)
		event = InputEventKey.new()
		event.physical_keycode = KEY_D
		event.pressed = false
		Input.parse_input_event(event)
		await get_tree().process_frame
		if absf(best - 150.0) < 3.0:
			break
	_check(absf(best - 150.0) < 3.0, "real input speed %.2f units/s" % best)
	world.set_process(false)


func _capture() -> Image:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.convert(Image.FORMAT_RGB8)
	return image


func _save(image: Image, name: String) -> void:
	image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [RESULTS_DIR, name]))


func _shot(name: String, x: float, y: float) -> void:
	var rig: JointedRig = world.rig
	rig.place(x, y)
	world.camera.center_on(x, y)
	world.set_process(true)
	await get_tree().create_timer(0.5).timeout
	world.set_process(false)
	_save(await _capture(), name)


func _shots() -> void:
	var rig: JointedRig = world.rig
	rig.equip({})
	await _shot("1_bare", 1240.0, 680.0)
	rig.equip(OUTFITS[1])
	await _shot("2_dressed_behind_tree", 1522.0, 615.0)
	_check(world.banyan.canopy_alpha() < 0.6, "canopy fades behind the tree")
	rig.equip(OUTFITS[2])
	await _shot("3_robe", 1440.0, 800.0)
	rig.equip({})


func _tile(sheet: Image, column: int, row: int) -> void:
	var image: Image = await _capture()
	var source := Rect2i((image.get_size() - TILE) / 2, TILE)
	sheet.blit_rect(image, source, Vector2i(column * TILE.x, row * TILE.y))


func _sheets() -> void:
	var rig: JointedRig = world.rig
	world.hint.visible = false
	rig.place(1000.0, 900.0)
	world.camera.zoom = Vector2(4.0, 4.0)
	world.camera.position = Vector2(1000.0, 870.0)
	var sheet := Image.create(TILE.x * 4, TILE.y * OUTFITS.size(), false, Image.FORMAT_RGB8)
	for row in OUTFITS.size():
		rig.equip(OUTFITS[row])
		for column in 4:
			var back := column >= 2
			if column % 2 == 0:
				rig.show_pose(back, false, "idle", 0.0)
			else:
				rig.show_pose(back, false, "run", 0.0)
			await _tile(sheet, column, row)
	_save(sheet, "4_outfits")
	rig.equip(OUTFITS[1])
	var stride := Image.create(TILE.x * 8, TILE.y * 2, false, Image.FORMAT_RGB8)
	for line in 2:
		for i in 8:
			rig.show_pose(line == 1, false, "run", i * 0.0625)
			await _tile(stride, i, line)
	_save(stride, "5_run_cycle")
	var swings := Image.create(TILE.x * 8, TILE.y * 2, false, Image.FORMAT_RGB8)
	var names := ["swing_sword", "swing_staff"]
	for line in 2:
		rig.equip(OUTFITS[line + 1])
		for i in 8:
			rig.show_pose(false, false, "stance", 0.0, names[line], 0.06 * i)
			await _tile(swings, i, line)
	_save(swings, "6_swings")
	await _face_sheet()
	await _skill_sheets()


func _face_sheet() -> void:
	var rig: JointedRig = world.rig
	var count := JointedRig.FACES.size()
	var sheet := Image.create(TILE.x * count, TILE.y * 4, false, Image.FORMAT_RGB8)
	var gear := [{}, {"hair": 1, "top": 1}]
	for row in 4:
		# Top rows enlarged; bottom rows at the two real game zooms.
		var zoom: float = [4.0, 4.0, 1.742, 1.161][row]
		world.camera.zoom = Vector2(zoom, zoom)
		rig.equip(gear[row] if row < 2 else gear[1])
		for column in count:
			rig.face_style = column
			rig.show_pose(false, false, "idle", 0.0)
			await _tile(sheet, column, row)
	_save(sheet, "7_faces")
	world.camera.zoom = Vector2(4.0, 4.0)
	rig.face_style = 1


func _skill_sheets() -> void:
	var rig: JointedRig = world.rig
	world.camera.zoom = Vector2(3.0, 3.0)
	world.camera.position = Vector2(1000.0, 860.0)
	rig.equip({"hair": 1, "top": 2, "shoes": 1, "weapon": JointedRig.STAFF_INDEX})
	var skills := {
		"8_skill_raise": ["skill_raise", [0.18, 0.38, 0.7, 1.02, 1.08, 1.12, 1.3, 1.5]],
		"9_skill_slam": ["skill_slam", [0.18, 0.25, 0.4, 0.6, 0.8, 1.15, 1.44, 1.6]],
		"10_skill_spin": ["skill_spin", [0.09, 0.16, 0.22, 0.28, 0.34, 0.5, 0.72, 0.85]],
	}
	for sheet_name: String in skills:
		var data: Array = skills[sheet_name]
		var times: Array = data[1]
		var strip := Image.create(TILE.x * times.size(), TILE.y * 2, false, Image.FORMAT_RGB8)
		for row in 2:
			for column in times.size():
				rig.show_pose(row == 1, false, "stance", 0.0, data[0], times[column])
				await _tile(strip, column, row)
		_save(strip, sheet_name)
