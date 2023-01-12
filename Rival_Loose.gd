extends Node2D

onready var dialogue = Utils.get_dialogue()
onready var player = Utils.get_player()

func _ready() -> void:
	var rival = get_parent()
	print("RIVAL LOOSE SCRIPT")
	var PlayerTurnAround = ["TURN UP"]
	player.cutscene_input_action_pressed(PlayerTurnAround)
	player.surprise()
	yield(dialogue.set_text("GARY: I hate you!"), "done")
	var directions = ["LEFT", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN"]
	rival.cutscene_input_action_pressed(directions)
	yield(rival, "npc_script_done")
	player.cut_scene = false
