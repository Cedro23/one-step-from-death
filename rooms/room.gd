extends Node2D

@onready var bounds_top_left: Marker2D = $BoundsTopLeft
@onready var bounds_bottom_right: Marker2D = $BoundsBottomRight
@onready var room_area: Area2D = $RoomArea

@onready var enemies_container: Node2D = $Enemies
@onready var exits_container: Node2D = $Exits
@onready var spawn_points: Node2D = $SpawnPoints

@export var available_exits: Array[String] = []

var enemies_alive: int = 0
var player_inside: bool = false


func _ready() -> void:
	_setup_bounds()
	_place_player()
	_place_exits()

	if GameManager.current_room_node.cleared:
		_free_all_enemies()
		_unlock_exits()
	elif enemies_container.get_child_count() >= 1:
		_count_enemies()

#region Bounds & Camera
func _setup_bounds() -> void:
	var top_left = bounds_top_left.position
	var bottom_right = bounds_bottom_right.position
	var size = bottom_right - top_left
	var center = top_left + size / 2

	var shape = RectangleShape2D.new()
	shape.size = size
	var area_collision = room_area.get_node("CollisionShape2D")
	area_collision.shape = shape
	area_collision.position = center

func _setup_camera(player: Node) -> void:
	var camera = player.get_node("Camera2D")
	camera.limit_left = int(bounds_top_left.position.x)
	camera.limit_top = int(bounds_top_left.position.y)
	camera.limit_right = int(bounds_bottom_right.position.x)
	camera.limit_bottom = int(bounds_bottom_right.position.y)
#endregion

#region Player Placement
func _place_player() -> void:
	var player = GameManager.player
	if player == null:
		push_error("Room: GameManager.player is null")
	
	var spawn_point: Marker2D = _get_spawn_point(GameManager.incoming_spawn_direction)
	if spawn_point:
		player.global_position = spawn_point.global_position
	else:
		# Fallback to center of room if no matching spawn point found
		player.global_position = (bounds_top_left.global_position + bounds_bottom_right.global_position) / 2.0
		push_warning("Room: no spawn point found for direction '%s', using center" % GameManager.incoming_spawn_direction)

	_setup_camera(player)

func _get_spawn_point(direction: String) -> Marker2D:
	for child in spawn_points.get_children():
		if child.name.to_lower() == "spawn" + direction.to_lower():
			return child
	return null
#endregion

#region Exit Wiring
func _place_exits() -> void:
	for exit in exits_container.get_children():
		var direction: String = exit.exit_direction
		if GameManager.current_room_node.connections.has(direction):
			exit.destination_node = GameManager.current_room_node.connections[direction]
		else:
			# No connection in this direction - hide the door entirely
			exit.hide()
#endregion

#region Enemy Tracking
func _count_enemies() -> void:
	for enemy in enemies_container.get_children():
		enemies_alive += 1
		enemy.tree_exited.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	enemies_alive = max(0, enemies_alive - 1)
	if enemies_alive == 0 and player_inside:
		GameManager.mark_room_cleared()
		_unlock_exits()

func _free_all_enemies() -> void:
	for enemy in enemies_container.get_children():
		enemy.queue_free()
#endregion

#region Exits Lock / Unlock
func _lock_exits() -> void:
	for exit in exits_container.get_children():
		if not exit.visible:
			continue
		exit.lock()


func _unlock_exits() -> void:
	for exit in exits_container.get_children():
		if not exit.visible:
			continue
		exit.unlock()
#endregion

#region Player Entry Detection
func _on_room_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not player_inside:
		player_inside = true

		if not GameManager.current_room_node.cleared:
			if enemies_alive >= 1:
				_lock_exits()
#endregion
