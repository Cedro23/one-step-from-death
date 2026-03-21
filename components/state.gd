class_name State
extends Node

# Reference to the owner of this state (player, shambler, etc.)
# Set by the StateMachine on initialization
var character: CharacterBody2D


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
