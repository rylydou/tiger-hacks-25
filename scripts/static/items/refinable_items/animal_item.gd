extends Item
class_name AnimalItem


func _init(p_name: String = "Animal", p_icon: Texture2D = null, p_description: String = "") -> void:
	super._init(p_name, Item.ResourceType.ANIMAL, p_icon, p_description)


func use_item() -> void:
	pass
	# Animal-specific behavior here
