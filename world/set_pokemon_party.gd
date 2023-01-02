extends Node2D

var pokemon
onready var player = Utils.get_player()
onready var pokemon_sprite = $PokemonPartySprite
onready var pokemon_name = $PokemonName
onready var pokemon_level = $LevelLabel
onready var pokemon_HP = $HealthLabel
onready var pokemon_Max_HP = $MaxHealthLabel
export(int) var menu_number

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if range(player.trainer.pokemon.size()).has(menu_number):
		pokemon = player.trainer.pokemon[menu_number]
		pokemon_sprite.texture = pokemon.texture
		pokemon_name.texture = pokemon.texture
		pokemon_level.text = str(pokemon.level)
		pokemon_HP.text = str(pokemon.hp)
		pokemon_Max_HP.text = str(pokemon.max_hp)
	else:
		get_node(".").visible = false

