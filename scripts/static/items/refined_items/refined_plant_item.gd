extends Item
class_name RefinedPlantItem


func _init(p_name: String = "Refined_Plant", p_icon: Texture2D = null, p_description: String = "") -> void:
	super._init(p_name, Item.ResourceType.REFINED_PLANT, p_icon, p_description)


func use_item() -> void:
	pass
	# Plant-specific behavior here
