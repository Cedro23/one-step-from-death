extends Node

const PLAYER_SCENE = preload("res://actors/player/player.tscn")
const FIRST_ROOM = "res://rooms/floor_1/room_01.tscn"
const FIRST_SPAWN_DIRECTION = "east"

var player: CharacterBody2D
var room_states: Dictionary = {}
var current_room_path: String = ""
var incoming_spawn_direction: String = FIRST_SPAWN_DIRECTION

func _ready():
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	go_to_room(FIRST_ROOM, incoming_spawn_direction)

func go_to_room(destination: String, spawn_direction: String) -> void:
	current_room_path = destination
	incoming_spawn_direction = spawn_direction

	# Ensure state entry exists
	if not room_states.has(destination):
		room_states[destination] = { "cleared": false }

	get_tree().call_deferred("change_scene_to_file", destination)

func restart_run() -> void:
	room_states.clear()
	current_room_path = ""
	incoming_spawn_direction = ""
	Engine.time_scale = 1.0
	player.get_node("StateMachine").transition_to("IdleState")
	go_to_room(FIRST_ROOM, FIRST_SPAWN_DIRECTION)
