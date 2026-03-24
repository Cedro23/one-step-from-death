class_name FloorGenerator
extends Node

const FLOOR_POOLS = {
	1: {
		"entry": [{
			"path": "res://rooms/floor_1/entry_01.tscn",
			"exits": ["north"]
		}],
		"combat": [{
			"path": "res://rooms/floor_1/room_01.tscn",
			"exits": ["south", "east"]
		},
		{
			"path": "res://rooms/floor_1/room_02.tscn",
			"exits": ["west"]
		}],
		"treasure": [],
		"shop": [],
		"boss": []
	},
	2: {},
	3: {}
}

const MIN_COMBAT_ROOMS: int = 4
const MAX_COMBAT_ROOMS: int = 6
const BONUS_ROOM_CHANCE: float = 0.4

func generate_floor(floor_number: int) -> Array[RoomNode]:
	assert(FLOOR_POOLS.has(floor_number), \
		"FloorGenerator: no pool defined for floor %d" % floor_number)

	var pool: Dictionary = FLOOR_POOLS[floor_number]
	var chain: Array[RoomNode] = []

	# 1 — Entry room (always first, always safe)
	chain.append(_make_node(pool["entry"][0]))

	# 2 — Build shuffled combat pool
	var combat_data: Array = pool["combat"].duplicate()
	combat_data.shuffle()
	var combat_count: int = mini(randi_range(MIN_COMBAT_ROOMS, MAX_COMBAT_ROOMS), combat_data.size())

	var combat_nodes: Array[RoomNode] = []
	for i in range(combat_count):
		combat_nodes.append(_make_node(combat_data[i]))

	# 3 — Inject treasure room at a random interior position
	if pool["treasure"].size() > 0:
		var treasure_idx: int = randi_range(1, maxi(1, combat_nodes.size() - 1))
		combat_nodes.insert(treasure_idx, _make_node(_pick_random(pool["treasure"])))

	# 4 — Inject shop room at a different interior position
	if pool["shop"].size() > 0:
		var shop_idx:int = randi_range(1, maxi(1, combat_nodes.size() - 1))
		# Make sure shop doesn't land on the same index as treasure
		while combat_nodes[shop_idx].room_type == RoomNode.RoomType.TREASURE \
		and combat_nodes.size() > 2:
			shop_idx = (shop_idx + 1) % (combat_nodes.size() - 1) + 1
		combat_nodes.insert(shop_idx, _make_node(_pick_random(pool["shop"])))

	# 5 — Append combat+special rooms to chain
	chain.append_array(combat_nodes)

	# 6 — Boss room (always last)
	chain.append(_make_node(_pick_random(pool["boss"])))

	# 7 — Wire the main chain together
	_wire_chain(chain)

	# 8 — Optionally attach bonus rooms to spare exits
	if pool["treasure"].size() > 0:
		_attach_bonus_rooms(chain, pool)

	return chain

#region Wiring
func _wire_chain(chain: Array[RoomNode]) -> void:
	for i in range(chain.size() - 1):
		var current: RoomNode = chain[i]
		var next: RoomNode = chain[i + 1]

		var pair: Array[String] = _find_compatible_pair(current, next)
		if pair.is_empty():
			push_error("FloorGenerator: no compatible exits between '%s' and '%s'" % [current.scene_path, next.scene_path])
			continue

		current.connect_to(pair[0], next)

func _attach_bonus_rooms(chain: Array[RoomNode], pool: Dictionary) -> void:
	for node in chain:
		# Find exits that weren't used in the main chain
		var spare_exits: Array[String] = node.available_exits.filter(
			func(e: String) -> bool: return not node.connections.has(e)
		)

		for exit_dir in spare_exits:
			if randf() < BONUS_ROOM_CHANCE and pool["treasure"].size() > 0:
				var bonus: RoomNode = _make_node(_pick_random(pool["treasure"]))
				# Only attach if the bonus room has a compatible incoming exit
				var incoming: String = RoomNode.opposite_direction(exit_dir)
				if bonus.available_exits.has(incoming):
					node.connect_to(exit_dir, bonus)
#endregion

#region Helpers
func _make_node(data: Dictionary) -> RoomNode:
	return RoomNode.new(data["path"], _type_from_path(data["path"]), data["exits"])

static func _pick_random(arr: Array) -> Dictionary:
	assert(arr.size() > 0, "FloorGenerator: tried to pick from an empty pool")
	return arr[randi() % arr.size()]

static func _find_compatible_pair(a: RoomNode, b: RoomNode) -> Array:
	var preferred = [
		["south", "north"],
		["east",  "west"],
		["north", "south"],
		["west",  "east"]
	]

	for pair in preferred:
		var a_exit: String = pair[0]
		var b_exit: String = pair[1]

		if a.available_exits.has(a_exit) \
		and not a.connections.has(a_exit) \
		and b.available_exits.has(b_exit) \
		and not b.connections.has(b_exit):
			return pair

	return []

static func _type_from_path(path: String) -> RoomNode.RoomType:
	if "entry" in path: return RoomNode.RoomType.ENTRY
	if "treasure" in path: return RoomNode.RoomType.TREASURE
	if "shop" in path: return RoomNode.RoomType.SHOP
	if "boss" in path: return RoomNode.RoomType.BOSS
	return RoomNode.RoomType.COMBAT
#endregion