extends Node

#region Scenes References
const PLAYER_SCENE = preload("res://actors/player/player.tscn")
const GAME_OVER_SCENE = preload("res://ui/game_over.tscn")

const FIRST_FLOOR: int = 1
const FIRST_SPAWN_DIRECTION = "south"
#endregion

#region State
var player: CharacterBody2D
var game_over_screen: CanvasLayer

var current_floor: int = 1
var floor_graph: Array[RoomNode] = []
var current_room_node: RoomNode = null
var incoming_spawn_direction: String = FIRST_SPAWN_DIRECTION
#endregion

#region Initialisation
func _ready():
	# player = PLAYER_SCENE.instantiate()
	# add_child(player)

	# game_over_screen = GAME_OVER_SCENE.instantiate()
	# add_child(game_over_screen)
	# game_over_screen.hide()

	start_floor(FIRST_FLOOR)
#endregion

#region Floor Management
func start_floor(floor_number: int) -> void:
	current_floor = floor_number
	floor_graph = FloorGenerator.generate_floor(floor_number)
	# go_to_room(floor_graph[0], FIRST_SPAWN_DIRECTION)

func advance_floor() -> void:
	if current_floor < 3:
		start_floor(current_floor + 1)
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
	start_floor(FIRST_FLOOR)

func _reset_player() -> void:
	Engine.time_scale = 1.0
	player.is_alive = true
	player.get_node("StateMachine").transition_to("IdleState")
#endregion