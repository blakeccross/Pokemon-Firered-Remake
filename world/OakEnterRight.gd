extends Area2D

export var dialogue_key = ""
onready var dialogue = Utils.get_dialogue()
onready var player = Utils.get_player()
onready var prof_oak = get_parent().get_node("Prof_Oak")

func _on_DialogueTriggger_body_entered(body: Node) -> void:
	if Flags.OakEntered == false:
		Flags.OakEntered = true
		prof_oak.visible = true
		prof_oak.disable_collision()
		get_parent().get_parent().get_node("palletTown_music").stream_paused = true
		yield(player, "player_stopped_signal")
		$oakTheme_music.play()
		yield(dialogue.set_text("OAK: Hey! Wait!\nDon't go out!"), "done")
		var PlayerTurnAround = ["TURN DOWN"]
		player.cutscene_turn_player(PlayerTurnAround)
		player.surprise()
		var directions = ["UP", "UP", "UP", "UP", "UP", "RIGHT", "RIGHT", "UP"]
		prof_oak.cutscene_input_action_pressed(directions)
		yield(prof_oak, "npc_script_done")
		OakLeadPlayerToLabLeft()
	if Flags.OakEntered == true:
		return
	
func OakLeadPlayerToLabLeft():
	yield(dialogue.set_text("OAK: It's unsafe!\nWild POKéMON live in tall grass!"), "done")
	var OakDirections = ["DOWN", "LEFT", "LEFT", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "UP", "UP"]
	prof_oak.cutscene_input_action_pressed(OakDirections)
	var PlayerDirections = ["DOWN", "DOWN", "LEFT", "LEFT", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "DOWN", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "UP", "UP"]
	player.cutscene_input_action_pressed(PlayerDirections)
