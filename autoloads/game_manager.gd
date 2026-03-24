extends Node

const PLAYER_SCENE = preload("res://actors/player/player.tscn")
const FIRST_ROOM = "res://rooms/floor_1/room_01.tscn"
const FIRST_SPAWN_DIRECTION = "east"

const GAME_OVER_SCENE = preload("res://ui/game_over.tscn")
var game_over_screen: CanvasLayer

var player: CharacterBody2D
var room_states: Dictionary = {"res://rooms/floor_1/room_01.tscn": {"cleared": true}}
var current_room_path: String = ""
var incoming_spawn_direction: String = FIRST_SPAWN_DIRECTION


func _ready():
	player = PLAYER_SCENE.instantiate()
	add_child(player)

	game_over_screen = GAME_OVER_SCENE.instantiate()
	add_child(game_over_screen)
	game_over_screen.hide()

	go_to_room(FIRST_ROOM, incoming_spawn_direction)

func go_to_room(destination: String, spawn_direction: String) -> void:
	current_room_path = destination
	incoming_spawn_direction = spawn_direction

	# Ensure state entry exists
	if not room_states.has(destination):
		room_states[destination] = { "cleared": false }

	Engine.time_scale = 0.0
	await get_tree().create_timer(0.15, true, false, true).timeout
	Engine.time_scale = 1.0

	get_tree().call_deferred("change_scene_to_file", destination)

func restart_run() -> void:
	game_over_screen.hide()
	room_states.clear()
	room_states = {"res://rooms/floor_1/room_01.tscn": {"cleared": true}}
	player.is_alive = true
	Engine.time_scale = 1.0
	player.get_node("StateMachine").transition_to("IdleState")
	go_to_room(FIRST_ROOM, FIRST_SPAWN_DIRECTION)

func show_game_over() -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.2, true, false, true).timeout
	game_over_screen.show()

func mark_room_cleared(room_path: String) -> void:
	if room_states.has(room_path):
		room_states[room_path]["cleared"] = true