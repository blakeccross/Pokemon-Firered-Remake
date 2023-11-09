extends Node

var is_talking = false
var player_pokemon_party: Array[PokemonModel] = []
@onready var resource1 = load("res://pokemon/charmander/charmander.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	player_pokemon_party.append(resource1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
