extends State

func physics_update(_delta: float) -> void:
	if !GameManager.player :
		character.state_machine.transition_to("IdleState")
	
	var direction = (GameManager.player.global_position - character.global_position).normalized()
	character.velocity = direction * character.run_speed
	character.move_and_slide()

	if character.global_position.distance_to(GameManager.player.global_position) <= character.lunge_detection_distance:
		character.state_machine.transition_to("LungeState")
	elif character.global_position.distance_to(GameManager.player.global_position) > character.player_escape_range:
		character.state_machine.transition_to("IdleState")
