extends State

const SPEED: float = 20.0
const PLAYER_DETECTION_RANGE: float = 120.0

func physics_update(_delta: float) -> void:
	var player = character.get_node("../Player")
		
	if character.global_position.distance_to(player.global_position) <= PLAYER_DETECTION_RANGE:
		character.state_machine.transition_to("ChaseState")
