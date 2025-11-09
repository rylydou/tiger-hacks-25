extends Item
class_name RefinedPlantItem


func _init(p_name: String = "Refined_Plant", p_icon: Texture2D = null, p_description: String = "", p_reward: int = 30) -> void:
	if p_icon == null:
		p_icon = preload("res://content/art/Interactables/refined plant.png")
	super._init(p_name, Item.ResourceType.REFINED_PLANT, p_icon, p_description, p_reward)


func use_item() -> void:
	pass
	# Plant-specific behavior here
