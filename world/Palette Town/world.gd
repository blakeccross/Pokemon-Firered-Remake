extends Node2D
signal battle_started

@export_range(0, 100) var encounter_rate: int = 0
@export var land_pokemon: Array[PokemonModel]

@onready var TallGrass = get_node("Grasses/TallGrass")
var wild_encounter_rng = RandomNumberGenerator.new()

func is_wild_pokemon():
	wild_encounter_rng.randomize()
	var wild_encounter_number = wild_encounter_rng.randf_range(0.0, 100.0)
	if wild_encounter_number <= encounter_rate:
		return true
	else:
		return false
		
func randomize_pokemon_encounter():
	var chosen_pokemon
	var random_number = randi() % 100 + 1
	randomize()
	
	for i in land_pokemon:
		if random_number <= i.encounter_chance:
			chosen_pokemon = i
			break
		else:
			random_number -= i.encounter_chance
	return chosen_pokemon

func _on_tall_grass_player_entered_grass():
	if is_wild_pokemon():
		var chosen = randomize_pokemon_encounter()
		Utils.get_scene_manager().transition_to_pokemon_scene(chosen)
		
