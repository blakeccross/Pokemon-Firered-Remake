extends Node2D

onready var anim_player = $AnimationPlayer
const grass_overlay_texture = preload("res://Assets/Grass/stepped_tall_grass.png")
const GrassStepEffect = preload("res://world/GrassStepEffect.tscn")

export(Array, Resource) var pokemon
export(Array,float,0,100) var pokemon_chances

var grass_overlay: TextureRect = null
var rng = RandomNumberGenerator.new()
var player_inside: bool = false
var wild_pokemon

signal wild_encounter

func _ready():
	var player = Utils.get_player()
	player.connect("player_moving_signal", self, "player_exiting_grass")
	player.connect("player_stopped_signal", self, "player_in_grass")

func player_exiting_grass():
	player_inside = false
	if is_instance_valid(grass_overlay):
		grass_overlay.queue_free()
	
func player_in_grass():
	if player_inside == true:
		var grass_step_effect = GrassStepEffect.instance()
		grass_step_effect.position = position
		get_tree().current_scene.add_child(grass_step_effect)
		
		
		grass_overlay = TextureRect.new()
		grass_overlay.texture = grass_overlay_texture
		grass_overlay.rect_position = position
		get_tree().current_scene.add_child(grass_overlay)

func _on_Area2D_body_entered(body):
	player_inside = true
	anim_player.play("Stepped")
	randomize_encounter()

func randomize_encounter():
	rng.randomize()
	var encounter_chance = rng.randi_range(0, 4)
	if encounter_chance == 0:
		var player = Utils.get_player()
		yield(player, "player_stopped_signal")
		#player.stop_input = true
		player.set_physics_process(false)
		player.anim_state.travel("Idle")
		randomize_pokemon()
		Utils.get_scene_manager().transition_to_pokemon_scene(wild_pokemon)
	else:
		return

func randomize_pokemon():
	rng.randomize()
	var rng_1 = rng.randf_range(0.0, 100.0)
	print(rng_1)
	for i in range(0,pokemon_chances.size()):
		if rng_1 < pokemon_chances[i]:
			wild_pokemon = pokemon[i]
			
	print("WILD", wild_pokemon)
