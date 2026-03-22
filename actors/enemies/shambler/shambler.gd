class_name Shambler
extends CharacterBody2D

@onready var state_machine: StateMachine = $StateMachine

func _on_hurtbox_hit() -> void:
	queue_free()
