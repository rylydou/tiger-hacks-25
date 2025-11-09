extends Node2D

@export var EndGameButton: Button
@export var rq_mngr: RequestManager

func _ready() -> void:
	# Stop request manager while in shop
	EndGameButton.hide()
	if rq_mngr:
		rq_mngr.set_process(false)

	Inventory.item_removed.connect(_on_item_removed)


func _start_game() -> void:
	if rq_mngr:
		rq_mngr.set_process(true)


func _on_item_removed(item: Item) -> void:
	if Inventory.items.size() <= 0:
		EndGameButton.show()

func _end_game() -> void:
	get_tree().change_scene_to_file("res://scenes/test-ryly.tscn")
