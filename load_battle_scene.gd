extends CanvasLayer

const Pokemon_stage = preload("res://Battle/wild_battle.tscn")
const rival = preload("res://NPC/RIVAL.tres")
var battle = preload("res://Battle/battle.tscn")

var pokemon_scene

func load_pokemon_scene(wild_pokemon):
	pokemon_scene = Pokemon_stage.instance()
	pokemon_scene.wild_pokemon = wild_pokemon
	add_child(pokemon_scene)

func unload_pokemon_scene():
	remove_child(pokemon_scene)
	Utils.get_player().set_physics_process(true)

func load_Trainer_Battle_scene(trainer):
	print("TRAINER", trainer.NPC)
	pokemon_scene = battle.instance()
	pokemon_scene.enemy = trainer.NPC
	add_child(pokemon_scene)
