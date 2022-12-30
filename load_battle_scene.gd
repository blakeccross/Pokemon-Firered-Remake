extends CanvasLayer

const Pokemon_stage = preload("res://Battle/wild_battle.tscn")

var pokemon_scene

func load_pokemon_scene(wild_pokemon):
	pokemon_scene = Pokemon_stage.instance()
	pokemon_scene.wild_pokemon = wild_pokemon
	add_child(pokemon_scene)

func unload_pokemon_scene():
	remove_child(pokemon_scene)
	Utils.get_player().set_physics_process(true)
