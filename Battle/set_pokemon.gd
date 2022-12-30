extends Position2D

onready var stats = find_node("stats")
onready var pokemon = find_node("pokemon") setget set_pokemon, get_pokemon
#var pokemon setget set_pokemon, get_pokemon

func set_pokemon(value):
	pokemon = value

func get_pokemon():
	return get_node_or_null("pokemon")
