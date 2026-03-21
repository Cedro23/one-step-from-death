extends State

@onready var recovery_timer: Timer = $"../../RecoveryTimer"

func enter() -> void:
	# Start revocery timer
	recovery_timer.start()

func _on_recovery_timer_timeout() -> void:
	character.state_machine.transition_to("IdleState")
