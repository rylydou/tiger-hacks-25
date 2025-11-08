extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Stats:
		Stats.connect("money_changed", Callable(self, "_on_money_changed"))
		_on_money_changed(Stats.current_money)

func _on_money_changed(new_money: int) -> void:
	text = str(new_money)
