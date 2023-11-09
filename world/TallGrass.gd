extends Node2D

@onready var anim_player = $AnimationPlayer
const grass_overlay_texture = preload("res://Assets/Grass/stepped_tall_grass.tscn")
const GrassStepEffect = preload("res://world/GrassStepEffect.tscn")

var grass_overlay
var rng = RandomNumberGenerator.new()
var player_inside: bool = false
var wild_pokemon

signal player_entered_grass
@onready var player = Utils.get_player()

func _ready():
	pass

func player_exiting_grass():
	player_inside = false
	grass_overlay.queue_free()
	if is_instance_valid(grass_overlay):
		
		grass_overlay.queue_free()
	
func player_in_grass():
	var grass_step_effect = GrassStepEffect.instantiate()
	grass_step_effect.position = position
	get_tree().current_scene.add_child(grass_step_effect)
	
	
	grass_overlay = grass_overlay_texture.instantiate()
	grass_overlay.position = position
	get_tree().current_scene.add_child(grass_overlay)

#func randomize_encounter():
#	rng.randomize()
#	var encounter_chance = rng.randi_range(0, 4)
#	if encounter_chance == 0:
#		await player.player_stopped_signal
#		player.set_physics_process(false)
#		player.anim_state.travel("Idle")
#		emit_signal("wild_encounter")
#		Utils.get_scene_manager().transition_to_pokemon_scene(wild_pokemon)
#	else:
#		return

			


func _on_body_entered(body):
	await player.player_stopped_signal
	anim_player.play("Stepped")
	emit_signal("player_entered_grass")
	player_in_grass()



func _on_exit_grass(body):
	player_exiting_grass()
