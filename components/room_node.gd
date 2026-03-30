class_name RoomNode
extends RefCounted

var marker: String
var room_type: Enums.RoomType = Enums.RoomType.EMPTY
var connections: Dictionary[Enums.ExitDirection, RoomNode] = {}
var cleared: bool = false


func _init(p_marker: String) -> void:
	marker = p_marker

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
