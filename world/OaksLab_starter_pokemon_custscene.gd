extends Node2D

onready var dialogue = Utils.get_dialogue()
onready var player = Utils.get_player()
onready var prof_oak = find_node("Prof_Oak")
onready var rival = find_node("Rival")


func _ready() -> void:
	prof_oak.position = Vector2(96, 176) 
	rival.get_node("Area2D/AnimationPlayer").play("IdleUp")
	var directions = ["UP", "UP", "UP", "UP", "UP", "UP", "UP", "UP"]
	prof_oak.cutscene_input_action_pressed(directions)
	yield(prof_oak, "npc_script_done")
	var turnoak = ["TURN DOWN"]
	prof_oak.cutscene_turn_player(turnoak)
	var PlayerDirections = ["UP", "UP", "UP", "UP", "UP", "UP", "UP", "UP"]
	player.cutscene_input_action_pressed(PlayerDirections)
	yield(player, "player_script_done")
	yield(dialogue.set_text("GARY: Gramps!\nI'm fed up with waiting!"), "done")
	yield(dialogue.set_text("OAK: Gary?\nLet me think..."), "done")
	yield(dialogue.set_text("Ooh, that's right, I told you to\ncome! Just wait!"), "done")
	yield(dialogue.set_text("Here, RED."), "done")
	yield(dialogue.set_text("There are three POKeMON here."), "done")
	yield(dialogue.set_text("Haha!"), "done")
	yield(dialogue.set_text("The POKeMON are held inside\nthese POKe BALLS."), "done")
	yield(dialogue.set_text("When I was young, I was a serious\nPOKeMON TRAINER."), "done")
	yield(dialogue.set_text("But now, in my old age, I have\nonly these three left."), "done")
	yield(dialogue.set_text("You can have one.\nGo on, choose!"), "done")
	yield(dialogue.set_text("GARY: Hey! Gramps! No fair!\nWhat about me?"), "done")
	yield(dialogue.set_text("OAK: Be patient, GARY.\nYou can have one, too!"), "done")
	
