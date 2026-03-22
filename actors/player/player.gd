class_name Player
extends CharacterBody2D

@export var run_speed: float = 100.0
@export var attack_range: float = 16.0
@export var roll_speed: float = 250.0

@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: Sprite2D = $Sprite2D

var input_direction: Vector2
var mouse_position: Vector2

var can_attack: bool = true
var can_roll: bool = true

func get_input() -> void:
	input_direction = Input.get_vector("left", "right", "up", "down")
	
func update_sprite_direction():
	if mouse_position.x < position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _process(_delta: float) -> void:
	mouse_position = get_global_mouse_position()
	update_sprite_direction()

func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()

func _on_hurtbox_hit() -> void:
	state_machine.transition_to("DeathState")

func _on_roll_cooldown_timer_timeout() -> void:
	can_roll = true

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
