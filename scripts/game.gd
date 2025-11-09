extends CanvasLayer


@export var trans_animation_player: AnimationPlayer
@export var flavor_text_label: Label


var _transitioning_to := ""


func transition_to_file(file: String, flavor_text := "", pause := true) -> void:
	Engine.time_scale = 1.0
	flavor_text_label.text = flavor_text
	_transition_to_file(file, pause)


func _transition_to_file(file: String, pause := true) -> void:
	if pause:
		get_tree().paused = true
	
	if not _transitioning_to:
		trans_animation_player.play(&"fade_in")
	
	_transitioning_to = file

func _do_scene_transition() -> void:
	if _transitioning_to == "RELOAD":
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file(_transitioning_to)
	get_tree().paused = false
	_transitioning_to = ""
	trans_animation_player.play(&"fade_out")
