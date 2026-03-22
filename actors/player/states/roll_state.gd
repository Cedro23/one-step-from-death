extends State

@onready var hurtbox: Area2D = $"../../Hurtbox"
@onready var roll_timer: Timer = $"../../RollTimer"
@onready var roll_cooldown_timer: Timer = $"../../RollCooldownTimer"

func enter() -> void:
	character.velocity = character.input_direction * character.roll_speed
	hurtbox.monitoring = false
	roll_timer.start()
	roll_cooldown_timer.start()

func _on_roll_timer_timeout():
	hurtbox.monitoring = true
	character.state_machine.transition_to("IdleState")
