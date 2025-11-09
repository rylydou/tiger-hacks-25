extends Item
class_name RockItem


func _init(p_name: String = "Rock", p_icon: Texture2D = null, p_description: String = "", p_reward: int = 30) -> void:
	if p_icon == null:
		p_icon = preload("res://content/art/Interactables/rock icon small.png")
	super._init(p_name, Item.ResourceType.ROCK, p_icon, p_description, p_reward)


func use_item() -> void:
	pass
	# Rock-specific behavior here
