extends Node2D

@onready var bounds_top_left = $BoundsTopLeft
@onready var bounds_bottom_right = $BoundsBottomRight
@onready var room_area = $RoomArea

@onready var enemies_node = $Enemies
@onready var exits_node = $Exits

var is_player_inside: bool = false
var enemies_alive: int = 0


func _ready() -> void:
	_setup_bounds()
	_setup_doors()
	_place_player()
	_check_room_state()

func _setup_bounds() -> void:
	var top_left = bounds_top_left.position
	var bottom_right = bounds_bottom_right.position
	var size = bottom_right - top_left
	var center = top_left + size / 2

	var shape = RectangleShape2D.new()
	shape.size = size
	room_area.get_node("CollisionShape2D").shape = shape
	room_area.get_node("CollisionShape2D").position = center

func _setup_doors() -> void:
	for door in exits_node.get_children():
		if not door.player_exited.is_connected(_on_player_exited):
			door.player_exited.connect(_on_player_exited)

func _place_player() -> void:
	var player = GameManager.player
	var spawn_name = "Spawn" + GameManager.incoming_spawn_direction.capitalize()
	var spawn_points = $SpawnPoints

	if spawn_points.has_node(spawn_name):
		player.global_position = spawn_points.get_node(spawn_name).global_position
	else:
		# Fallback to first available spawn point
		player.global_position = spawn_points.get_child(0).global_position

	_setup_camera(player)

func _check_room_state() -> void:
	var state = GameManager.room_states.get(scene_file_path, {})
	if state.get("cleared", false):
		_free_all_enemies()
		_unlock_exits()
	else:
		_count_enemies()
		_lock_exits()

func _count_enemies() -> void:
	for enemy in enemies_node.get_children():
		enemies_alive += 1
		enemy.tree_exited.connect(_on_enemy_died)

func _on_room_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_inside = true
		if enemies_alive > 0:
			_lock_exits()

func _setup_camera(player: Node) -> void:
	var camera = player.get_node("Camera2D")
	camera.limit_left = int(bounds_top_left.position.x)
	camera.limit_top = int(bounds_top_left.position.y)
	camera.limit_right = int(bounds_bottom_right.position.x)
	camera.limit_bottom = int(bounds_bottom_right.position.y)

func _lock_exits() -> void:
	for door in exits_node.get_children():
		door.lock()


func _unlock_exits() -> void:
	for door in exits_node.get_children():
		door.unlock()

func _free_all_enemies() -> void:
	for enemy in enemies_node.get_children():
		enemy.queue_free()

func _on_enemy_died() -> void:
	enemies_alive = max(0, enemies_alive - 1)
	if enemies_alive == 0 and is_player_inside:
		_mark_cleared()
		_unlock_exits()

func _mark_cleared() -> void:
	GameManager.mark_room_cleared(scene_file_path)

func _on_player_exited(destination: String, spawn_direction: String) -> void:
	GameManager.go_to_room(destination, spawn_direction)
