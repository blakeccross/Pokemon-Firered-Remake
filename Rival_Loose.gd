extends Node2D

onready var dialogue = Utils.get_dialogue()
onready var player = Utils.get_player()

func _ready() -> void:
	var rival = get_parent()
	print("RIVAL LOOSE SCRIPT")
	var PlayerTurnAround = ["TURN UP"]
	player.cutscene_input_action_pressed(PlayerTurnAround)
	player.surprise()
	dialogue.set_dialogue(["GARY: Ok! I'll make my\nPOKeMON battle to toughen it up!", "RED! Gramps!\nSmell you later!"])
	yield(dialogue, "finished")
	var directions = ["RIGHT", "DOWN", "DOWN", "DOWN", "DOWN", "LEFT", "DOWN", "DOWN"]
	rival.cutscene_input_action_pressed(directions)
	yield(rival, "npc_script_done")
	player.cut_scene = false
