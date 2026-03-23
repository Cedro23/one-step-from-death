class_name ExitDoor
extends Area2D

signal player_exited

@export var horizontal: bool = true  # true = horizontal door, false = vertical door

@onready var blocking_body = $BlockingBody
@onready var visual = $Polygon2D

var locked: bool = true


func _ready() -> void:
	_setup_orientation()


func _setup_orientation() -> void:
	var long_side = 32.0
	var short_side = 6.0

	var door_size: Vector2

	if horizontal:
		door_size = Vector2(long_side, short_side)
	else:
		door_size = Vector2(short_side, long_side)

	# Resize the trigger Area2D shape
	var area_shape = $CollisionShape2D
	var rect = RectangleShape2D.new()
	rect.size = door_size
	area_shape.shape = rect

	# Resize the blocking body shape
	var block_shape = $BlockingBody/CollisionShape2D
	var block_rect = RectangleShape2D.new()
	block_rect.size = door_size
	block_shape.shape = block_rect

	# Resize the visual
	visual.polygon = PackedVector2Array([
		-door_size / 2,
		Vector2(door_size.x / 2, -door_size.y / 2),
		door_size / 2,
		Vector2(-door_size.x / 2, door_size.y / 2),
	])


func lock() -> void:
	locked = true
	blocking_body.process_mode = Node.PROCESS_MODE_INHERIT
	visual.color = Color.RED


func unlock() -> void:
	locked = false
	blocking_body.process_mode = Node.PROCESS_MODE_DISABLED
	visual.color = Color.GREEN


func _on_body_entered(body: Node) -> void:
	if locked:
		return
	if body.is_in_group("player"):
		player_exited.emit()