extends Node
#region Constraints
@export_group("Constraints")
@export var _dimensions: Vector2i = Vector2i(7, 5)
@export var _start: Vector2i = Vector2i(3, 0)
@export var _end_path_bucket: Array[Enums.RoomType] = [Enums.RoomType.TREASURE, Enums.RoomType.SHOP, Enums.RoomType.CAMP]
@export_subgroup("Critical path")
@export var _crit_path_coef: float = 2.5
@export var _crit_path_const: Vector2i = Vector2i(4, 6)
@export var _crit_path_max: int = 20
@export var _branches: int = 3
@export var _branch_length: Vector2i = Vector2i(1, 4)
#endregion

var dungeon: Array
var _branch_candidates: Array[Vector2i]

func generate_floor(depth: int):
	_initialize_dungeon()
	_place_entrance()
	var critical_path_length = mini(roundi(_crit_path_coef * depth * randi_range(_crit_path_const.x, _crit_path_const.y)), roundi(_crit_path_max * depth / 2.0))
	_generate_path(_start, critical_path_length, [Enums.RoomType.BOSS])
	_generate_branches()
	_print_dungeon()
	return dungeon

func _initialize_dungeon() -> void:
	for x in _dimensions.x:
		dungeon.append([])
		for y in _dimensions.y:
			dungeon[x].append(null)

func _place_entrance():
	if _start.x < 0 or _start.x >= _dimensions.x:
		_start.x = randi_range(0, _dimensions.x - 1)
	if _start.y < 0 or _start.y >= _dimensions.y:
		_start.y = randi_range(0, _dimensions.y - 1)

	var room = RoomNode.new("S")
	room.set_type(Enums.RoomType.ENTRY)
	dungeon[_start.x][_start.y] = room

func _generate_path(from: Vector2i, length: int, end_of_path: Array[Enums.RoomType]) -> bool:
	if length == 0:
		return true
	var current: Vector2i = from
	var destination: Vector2i
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
			var room_node = RoomNode.new("P")
			if length <= 1:
				var room_type = end_of_path[randi_range(0, len(end_of_path) - 1)]
				room_node.set_type(room_type)
				end_of_path.erase(room_type)
			else:
				room_node.set_type(Enums.RoomType.COMBAT)

			dungeon[current.x][current.y].add_connection(Utils.direction_from_vector(direction), room_node)
			destination = current + direction
			
			dungeon[destination.x][destination.y] = room_node

			if length > 1:
				_branch_candidates.append(destination)
			if _generate_path(destination, length - 1, end_of_path):
				return true
			else:
				dungeon[current.x][current.y].remove_connection(Utils.direction_from_vector(direction))
				_branch_candidates.erase(destination)
				dungeon[destination.x][destination.y] = null
		direction = Vector2i(direction.y, -direction.x)
	return false

func _generate_branches() -> void:
	var branches_created: int = 0
	var candidate: Vector2i

	while branches_created < _branches and _branch_candidates.size():
		candidate = _branch_candidates[randi_range(0, _branch_candidates.size() - 1)]
		if _generate_path(candidate, randi_range(_branch_length.x, _branch_length.y), _end_path_bucket):
			branches_created += 1
		else:
			_branch_candidates.erase(candidate)


func _print_dungeon() -> void:
	var dungeon_as_string: String = ""
	for y in range(_dimensions.y - 1, -1, -1):
		for x in _dimensions.x:
			if dungeon[x][y]:
				dungeon_as_string += "[" + str(dungeon[x][y].room_type) + "]"
			else:
				dungeon_as_string += "   "
		dungeon_as_string += '\n'
	print(dungeon_as_string)
