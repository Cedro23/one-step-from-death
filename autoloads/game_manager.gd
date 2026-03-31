extends Node

#region Scenes References
const PLAYER_SCENE = preload("res://actors/player/player.tscn")
const GAME_OVER_SCENE = preload("res://ui/game_over.tscn")
const MAP_SCENE = preload("res://ui/map.tscn")

const FIRST_FLOOR: int = 1
const FIRST_SPAWN_DIRECTION = "south"
#endregion

#region State
var player: CharacterBody2D
var game_over_screen: CanvasLayer
var map: CanvasLayer

var current_floor: int = 1
var floor_graph: Array = []
var current_room_node: RoomNode = null
var incoming_spawn_direction: String = FIRST_SPAWN_DIRECTION
#endregion

#region Initialisation
func _ready():
	generate_floor()

	map = MAP_SCENE.instantiate()
	add_child(map)
	# map.hide()
	
	map.set_map(floor_graph)

	# Generate and build the first floor of the dungeon
	#Todo: build rooms and wait for them to be built


	# player = PLAYER_SCENE.instantiate()
	# add_child(player)

	# game_over_screen = GAME_OVER_SCENE.instantiate()
	# add_child(game_over_screen)
	# game_over_screen.hide()


	# start_floor()
#endregion

#region Floor Management
func generate_floor() -> void:
	floor_graph = FloorGenerator.generate_floor(current_floor)

func start_floor() -> void:
	go_to_room(floor_graph[0], FIRST_SPAWN_DIRECTION)

func advance_floor() -> void:
	if current_floor < 3:
		current_floor += 1
		generate_floor()
		start_floor()
	else:
		# Run complete — show victory screen (M4)
		pass
#endregion

#region Room Transition
func go_to_room(room_node: RoomNode, spawn_direction: String) -> void:
	if room_node == null:
		push_error("GameManager.go_to_room: room_node is null")
		return

	current_room_node = room_node
	incoming_spawn_direction = spawn_direction

	Engine.time_scale = 0.0
	await get_tree().create_timer(0.15, true, false, true).timeout
	Engine.time_scale = 1.0

	get_tree().call_deferred("change_scene_to_file", room_node.scene_path)

func mark_room_cleared() -> void:
	if current_room_node == null:
		push_error("GameManager.mark_room_cleared: current_room_node is null")
		return

	current_room_node.cleared = true
#endregion

#region Death & Restart
func show_game_over() -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.2, true, false, true).timeout
	game_over_screen.show()

func restart_run() -> void:
	game_over_screen.hide()
	_reset_player()
	current_floor = 1
	generate_floor()
	start_floor()

func _reset_player() -> void:
	Engine.time_scale = 1.0
	player.is_alive = true
	player.get_node("StateMachine").transition_to("IdleState")
#endregion
