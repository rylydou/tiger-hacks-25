extends DraggableItemBin
class_name ItemMatcher

signal correct_item_received()
signal incorrect_item_received()
signal request_fulfilled()

@export var base_reward: int = 1

# List of correct items to accept
@export var correct_items: Array[Item.ResourceType] = []

# The primary correct item to receive
var primary_correct_item: Item.ResourceType = Item.ResourceType.NONE
@export var amount_needed: int = 1


func _ready() -> void:	
	# Initialize as receiving bin
	super._ready()
	is_receiving = true
	primary_correct_item = receiving_items[0] if not receiving_items.is_empty() else Item.ResourceType.NONE


func set_correct_items(items: Array[Item.ResourceType]) -> void:
	# Set list of items this matcher accepts as correct
	correct_items = items
	if correct_items.is_empty():
		push_warning("No correct items set for ItemMatcher")


func _try_receive_item(item_type: Item.ResourceType = Item.ResourceType.NONE) -> bool:
	# Check if item is acceptable
	#print("ItemMatcher._try_receive_item called with type: ", item_type)
	
	if not is_receiving:
		#print("  -> Not receiving")
		return false
	
	if item_type == Item.ResourceType.NONE:
		#print("  -> Invalid item type (NONE)")
		return false
	
	if not (item_type in correct_items):
		#print("  -> Item type not in correct_items: ", correct_items)
		return false
	
	#print("  -> Item acceptable, receiving...")
	# Item is acceptable, always receive it
	var result = super._try_receive_item(item_type)
	#print("  -> super._try_receive_item returned: ", result)
	
	# Check if it's correct and emit appropriate signal
	if item_type == primary_correct_item:
		#print("  -> Item is CORRECT! Rewarding...")
		Stats.add_money(int(base_reward * Stats.reward_multiplier))
		correct_item_received.emit()
		if count >= amount_needed:
			#print("  -> Request fulfilled!")
			request_fulfilled.emit()
	else:
		#print("  -> Item is INCORRECT! Penalizing...")
		Stats.add_money(int(base_reward * Stats.incorrect_multiplier))
		incorrect_item_received.emit()
	
	#print("  -> Final result: ", result)
	return result
