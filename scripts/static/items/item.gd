class_name Item


#unforuntately I have it so you must update this enum as well as the get_type_string function manually
enum ResourceType { NONE, ROCK, ANIMAL, PLANT, REFINED_ROCK, REFINED_ANIMAL, REFINED_PLANT }

var resource_type: ResourceType = ResourceType.NONE
var item_name: String = "Item"
var icon: Texture2D = preload("res://icon.svg")
var description: String = "Description of the item."
var processing_duration: float = 5.0
var sprite_scale: Vector2 = Vector2.ONE *15


func _init(p_name: String = "Item", p_type: ResourceType = ResourceType.ROCK, p_icon: Texture2D = preload("res://icon.svg"), p_description: String = "", p_sprite_scale: Vector2 = Vector2.ONE * 15) -> void:
	item_name = p_name
	resource_type = p_type
	icon = p_icon
	description = p_description
	sprite_scale = p_sprite_scale
	processing_duration = 5.0

# This isnt used rn but might be useful later
func get_type_string() -> String:
	match resource_type:
		ResourceType.ROCK:
			return "Boom Rock"
		ResourceType.ANIMAL:
			return "Space Fish"
		ResourceType.PLANT:
			return "Zen Fruit"
		ResourceType.REFINED_ROCK:
			return "Refined Minerals"
		ResourceType.REFINED_ANIMAL:	
			return "Fish Fillet"
		ResourceType.REFINED_PLANT:
			return "Refined Plant"
	return "Unknown"


# virtual - override in subclasses for type-specific behavior
func use_item() -> void:
	print("Using item: ", item_name)
