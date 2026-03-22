class_name Shambler
extends CharacterBody2D

@export var run_speed: float = 40.0
@export var lunge_speed: float = 300.0
@export var lunge_detection_distance: float = 60.0
@export var player_escape_range: float = 180.0

@onready var state_machine: StateMachine = $StateMachine

func _on_hurtbox_hit() -> void:
	state_machine.transition_to("DeathState")
