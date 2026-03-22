extends State

func physics_update(_delta: float) -> void:
	character.velocity = character.input_direction * character.run_speed

	if character.velocity == Vector2.ZERO:
		character.state_machine.transition_to("IdleState")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("click") and character.can_attack:
		character.state_machine.transition_to("AttackState")
	if event.is_action_pressed("roll") and character.can_roll:
		character.can_roll = false
		character.state_machine.transition_to("RollState")
