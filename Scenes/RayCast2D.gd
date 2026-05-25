extends RayCast2D


# Called when the node enters the scene tree for the first time.
func validate_movement(cast_to : Vector2) -> bool:
	target_position = cast_to
	force_raycast_update()
	return not is_colliding()
