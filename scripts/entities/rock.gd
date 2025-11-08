extends StaticBody2D


var picked_up := false

func _interact() -> void:
	if picked_up: return
	picked_up = true
	DevTools.toast("+1 Boom Rock")
	Inventory.add_item(RockItem.new())
	SFX.event(&"sfx/pickup", &"rock").at(self).play()
	queue_free()
