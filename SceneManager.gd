extends Node2D

var next_scene = null

var player_location = Vector2(0, 0)
var player_direction = Vector2(0, 0)

enum TransitionType { NEW_SCENE, PARTY_SCREEN, MENU_ONLY, BATTLE_SCENE }
var transition_type = TransitionType.NEW_SCENE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func transition_to_party_screen():
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	transition_type = TransitionType.PARTY_SCREEN
	
func transition_exit_party_screen():
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	transition_type = TransitionType.MENU_ONLY


func transition_to_scene(new_scene: String, spawn_location, spawn_direction):
	next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction
	transition_type = TransitionType.NEW_SCENE
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	
func transition_to_pokemon_scene(wild_pokemon):
	$Transition.show_barx_x()
	yield($Transition/TextureRect, "trans_done")
	$Transition.hide_barx_x()
	$battle_scene.load_pokemon_scene(wild_pokemon)
	yield($battle_scene/battle, "done")
	transition_exit_pokemon_scene()
	
func transition_exit_pokemon_scene():
	$Transition.show_barx_x()
	yield($Transition/TextureRect, "trans_done")
	$Transition.hide_barx_x()
	$battle_scene.unload_pokemon_scene()
	
	
func transition_to_trainer_battle_scene(trainer):
	$Transition.show_barx_x()
	yield($Transition/TextureRect, "trans_done")
	$Transition.hide_barx_x()
	$battle_scene.load_Trainer_Battle_scene(trainer)
	yield($battle_scene/battle, "done")
	transition_exit_trainer_battle_scene(trainer)
	
func transition_exit_trainer_battle_scene(trainer):
	$Transition.show_barx_x()
	yield($Transition/TextureRect, "trans_done")
	$Transition.hide_barx_x()
	$battle_scene.unload_pokemon_scene()
	play_script_(trainer, trainer.NPC.world_loose)
	
func finished_fading():
	match transition_type:
		TransitionType.NEW_SCENE:
			$CurrentScene.get_child(0).queue_free()
			$CurrentScene.add_child(load(next_scene).instance())
			
			var player = Utils.get_player()
			player.set_spawn(player_location, player_direction)
		TransitionType.PARTY_SCREEN:
			$Menu.load_party_screen()
		TransitionType.MENU_ONLY:
			$Menu.unload_party_screen()
	
	$ScreenTransition/AnimationPlayer.play("FadeToNormal")
	
func play_script_(parent, script):
	var s
	if script is Script:
		s = script.new()
	#elif script is TextModel:
	#	s = GenericEncounter.new()
	#	s.text = script

	parent.add_child(s)
	return s
