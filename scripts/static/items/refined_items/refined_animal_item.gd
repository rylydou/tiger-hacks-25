extends Item
class_name RefinedAnimalItem


func _init(p_name: String = "Refined_Animal", p_icon: Texture2D = null, p_description: String = "") -> void:
	if p_icon == null:
		p_icon = preload("res://content/art/Interactables/refined fish.png")
	super._init(p_name, Item.ResourceType.REFINED_ANIMAL, p_icon, p_description)


func use_item() -> void:
	pass
	# Animal-specific behavior here
