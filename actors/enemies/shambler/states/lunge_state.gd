extends State

const HITBOX_DISTANCE: float = 16.0

var player: CharacterBody2D
var direction: Vector2
var lunge_windup_timer: Timer
var lunge_timer: Timer
var hitbox: Area2D
var hitbox_collision: CollisionShape2D
var rotation: float

func enter() -> void:
	# Resolve references at enter time, not at ready time
	lunge_windup_timer = character.get_node("LungeWindupTimer")
	lunge_timer = character.get_node("LungeTimer")

	# Connect signals if not already connected
	if not lunge_windup_timer.timeout.is_connected(_on_lunge_windup_timer_timeout):
		lunge_windup_timer.timeout.connect(_on_lunge_windup_timer_timeout)
	if not lunge_timer.timeout.is_connected(_on_lunge_timer_timeout):
		lunge_timer.timeout.connect(_on_lunge_timer_timeout)
	
	hitbox = character.get_node("Hitbox")
	hitbox_collision = character.get_node("Hitbox/CollisionShape2D")

	direction = (GameManager.player.global_position - character.global_position).normalized()
	rotation = GameManager.player.global_position.angle_to_point(character.global_position)

	hitbox.position = direction * HITBOX_DISTANCE
	hitbox.rotation = rotation
	character.velocity = Vector2.ZERO

	lunge_windup_timer.start()


func physics_update(_delta: float) -> void:
	character.move_and_slide()


func _on_lunge_windup_timer_timeout() -> void:
	hitbox_collision.disabled = false
	character.velocity = direction * character.lunge_speed
	lunge_timer.start()


func _on_lunge_timer_timeout() -> void:
	hitbox_collision.disabled = true
	character.state_machine.transition_to("RecoveryState")