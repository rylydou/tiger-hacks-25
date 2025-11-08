extends Node2D


func _process(delta: float) -> void:
	position = get_parent().global_position
	
	var camera := get_viewport().get_camera_2d()
	
	rotation = camera.global_rotation
