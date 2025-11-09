extends Area2D


@export var prompt: CanvasItem


func _on_body_entered(body: Node2D) -> void:
	prompt.show()
	get_tree().paused = true
	SFX.event(&"ui/click").at(self).play()


func resume() -> void:
	get_tree().paused = false
	prompt.hide()
	SFX.event(&"ui/click").at(self).play()


func goto_shop() -> void:
	Game.transition_to_file("res://scenes/test-Ian.tscn", "LET'S GET SELLING!")
	SFX.event(&"ui/shop").at(self).play()
