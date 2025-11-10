extends CanvasItem


@export var is_pause_menu := false


func _ready() -> void:
	randomize()


func _process(delta: float) -> void:
	if not is_pause_menu: return
	
	if Input.is_action_just_pressed(&"pause"):
		if get_tree().paused:
			resume()
		else:
			pause()


func play() -> void:
	Game.transition_to_file("res://scenes/test-ryly.tscn", "HERE GOES NOTHING...")


func quit() -> void:
	get_tree().quit()


func main_menu() -> void:
	hide()
	Game.transition_to_file("res://scenes/main.tscn", "MAIN MENUING...")


func resume() -> void:
	get_tree().paused = false
	hide()


func pause() -> void:
	get_tree().paused = true
	show()
