class_name CameraController
extends Camera2D
## Port of the camera in MainScene.create() and Phaser's Camera.preRender().
##
## Built-in position smoothing and limits stay off: Camera2D's smoothing is a
## different algorithm, and stacking it on this follow would change the feel. The
## camera is a plain position updated once per rendered frame, after the player.
##
## Phaser keeps scrollX, where the world point at screen centre is
## scrollX + width / 2 at any zoom. Godot's Camera2D with DRAG_CENTER stores that
## centre directly, so this script works in centre coordinates:
##   clampX: scrollX in [(dw - w) / 2, max(that, that + W - dw)]
##     becomes centre in [dw / 2, max(dw / 2, W - dw / 2)]   with dw = w / zoom

var center_x := 0.0
var center_y := 0.0
var zoom_value := 1.0
var follow_factor := 0.0
var view_width := 0.0
var view_height := 0.0


## resizeCamera() in MainScene.ts: the visible world height stays fixed at the
## reference height unless the view is so wide that 2200 world units would no
## longer fill it.
func set_view_size(width: float, height: float) -> void:
	if width <= 0.0 or height <= 0.0:
		return
	view_width = width
	view_height = height
	zoom_value = maxf(height / MovementConfig.CAMERA_REFERENCE_HEIGHT, width / MovementConfig.WORLD_WIDTH)
	zoom = Vector2(zoom_value, zoom_value)


## camera.centerOn(): snaps, then clamps. Used at startup and on every resize.
func center_on(x: float, y: float) -> void:
	center_x = clamp_center(x, view_width, MovementConfig.WORLD_WIDTH)
	center_y = clamp_center(y, view_height, MovementConfig.WORLD_HEIGHT)
	_apply()


## setLerp(1 - exp(-rate * dt)) followed by Linear() in preRender. dt is in
## seconds. A dt of 0 leaves the camera still.
func follow(dt: float, target_x: float, target_y: float) -> void:
	follow_factor = 1.0 - exp(-MovementConfig.CAMERA_FOLLOW_RATE * dt)
	center_x = clamp_center(
		(target_x - center_x) * follow_factor + center_x, view_width, MovementConfig.WORLD_WIDTH
	)
	center_y = clamp_center(
		(target_y - center_y) * follow_factor + center_y, view_height, MovementConfig.WORLD_HEIGHT
	)
	_apply()


func clamp_center(value: float, view_size: float, world_size: float) -> float:
	var half_view := view_size / zoom_value / 2.0
	return minf(maxf(value, half_view), maxf(half_view, world_size - half_view))


func _apply() -> void:
	position = Vector2(center_x, center_y)
