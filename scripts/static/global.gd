class_name Global extends RefCounted


const TPS := 60.0


static var atmospheres: Array[GradientTexture1D] = [
	preload("res://resources/atmospheres/blue-teal-green.tres"),
	preload("res://resources/atmospheres/ice.tres"),
	preload("res://resources/atmospheres/purple-gold.tres"),
	preload("res://resources/atmospheres/sulfur.tres"),
]

static var materials_misc: Array[SS2D_Material_Shape] = [
	preload("res://resources/shape_materials/dirt.tres"),
]

static var materials_mineral: Array[SS2D_Material_Shape] = [
	preload("res://resources/shape_materials/dirt.tres"),
	preload("res://resources/shape_materials/rock_gray.tres"),
]

static var materials_flora: Array[SS2D_Material_Shape] = [
	preload("res://resources/shape_materials/dirt.tres"),
	preload("res://resources/shape_materials/dirt_with_grass.tres"),
]
