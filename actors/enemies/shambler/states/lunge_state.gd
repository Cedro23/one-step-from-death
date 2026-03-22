extends State

const LUNGE_SPEED: float = 300.0
@onready var lunge_windup_timer: Timer = $"../../LungeWindupTimer"
@onready var lunge_timer: Timer = $"../../LungeTimer"

const HITBOX_DISTANCE: float = 16.0
@onready var hitbox: Area2D = $"../../Hitbox"
@onready var hitbox_collision: CollisionShape2D = $"../../Hitbox/CollisionShape2D"

var player: CharacterBody2D
var direction: Vector2
var rotation: float

func enter() -> void:
	player = character.get_node("/root/Main/Player")
	direction = (player.global_position - character.global_position).normalized()
	rotation = player.global_position.angle_to_point(character.global_position)

	hitbox.position = direction * HITBOX_DISTANCE
	hitbox.rotation = rotation
	character.velocity = Vector2.ZERO
	
	lunge_windup_timer.start()

func physics_update(_delta: float) -> void:
	character.move_and_slide()

func _on_lunge_windup_timer_timeout() -> void:
	hitbox_collision.disabled = false
	character.velocity = direction * LUNGE_SPEED
	lunge_timer.start()

func _on_lunge_timer_timeout() -> void:
	hitbox_collision.disabled = true
	character.state_machine.transition_to("RecoveryState")
