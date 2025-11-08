extends Area2D


@export var max_stray_distance := 0.0
@export var dwell_time_range := Vector2.ZERO

@export var move_range := Vector2.ZERO
@export var move_smoothing := 2.0


@onready var target_pos := position
@onready var starting_pos := position


var dwell_timer := 0.0


func _physics_process(delta: float) -> void:
	dwell_timer -= delta
	if dwell_timer < 0.0:
		pick_new_target()
	
	position = position.lerp(target_pos, Math.smooth(move_smoothing, delta))


func pick_new_target() -> void:
	var test_pos := position + Math.rand_dir() * randf_range(move_range.x, move_range.y)
	
	if MapGen.instance.check_planet_pos(test_pos, 32.0) and test_pos.distance_squared_to(starting_pos) < max_stray_distance ** 2.0:
		target_pos = test_pos
		dwell_timer = randf_range(dwell_time_range.x, dwell_time_range.y)
		look_at(target_pos)


var picked_up := false

func pickup() -> void:
	if picked_up: return
	picked_up = true
	
	Inventory.add_item(RockItem.new())
	queue_free()
	
	DevTools.toast("+1 Space Fish")


func _on_body_entered(body: Node2D) -> void:
	pickup()
