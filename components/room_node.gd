class_name RoomNode
extends RefCounted

enum RoomType { ENTRY, COMBAT, TREASURE, SHOP, BOSS }

var scene_path: String
var room_type: RoomType
var available_exits: Array[String]
var connections: Dictionary = {}  # { "north": RoomNode, ... }
var cleared: bool = false


func _init(p_path: String, p_type: RoomType, p_exits: Array[String]) -> void:
	scene_path = p_path
	room_type = p_type
	available_exits = p_exits


func connect_to(direction: String, other: RoomNode) -> void:
	assert(available_exits.has(direction),
		"RoomNode: '%s' has no '%s' exit" % [scene_path, direction])
	assert(other.available_exits.has(opposite_direction(direction)),
		"RoomNode: '%s' has no '%s' exit" % [other.scene_path, opposite_direction(direction)])
	assert(not connections.has(direction),
		"RoomNode: '%s' already has a connection to the '%s'" % [scene_path, direction])

	connections[direction] = other
	other.connections[opposite_direction(direction)] = self


static func opposite_direction(direction: String) -> String:
	match direction:
		"north": return "south"
		"south": return "north"
		"east":  return "west"
		"west":  return "east"
	return ""