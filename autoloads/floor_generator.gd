extends Node

#region Constraints
@export var _dimensions: Vector2i = Vector2i(7, 5)
@export var _start: Vector2i = Vector2i(3, 0)
@export var _critical_path_length: int = 13
@export var _branches: int = 3
@export var _branch_length: Vector2i = Vector2i(1, 4)
#endregion

var dungeon: Array
var _branch_candidates: Array[Vector2i]

@export var floors_data: Array[FloorData] = []

const MIN_COMBAT_ROOMS: int = 4
const MAX_COMBAT_ROOMS: int = 6
const BONUS_ROOM_CHANCE: float = 0.4

func _ready():
	_initialize_dungeon()
	_place_entrance()
	_generate_path(_start, _critical_path_length, "C")
	_generate_branches()
	_print_dungeon()

func _initialize_dungeon() -> void:
	for x in _dimensions.x:
		dungeon.append([])
		for y in _dimensions.y:
			dungeon[x].append(0)

func _place_entrance():
	if _start.x < 0 or _start.x >= _dimensions.x:
		_start.x = randi_range(0, _dimensions.x - 1)
	if _start.y < 0 or _start.y >= _dimensions.y:
		_start.y = randi_range(0, _dimensions.y - 1)
	dungeon[_start.x][_start.y] = "S"

func _generate_path(from: Vector2i, length: int, marker: String) -> bool:
	if length == 0:
		return true
	var current: Vector2i = from
	var direction: Vector2i

	match randi_range(0, 3):
		0: direction = Vector2i.UP
		1: direction = Vector2i.RIGHT
		2: direction = Vector2i.DOWN
		3: direction = Vector2i.LEFT
	
	for i in 4:
		if (current.x + direction.x >= 0 and current.x + direction.x < _dimensions.x and 
			current.y + direction.y >= 0 and current.y + direction.y < _dimensions.y and
			not dungeon[current.x + direction.x][current.y + direction.y]):
			current += direction
			dungeon[current.x][current.y] = marker
			if length > 1:
				_branch_candidates.append(current)
			if _generate_path(current, length - 1, marker):
				return true
			else:
				_branch_candidates.erase(current)
				dungeon[current.x][current.y] = 0
				current -= direction
		direction = Vector2i(direction.y, -direction.x)
	return false

func _generate_branches() -> void:
	var branches_created: int = 0
	var candidate: Vector2i

	while branches_created < _branches and _branch_candidates.size():
		candidate = _branch_candidates[randi_range(0, _branch_candidates.size() - 1)]
		if _generate_path(candidate, randi_range(_branch_length.x, _branch_length.y), str(branches_created + 1)):
			branches_created += 1
		else:
			_branch_candidates.erase(candidate)


func _print_dungeon() -> void:
	var dungeon_as_string: String = ""
	for y in range(_dimensions.y - 1, -1, -1):
		for x in _dimensions.x:
			if dungeon[x][y]:
				dungeon_as_string += "[" + str(dungeon[x][y]) + "]"
			else:
				dungeon_as_string += "   "
		dungeon_as_string += '\n'
	print(dungeon_as_string)

func _get_floor_data(floor_number: int) -> FloorData:
	if floor_number > floors_data.size():
		push_error("FloorGenerator: no data for floor %d" % floor_number)
		return null
	return floors_data[floor_number - 1]


func generate_floor(floor_number: int) -> Array[RoomNode]:
	var data := _get_floor_data(floor_number)
	assert(data != null, "FloorGenerator: floor data is null for floor %d" % floor_number)

	var chain: Array[RoomNode] = []

	# 1 — Entry room
	assert(data.entry_rooms.size() > 0, "FloorGenerator: no entry rooms defined for floor %d" % floor_number)
	chain.append(_make_node(_pick_random_resource(data.entry_rooms)))

	# 2 — Shuffled combat pool
	var combat_pool: Array[RoomData] = data.combat_rooms.duplicate()
	combat_pool.shuffle()
	var combat_count := mini(
		randi_range(MIN_COMBAT_ROOMS, MAX_COMBAT_ROOMS),
		combat_pool.size()
	)

	var combat_nodes: Array[RoomNode] = []
	for i in range(combat_count):
		combat_nodes.append(_make_node(combat_pool[i]))

	# 3 — Inject treasure room
	if data.treasure_rooms.size() > 0 and combat_nodes.size() >= 2:
		var idx := randi_range(1, combat_nodes.size() - 1)
		combat_nodes.insert(idx, _make_node(_pick_random_resource(data.treasure_rooms)))

	# 4 — Inject shop room
	if data.shop_rooms.size() > 0 and combat_nodes.size() >= 2:
		var idx := randi_range(1, combat_nodes.size() - 1)
		var attempts := 0
		while _node_at(combat_nodes, idx) != null \
		and combat_nodes[idx].room_type == RoomNode.RoomType.TREASURE \
		and attempts < combat_nodes.size():
			idx = (idx % (combat_nodes.size() - 1)) + 1
			attempts += 1
		combat_nodes.insert(idx, _make_node(_pick_random_resource(data.shop_rooms)))

	# 5 — Append middle section
	chain.append_array(combat_nodes)

	# 6 — Boss room
	assert(data.boss_rooms.size() > 0, "FloorGenerator: no boss rooms defined for floor %d" % floor_number)
	chain.append(_make_node(_pick_random_resource(data.boss_rooms)))

	# 7 — Wire chain
	_wire_chain(chain)

	# 8 — Attach bonus rooms to spare exits
	if data.treasure_rooms.size() > 0:
		_attach_bonus_rooms(chain, data)

	return chain

#region Wiring
func _wire_chain(chain: Array[RoomNode]) -> void:
	for i in range(chain.size() - 1):
		var current := chain[i]
		var next := chain[i + 1]
		var pair := _find_compatible_pair(current, next)

		if pair.is_empty():
			push_error("FloorGenerator: no compatible exits between '%s' and '%s'" \
				% [current.scene_path, next.scene_path])
			continue

		current.connect_to(pair[0], next)


func _attach_bonus_rooms(chain: Array[RoomNode], data: FloorData) -> void:
	for node in chain:
		var spare_exits: Array = node.available_exits.filter(
			func(e: String) -> bool: return not node.connections.has(e)
		)

		for exit_dir in spare_exits:
			if randf() >= BONUS_ROOM_CHANCE:
				continue

			var bonus := _make_node(_pick_random_resource(data.treasure_rooms))
			var incoming := RoomNode.opposite_direction(exit_dir)

			if bonus.available_exits.has(incoming):
				node.connect_to(exit_dir, bonus)
#endregion

#region Helpers
func _make_node(room_data: RoomData) -> RoomNode:
	assert(room_data != null, "FloorGenerator: RoomData is null")
	assert(room_data.scene != null, "FloorGenerator: RoomData has no scene assigned")

	var exits: Array[String] = []
	for exit in room_data.exits:
		exits.append(exit as String)

	return RoomNode.new(
		room_data.scene.resource_path,
		_type_from_path(room_data.scene.resource_path),
		exits
	)


static func _pick_random_resource(arr: Array[RoomData]) -> RoomData:
	assert(arr.size() > 0, "FloorGenerator: tried to pick from an empty pool")
	return arr[randi() % arr.size()]


static func _find_compatible_pair(a: RoomNode, b: RoomNode) -> Array:
	var preferred: Array = [
		["south", "north"],
		["east", "west"],
		["north", "south"],
		["west", "east"],
	]

	for pair in preferred:
		if a.available_exits.has(pair[0]) \
		and not a.connections.has(pair[0]) \
		and b.available_exits.has(pair[1]) \
		and not b.connections.has(pair[1]):
			return pair

	return []


static func _type_from_path(path: String) -> RoomNode.RoomType:
	if "entry" in path: return RoomNode.RoomType.ENTRY
	if "treasure" in path: return RoomNode.RoomType.TREASURE
	if "shop" in path: return RoomNode.RoomType.SHOP
	if "boss" in path: return RoomNode.RoomType.BOSS
	return RoomNode.RoomType.COMBAT


static func _node_at(arr: Array[RoomNode], idx: int) -> RoomNode:
	if idx < 0 or idx >= arr.size():
		return null
	return arr[idx]
#endregion
