extends State

const LUNGE_SPEED: float = 200.0
@onready var lunge_windup_timer: Timer = $"../../LungeWindupTimer"
@onready var lunge_timer: Timer = $"../../LungeTimer"

func enter() -> void:
	character.velocity = Vector2.ZERO
	lunge_windup_timer.start()

func physics_update(_delta: float) -> void:
	character.move_and_slide()


func _on_lunge_windup_timer_timeout() -> void:
	# Lock in on player
	# And lunge
	lunge_timer.start()

func _on_lunge_timer_timeout() -> void:
	character.state_machine.transition_to("RecoveryState")
