extends Item
class_name RefinedRockItem


func _init(p_name: String = "Refined_Rock", p_icon: Texture2D = null, p_description: String = "") -> void:
	if p_icon == null:
		p_icon = preload("res://content/art/Interactables/refined rock.png")
	super._init(p_name, Item.ResourceType.REFINED_ROCK, p_icon, p_description)


func use_item() -> void:
	pass
	# Rock-specific behavior here
