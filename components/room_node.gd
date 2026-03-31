class_name RoomNode
extends RefCounted

var position: Vector2i = Vector2i.ZERO
var room_type: Enums.RoomType = Enums.RoomType.EMPTY
var connections: Dictionary[Enums.ExitDirection, RoomNode] = {}
var cleared: bool = false

func _init(p_position: Vector2i) -> void:
	position = p_position

func set_type(type: Enums.RoomType) -> void:
	room_type = type

func add_connection(direction: Enums.ExitDirection, node: RoomNode) -> void:
	if !connections.has(direction):
		connections[direction] = node
		node.add_connection(Utils.opposite_direction(direction), self)

func remove_connection(direction: Enums.ExitDirection) -> void:
	if connections.has(direction):
		connections[direction].remove_connection(direction)
	connections.erase(direction)
