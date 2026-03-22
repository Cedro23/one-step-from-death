extends State

const ATTACK_RANGE: float = 16
const RUN_SPEED: float = 150.0

@onready var attack_hitbox: Area2D = $"../../AttackHitbox"
@onready var attack_hitbox_timer: Timer = $"../../AttackHitbox/Timer"
@onready var attack_hitbox_collision: CollisionShape2D = $"../../AttackHitbox/CollisionShape2D"

func enter():
	var direction: Vector2 = (character.mouse_position - character.global_position).normalized()
	var hitbox_position: Vector2 = direction * ATTACK_RANGE
	
	attack_hitbox.position = hitbox_position
	attack_hitbox_collision.disabled = false
	attack_hitbox_timer.start()

func physics_update(_delta: float) -> void:
	character.velocity = character.input_direction * RUN_SPEED

func _on_attack_timer_timeout() -> void:
	attack_hitbox_collision.disabled = true
	character.state_machine.transition_to("IdleState")
