class_name StateMachine
extends Node

var current_state: State
var states: Dictionary = {}


func _ready() -> void:
	# Build the states dictionary from child nodes
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.character = owner  # owner is the CharacterBody2D

	# Start in the first state
	if not states.is_empty():
		current_state = states.values()[0]
		current_state.enter()


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func transition_to(state_name: String) -> void:
	if not states.has(state_name):
		push_error("StateMachine: state not found: " + state_name)
		return

	if current_state:
		current_state.exit()

	current_state = states[state_name]
	current_state.enter()
