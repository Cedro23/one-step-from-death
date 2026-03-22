class_name Player
extends CharacterBody2D

@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: Sprite2D = $Sprite2D

var input_direction: Vector2
var mouse_position: Vector2



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
