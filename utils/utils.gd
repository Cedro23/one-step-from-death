class_name Utils

static func direction_from_vector(direction: Vector2i) -> Enums.ExitDirection:
	match direction:
		Vector2i.DOWN: return Enums.ExitDirection.NORTH
		Vector2i.RIGHT: return Enums.ExitDirection.WEST
		Vector2i.UP: return Enums.ExitDirection.SOUTH
		Vector2i.LEFT: return Enums.ExitDirection.EAST
	return Enums.ExitDirection.NONE


static func opposite_direction(direction: Enums.ExitDirection) -> Enums.ExitDirection:
	match direction:
		Enums.ExitDirection.NORTH: return Enums.ExitDirection.SOUTH
		Enums.ExitDirection.SOUTH: return Enums.ExitDirection.NORTH
		Enums.ExitDirection.EAST:  return Enums.ExitDirection.WEST
		Enums.ExitDirection.WEST:  return Enums.ExitDirection.EAST
	return Enums.ExitDirection.NONE
