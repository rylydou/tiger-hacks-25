extends StaticBody2D


var picked_up := false

func _interact() -> void:
	if picked_up: return
	
	if Inventory.is_full():
		DevTools.toast("Inventory is full")
		return
	
	picked_up = true
	DevTools.toast("+1 Boom Rock")
	Inventory.add_item(RockItem.new())
	SFX.event(&"sfx/pickup", &"rock").at(self).play()
	queue_free()
	
	Player.instance.velocity += global_position.direction_to(Player.instance.position) * 1000.0
