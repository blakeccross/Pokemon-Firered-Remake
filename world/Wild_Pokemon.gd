extends Node2D

export(Array, Resource) var pokemon
export(Array,float,0,100) var pokemon_chances
var rng = RandomNumberGenerator.new()
var wild_pokemon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_TallGrass_wild_encounter() -> void:
	rng.randomize()
	var rng_1 = rng.randf_range(0.0, 100.0)
	print(rng_1)
	for i in range(0,pokemon_chances.size()):
		if rng_1 < pokemon_chances[i]:
			wild_pokemon = pokemon[i]
			Utils.get_scene_manager().transition_to_pokemon_scene(wild_pokemon)
	print("WILD", wild_pokemon)
