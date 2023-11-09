extends CanvasLayer

const Pokemon_stage = preload("res://Battle/Battle.tscn")

var pokemon_scene

func load_pokemon_scene(wild_pokemon):
	pokemon_scene = Pokemon_stage.instantiate()
	pokemon_scene.load_pokemon(wild_pokemon)
	add_child(pokemon_scene)

func unload_pokemon_scene():
	remove_child(pokemon_scene)
	Utils.get_player().resume_movement()
