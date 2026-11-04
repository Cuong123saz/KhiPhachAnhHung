class_name MovementConfig
extends RefCounted
## Movement and camera tuning. The comments name where each value came from in the old game.

# src/world/definitions.ts, MAPS.village
const WORLD_WIDTH := 2200.0
const WORLD_HEIGHT := 1400.0
# src/run/Run.ts, createVillageZone()
const SPAWN_X := 660.0
const SPAWN_Y := 800.0

# src/config/movement.ts, MOVEMENT_PREVIEW
const SPEED := 150.0
const RADIUS := 12.0
# src/config/movement.ts, GROUND_BLOCKING
const GROUND_WIDTH_RATIO := 0.30
const GROUND_MIN_RADIUS := 6.0
const GROUND_MAX_RADIUS := 18.0

# src/presentation/phaser/MainScene.ts
const CAMERA_REFERENCE_HEIGHT := 620.0
const CAMERA_FOLLOW_RATE := 8.0
const MAX_FRAME_SECONDS := 0.05
const RUN_FRAME_RATE := 8.0


## movementBody() in src/world/bodyGeometry.ts: the round footprint at the feet,
## which is separate from the sprite and from the box that receives hits.
static func footprint_radius(hitbox_width: float) -> float:
	var width_radius := hitbox_width * GROUND_WIDTH_RATIO
	return minf(RADIUS, minf(GROUND_MAX_RADIUS, maxf(GROUND_MIN_RADIUS, width_radius)))
