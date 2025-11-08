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


func _ready() -> void:
	setup()


func setup() -> void:
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


func randomize_types() -> void:
	var potential_types: Array[Type] = []
	
	if can_be_misc:
		potential_types.append(Type.Misc)
	if can_be_mineral:
		potential_types.append(Type.Mineral)
	if can_be_flora:
		potential_types.append(Type.Flora)
	
	type = potential_types.pick_random()
