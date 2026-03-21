extends CharacterBody2D

var input_direction: Vector2
@export var speed: float = 200
@export var roll_speed: float = 500
@onready var sprite: Sprite2D = $Sprite2D

@onready var attack_hitbox: Area2D = $AttackHitBox
@onready var attack_hitbox_timer: Timer = $AttackHitBox/Timer
@onready var attack_hitbox_collision: CollisionShape2D = $AttackHitBox/CollisionShape2D
var is_attacking: bool = false

@onready var hurtbox: Area2D = $HurtBox
@onready var roll_timer: Timer = $RollTimer
@onready var roll_cooldown_timer: Timer = $RollCooldownTimer
var is_rolling: bool = false
var can_roll: bool = true

func get_input():
	input_direction = Input.get_vector("left", "right", "up", "down")
	
func update_sprite_direction():
	var mouse_position = get_global_mouse_position()
	if mouse_position.x < position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
#region Attack Hitbox
func trigger_attack_hitbox(position: Vector2):
	attack_hitbox.position = position
	attack_hitbox_collision.disabled = false
	is_attacking = true
	attack_hitbox_timer.start()

func _on_attack_timer_timeout() -> void:
	attack_hitbox_collision.disabled = true
	is_attacking = false
#endregion

#region Roll
func roll():
	velocity = input_direction * roll_speed
	if velocity == Vector2.ZERO:
		return
	hurtbox.monitoring = false
	can_roll = false
	is_rolling = true
	roll_timer.start()
	roll_cooldown_timer.start()

func _on_roll_timer_timeout():
	is_rolling = false
	hurtbox.monitoring = true
	
func _on_roll_cooldown_timer_timeout():
	can_roll = true
#endregion

func _physics_process(delta: float) -> void:
	get_input()
	if !is_rolling:
		velocity = input_direction * speed
	move_and_slide()

func _process(delta: float) -> void:
	update_sprite_direction()
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("click") and !is_attacking and !is_rolling:
		var hitbox_position: Vector2 = (event.position - position).normalized() * 16
		trigger_attack_hitbox(hitbox_position)
	if event.is_action_pressed("dodge") and can_roll:
		roll()

func _on_hurt_box_hit() -> void:
	get_tree().reload_current_scene()
