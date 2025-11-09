class_name Planet extends Node2D


enum Type {
	Misc,
	Mineral,
	Flora,
}


@export var pool_weight := 6.0

@export var gravity_radius := 400.0
@export var inner_safe_radius := 300.0


@export var can_be_misc := true
@export var can_be_mineral := true
@export var can_be_flora := true


@export var spawn_worm_odds := 1.0
@export var spawn_flora_odds := 1.0
@export var spawn_mineral_odds := 1.0


var type := Type.Misc


var run_setup := false
var is_setup := false


func _ready() -> void:
	setup()


func setup() -> void:
	if not run_setup: return
	if is_setup: return
	is_setup = true
	
	var shape: SS2D_Shape = $"SS2D_Shape"
	var atmosphere: MeshInstance2D = $"Atmosphere"
	
	randomize_types()
	
	var material_pool: Array[SS2D_Material_Shape] = []
	
	match type:
		Type.Misc: material_pool = Global.materials_misc
		Type.Mineral: material_pool = Global.materials_mineral
		Type.Flora: material_pool = Global.materials_flora
	
	var material := material_pool.pick_random()
	
	if material:
		shape.shape_material = material
		shape.force_update()
	
	atmosphere.texture = Global.atmospheres.pick_random()
	atmosphere.scale *= 1.5
	
	var scene: PackedScene
	
	if type == Type.Flora:
		scene = preload("res://scenes/entities/collectables/zen_flora.tscn")
	elif type == Type.Mineral:
		scene = preload("res://scenes/entities/collectables/boom_rock.tscn")
	
	if scene != null:
		for i in [0, 1, 1, 2, 2, 3].pick_random():
			var curve := shape.get_point_array().get_curve()
			var length := curve.get_baked_length()
			var trans := curve.sample_baked_with_rotation(randf() * length)
			var node: Node2D = scene.instantiate()
			node.transform = trans
			shape.add_child(node)


func randomize_types() -> void:
	var potential_types: Array[Type] = []
	
	if can_be_misc:
		potential_types.append(Type.Misc)
	if can_be_mineral:
		potential_types.append(Type.Mineral)
	if can_be_flora:
		potential_types.append(Type.Flora)
	
	type = potential_types.pick_random()
