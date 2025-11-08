class_name MapGen extends Node2D


static var instance: MapGen


@export var planet_padding := 0.0
@export var planet_limit := 20
@export var max_spawn_tries := 10
@export var branch_count: Array[int] = []
@export var distance_ranges: Array[Vector2] = []


@export var planets_pool_node: Node

@export var planets_parent: Node2D


@export_group("Fish", "fish_")
@export var fish_spawn_tries := 10
@export var fish_max := 30
@export var fish_odds_per_planet := 3.0
var fish_count := 0

@onready var rng := RandomNumberGenerator.new()


var planet_count := 0
var planets: Array[Vector3] = [Vector3(0, 0, 500)]

var planet_pool: Array[Planet] = []
var planet_pool_weights := PackedFloat32Array()


func _enter_tree() -> void:
	instance = self


func _ready() -> void:
	for planet in planets_pool_node.get_children():
		if planet is not Planet: continue
		
		planet_pool.append(planet)
		planet_pool_weights.append(planet.pool_weight)
		planets_pool_node.remove_child(planet)
	
	generate()


func generate() -> void:
	rng.randomize()
	randomize()
	
	for b in branch_count[0]:
		_trail(Vector2.ZERO, 1)
	
	# Spawn fish
	for planet in planets:
		if fish_count > fish_max:
			break
		
		if randf() > 1.0 / fish_odds_per_planet:
			continue 
		
		var pos := Vector2(planet.x, planet.y)
		
		for try_index in fish_spawn_tries:
			var direction := Math.rand_dir()
			var distance := randf_range(planet.z + planet_padding, planet.z + planet_padding + 500.0)
			
			var test_pos := position + direction * distance
			
			# These planets will overlap!!! try again
			if check_planet_pos(test_pos, 32.0):
				var new_fish: Node2D = preload("res://scenes/entities/collectables/space_fish.tscn").instantiate()
				new_fish.rotation = randf() * TAU
				new_fish.position = test_pos
				add_child(new_fish)
				fish_count += 1
				break
	
	# DevTools.sticky_toast(&"Map Gen", {
	# 	"# of Planets" = planets.size(),
	# 	"# of Fish" = fish_count,
	# }, 60)


func _trail(position: Vector2 , depth: int) -> void:
	var new_planet: Planet = planet_pool[rng.rand_weighted(planet_pool_weights)].duplicate()
	
	var target_pos := Vector2.ZERO
	
	for try_index in max_spawn_tries:
		var direction := Math.rand_dir()
		var distance_range := distance_ranges[depth]
		var distance := randf_range(distance_range.x, distance_range.y)
		
		var test_pos := position + direction * distance
		
		# These planets will overlap!!! try again
		if check_planet_pos(test_pos, new_planet.gravity_radius + planet_padding):
			target_pos = test_pos
			break
	
	if target_pos.is_zero_approx(): return
	
	planets.append(Vector3(target_pos.x, target_pos.y, new_planet.gravity_radius))
	new_planet.position = target_pos
	new_planet.rotation = randf() * TAU
	planets_parent.add_child(new_planet)
	new_planet.setup()

	if depth < branch_count.size() - 1:
		for branch_index in branch_count[depth]:
			_trail(target_pos, depth + 1)


func check_planet_pos(pos: Vector2, radius: float) -> bool:
	for try_index in max_spawn_tries:
		var direction := Math.rand_dir()
		var distance := randf_range(1000, 5000)
		
		var test_pos := position + direction * distance
		
		# These planets will overlap!!! try again
		for other_planet in planets:
			if Vector2(other_planet.x, other_planet.y).distance_squared_to(pos) < (other_planet.z + radius) ** 2.0:
				return false
	
	return true
