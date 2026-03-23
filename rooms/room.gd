extends Node2D

@onready var bounds_top_left = $BoundsTopLeft
@onready var bounds_bottom_right = $BoundsBottomRight
@onready var room_area = $RoomArea

@onready var doors: Array[Node]

var is_player_inside: bool = false
var enemies_alive: int = 0

func _ready() -> void:
	_setup_bounds()
	_place_player()
	_count_enemies()
	doors = get_tree().get_nodes_in_group("door")

func _setup_bounds() -> void:
	var top_left = bounds_top_left.position
	var bottom_right = bounds_bottom_right.position
	var size = bottom_right - top_left
	var center = top_left + size / 2

	var shape = RectangleShape2D.new()
	shape.size = size
	room_area.get_node("CollisionShape2D").shape = shape
	room_area.get_node("CollisionShape2D").position = center

func _place_player() -> void:
	var game_manager = get_node("/root/GameManager")
	var player = game_manager.player
	player.global_position = $SpawnPoint.global_position

func _count_enemies() -> void:
	for enemy in $Enemies.get_children():
		enemies_alive += 1
		enemy.tree_exited.connect(_on_enemy_died)

func _on_room_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_inside = true
		_toggle_exits(false)
		_setup_camera(body)

func _setup_camera(player: Node) -> void:
	var camera = player.get_node("Camera2D")
	camera.limit_left = int(bounds_top_left.position.x)
	camera.limit_top = int(bounds_top_left.position.y)
	camera.limit_right = int(bounds_bottom_right.position.x)
	camera.limit_bottom = int(bounds_bottom_right.position.y)

func _toggle_exits(open: bool) -> void:
	for door in doors:
		door.get_node("CollisionShape2D").disabled = open

func _on_enemy_died() -> void:
	enemies_alive = max(0, enemies_alive - 1)
	if enemies_alive == 0 and is_player_inside:
		_toggle_exits(true)
