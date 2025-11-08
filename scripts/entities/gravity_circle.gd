@tool
class_name GravityZone extends Area2D


@export var radius := 64.0:
	set(value):
		radius = value
		update()

@export var graphic: Node2D
@export var shape: CollisionShape2D


func _ready() -> void:
	update()


func update() -> void:
	if is_instance_valid(graphic) and is_instance_valid(shape):
		graphic.scale = Vector2.ONE * radius * 2.0 * 1.2
		shape.shape.radius = radius
