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
	
#func _on_encounter() -> void:
	#var battle_scene = preload("res://Battle/Battle_Scene.tscn").instance()
	#$battle.add_child(battle_scene)
