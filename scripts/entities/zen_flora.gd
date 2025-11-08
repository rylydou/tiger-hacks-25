extends Area2D


var picked_up := false

func _interact() -> void:
	if picked_up: return
	picked_up = true
	DevTools.toast("+1 Zen Fruit")
	Inventory.add_item(PlantItem.new())
	SFX.event(&"sfx/pickup", &"plant").at(self).play()
	queue_free()
