extends Node2D

onready var dialogue = Utils.get_dialogue()
onready var player = Utils.get_player()
onready var prof_oak = find_node("Prof_Oak")
onready var rival = find_node("Rival")
var starter_chosen = false
var PLAYER = "RED"
var RIVAL = "GREEN"


func _ready() -> void:
	player.cut_scene = true
	prof_oak.position = Vector2(96, 176) 
	rival.cutscene_input_action_pressed(["TURN UP", "TURN DOWN"])
	var directions = ["UP", "UP", "UP", "UP", "UP", "UP", "UP", "UP", "TURN DOWN"]
	prof_oak.cutscene_input_action_pressed(directions)
	yield(prof_oak, "npc_script_done")
	var PlayerDirections = ["UP", "UP", "UP", "UP", "UP", "UP", "UP", "UP"]
	player.cutscene_input_action_pressed(PlayerDirections)
	yield(player, "player_script_done")
	rival.cutscene_input_action_pressed(["TURN UP"])
	var PalletTown_ProfessorOaksLab_Text_OakThreeMonsChooseOne = [
		"OAK: %s?\n" % RIVAL,
		"Let me think…\n",
		"Oh, that's right, I told you to\ncome! Just wait!",
		"Here, %s." % PLAYER,
		"There are three POKéMON here.",
		"Haha!",
		"The POKéMON are held inside\nthese POKé BALLS.",
		"When I was young, I was a serious\nPOKéMON TRAINER.",
		"But now, in my old age, I have\nonly these three left.",
		"You can have one.\nGo on, choose!"
	]
	dialogue.set_dialogue(PalletTown_ProfessorOaksLab_Text_OakThreeMonsChooseOne)
	yield(dialogue, "finished")
	player.cut_scene = false
	
	
