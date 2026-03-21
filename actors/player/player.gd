extends CharacterBody2D

@export var speed: float = 200
@onready var sprite: Sprite2D = $Sprite2D

@onready var attack_hitbox: Area2D = $AttackHitBox
@onready var attack_hitbox_timer: Timer = $AttackHitBox/Timer
@onready var attack_hitbox_collision: CollisionShape2D = $AttackHitBox/CollisionShape2D
var is_attacking: bool = false

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
func update_sprite_direction():
	var mouse_position = get_global_mouse_position()
	if mouse_position.x < position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
func trigger_attack_hitbox(position: Vector2):
	attack_hitbox.position = position
	attack_hitbox_collision.disabled = false
	is_attacking = true
	attack_hitbox_timer.start()

func _on_timer_timeout() -> void:
	attack_hitbox_collision.disabled = true
	is_attacking = false

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()

func _process(delta: float) -> void:
	update_sprite_direction()
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("click") and !is_attacking:
		var hitbox_position: Vector2 = (event.position - position).normalized() * 16
		trigger_attack_hitbox(hitbox_position)
	
