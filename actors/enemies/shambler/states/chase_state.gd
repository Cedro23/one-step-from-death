extends State

const SPEED: float = 40.0
const LUNGE_DETECTION_DISTANCE: float = 60.0
const PLAYER_ESCAPE_RANGE: float = 180.0

func physics_update(_delta: float) -> void:
	var player = character.get_node("../Player")
	if !player :
		character.state_machine.transition_to("IdleState")
	
	var direction = (player.global_position - character.global_position).normalized()
	character.velocity = direction * SPEED
	character.move_and_slide()

	if character.global_position.distance_to(player.global_position) <= LUNGE_DETECTION_DISTANCE:
		character.state_machine.transition_to("LungeState")
	elif character.global_position.distance_to(player.global_position) > PLAYER_ESCAPE_RANGE:
		character.state_machine.transition_to("IdleState")
