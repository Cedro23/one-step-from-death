extends State


@onready var attack_hitbox: Area2D = $"../../AttackHitbox"
@onready var attack_duration: Timer = $"../../AttackHitbox/AttackDuration"
@onready var attack_cooldown: Timer = $"../../AttackHitbox/AttackCooldown"
@onready var attack_hitbox_collision: CollisionShape2D = $"../../AttackHitbox/CollisionShape2D"

func enter():
	var direction: Vector2 = (character.mouse_position - character.global_position).normalized()
	var hitbox_position: Vector2 = direction * character.attack_range
	
	attack_hitbox.position = hitbox_position
	attack_hitbox_collision.disabled = false
	attack_duration.start()

func physics_update(_delta: float) -> void:
	character.velocity = character.input_direction * character.run_speed

func _on_attack_timer_timeout() -> void:
	attack_cooldown.start()
	attack_hitbox_collision.disabled = true
	character.state_machine.transition_to("IdleState")
