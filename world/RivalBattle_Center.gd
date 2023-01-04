extends Area2D

export var dialogue_key = ""
onready var dialogue = Utils.get_dialogue()
onready var player = Utils.get_player()
onready var rival = get_parent().get_node("YSort/Rival")
onready var OaksLab = get_parent()

func _on_DialogueTriggger_body_entered(body: Node) -> void:
	if OaksLab.starter_chosen == true:
		yield(player, "player_stopped_signal")
		var PlayerTurnAround = ["TURN UP"]
		player.cutscene_turn_player(PlayerTurnAround)
		player.surprise()
		yield(dialogue.set_text("GARY: wait RED!\nLet's check out our POKeMON!"), "done")
		yield(dialogue.set_text("Come on, I'll take you on!"), "done")
		var directions = ["LEFT", "LEFT", "LEFT", "LEFT", "DOWN", "DOWN"]
		rival.cutscene_input_action_pressed(directions)
		yield(rival, "npc_script_done")
	elif OaksLab.starter_chosen == false:
		pass
	
