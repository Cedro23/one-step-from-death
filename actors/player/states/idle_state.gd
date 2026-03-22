extends State

func physics_update(_delta: float) -> void:
	if character.input_direction != Vector2.ZERO:
		character.state_machine.transition_to("RunState")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("click"):
		character.state_machine.transition_to("AttackState")