extends Area2D


@export var prompt: CanvasItem


func _on_body_entered(body: Node2D) -> void:
	prompt.show()
	get_tree().paused = true
	SFX.event(&"ui/click").play()


func resume() -> void:
	get_tree().paused = false
	prompt.hide()
	SFX.event(&"ui/click").play()


func goto_shop() -> void:
	SFX.event(&"ui/shop").play()
	Game.transition_to_file("res://scenes/test-Ian.tscn", "LET'S GET SELLING!")
