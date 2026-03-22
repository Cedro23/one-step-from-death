extends State

const RUN_SPEED: float = 150.0

var can_roll: bool = true

func physics_update(_delta: float) -> void:
	character.velocity = character.input_direction * RUN_SPEED

	if character.velocity == Vector2.ZERO:
		character.state_machine.transition_to("IdleState")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("click"):
		character.state_machine.transition_to("AttackState")
	if event.is_action_pressed("roll") and can_roll:
		can_roll = false
		character.state_machine.transition_to("RollState")

func _on_roll_cooldown_timer_timeout() -> void:
	can_roll = true
