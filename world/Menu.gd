extends CanvasLayer

const PokemonPartyScreen = preload("res://world/PokemonPartyScreen.tscn")

onready var select_arrow = $Control/NinePatchRect/TextureRect
onready var menu = $Control

enum ScreenLoaded { NOTHING, JUST_MENU, PARTY_SCREEN, }
var screen_loaded = ScreenLoaded.NOTHING

var selected_option: int = 0

func _ready():
	menu.visible = false
	#select_arrow.rect_position.y = 6 + (selected_option % 6) * 15
	if Utils.player_pokemon.size() == 0:
		$"Control/NinePatchRect/VBoxContainer/Pokemon".visible = false
		select_arrow.rect_position.y = 5 + (selected_option % 5) * 15

func load_party_screen():
	menu.visible = false
	screen_loaded = ScreenLoaded.PARTY_SCREEN
	var party_screen = PokemonPartyScreen.instance()
	add_child(party_screen)
	
	
func unload_party_screen():
	menu.visible = true
	screen_loaded = ScreenLoaded.JUST_MENU
	remove_child($PokemonPartyScreen)

func _unhandled_input(event):
	match screen_loaded:
		ScreenLoaded.NOTHING:
			if event.is_action_pressed("menu"):
				var player = Utils.get_player()
				if !player.is_moving:
					player.set_physics_process(false)
					menu.visible = true
					screen_loaded = ScreenLoaded.JUST_MENU
		
		ScreenLoaded.JUST_MENU:
			if event.is_action_pressed("menu") or event.is_action_pressed("x"):
				var player = Utils.get_player()
				player.set_physics_process(true)
				menu.visible = false
				screen_loaded = ScreenLoaded.NOTHING
				
			elif event.is_action_pressed("ui_down"):
				selected_option += 1
				select_arrow.rect_position.y = 5 + (selected_option % 5) * 15
				
			elif event.is_action_pressed("ui_up"):
				if selected_option == 0:
					selected_option = 5
				else:
					selected_option -= 1
				select_arrow.rect_position.y = 5 + (selected_option % 5) * 15
			elif event.is_action_pressed("z"):
				Utils.get_scene_manager().transition_to_party_screen()
			
		ScreenLoaded.PARTY_SCREEN:
			if event.is_action_pressed("x"):
				Utils.get_scene_manager().transition_exit_party_screen()
