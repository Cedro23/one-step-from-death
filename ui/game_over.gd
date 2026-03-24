extends CanvasLayer

func _on_restart_pressed() -> void:
	Engine.time_scale = 1.0
	GameManager.restart_run()