extends Node

#signal display_dialogue(text_key)
var player_pokemon = []
var OakEntered = false
var inBattle = false

func _ready():
	pass # Replace with function body.

func get_player():
	return get_node("/root/SceneManager/CurrentScene").get_children().back().find_node("Player")

func get_scene_manager():
	return get_node("/root/SceneManager")

func get_dialogue():
	return get_node("/root/SceneManager").get_node("Dialogue")
