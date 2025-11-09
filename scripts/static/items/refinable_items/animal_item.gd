extends Item
class_name AnimalItem


func _init(p_name: String = "Animal", p_icon: Texture2D = null, p_description: String = "", p_reward: int = 60) -> void:
	if p_icon == null:
		p_icon = preload("res://content/art/Interactables/fish icon small.png")
	super._init(p_name, Item.ResourceType.ANIMAL, p_icon, p_description, p_reward)


func use_item() -> void:
	pass
	# Animal-specific behavior here
