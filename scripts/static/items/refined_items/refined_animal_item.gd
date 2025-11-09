extends Item
class_name RefinedAnimalItem


func _init(p_name: String = "Refined_Animal", p_icon: Texture2D = null, p_description: String = "", p_reward: int = 120) -> void:
	if p_icon == null:
		p_icon = preload("res://content/art/Interactables/refined fish.png")
	super._init(p_name, Item.ResourceType.REFINED_ANIMAL, p_icon, p_description, p_reward)


func use_item() -> void:
	pass
	# Animal-specific behavior here
