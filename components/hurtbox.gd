extends Area2D

signal hit

@export var size: int = 10
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	collision_shape.shape.set_size(Vector2(size, size))

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("hitbox"):
		hit.emit()
