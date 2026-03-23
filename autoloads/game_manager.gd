extends Node

const PLAYER_SCENE = preload("res://actors/player/player.tscn")
const ROOMS = [
	"res://rooms/floor_1/room_01.tscn",
	"res://rooms/floor_1/room_02.tscn",
	"res://rooms/floor_1/room_03.tscn",
]

var player: CharacterBody2D
var current_room_index: int = 0

func _ready():
	player = PLAYER_SCENE.instantiate()
	add_child(player)

func go_to_next_room() -> void:
	current_room_index += 1
	_load_room()

func restart_run() -> void:
	current_room_index = 0
	_load_room()

func _load_room() -> void:
	get_tree().change_scene_to_file(ROOMS[current_room_index])
