class_name ExitDoor
extends Area2D

signal player_exited

@export var exit_direction: String = "south"
@export var horizontal: bool = true

var destination_node: RoomNode = null

@onready var blocking_body = $BlockingBody
@onready var visual = $Polygon2D
@onready var blocking_collision: CollisionShape2D = $BlockingBody/CollisionShape2D
@onready var area_collision: CollisionShape2D = $CollisionShape2D

var locked: bool = false


func _ready() -> void:
	_setup_orientation()
	unlock()

#region Orientation
func _setup_orientation() -> void:
	var long_side = 32.0
	var short_side = 6.0

	var door_size: Vector2 = Vector2(long_side, short_side) if horizontal else Vector2(short_side, long_side)

	# Area2D trigger shape
	var area_rect = RectangleShape2D.new()
	area_rect.size = door_size
	area_collision.shape = area_rect

	# BlockingBody shape
	var block_rect = RectangleShape2D.new()
	block_rect.size = door_size
	blocking_collision.shape = block_rect

	# Visual polygon
	var half: Vector2 = door_size / 2.0
	visual.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y)
	])
#endregion

#region Lock / Unlock
func lock() -> void:
	locked = true
	blocking_body.process_mode = Node.PROCESS_MODE_INHERIT
	visual.color = Color(0.7, 0.1, 0.1)

func unlock() -> void:
	locked = false
	blocking_body.process_mode = Node.PROCESS_MODE_DISABLED
	visual.color = Color(0.1, 0.7, 0.1)
#endregion

#region Player Detection
func _on_body_entered(body: Node) -> void:
	if locked:
		return
	if not body.is_in_group("player"):
		return
	if destination_node == null:
		push_error("ExitDoor: destination_node is null on '%s'" % name)
	
	player_exited.emit()
	GameManager.go_to_room(destination_node, _incoming_direction())

func _incoming_direction() -> String:
	return RoomNode.opposite_direction(exit_direction)
#endregion