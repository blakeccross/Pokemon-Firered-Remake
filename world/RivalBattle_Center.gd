extends Area2D

export var dialogue_key = ""
onready var dialogue = Utils.get_dialogue()
onready var player = Utils.get_player()
onready var rival = get_parent().get_node("YSort/Rival")
onready var OaksLab = get_parent()

func _on_DialogueTriggger_body_entered(body: Node) -> void:
	if Flags.Starter_Pokemon_Chosen == true:
		yield(player, "player_stopped_signal")
		var PlayerTurnAround = ["TURN UP"]
		player.cutscene_input_action_pressed(PlayerTurnAround)
		player.surprise()
		dialogue.set_dialogue(["GARY: wait RED!\nLet's check out our POKeMON!", "Come on, I'll take you on!"])
		yield(dialogue, "finished")
		var directions = ["LEFT", "LEFT", "LEFT", "LEFT", "DOWN", "DOWN"]
		rival.cutscene_input_action_pressed(directions)
		yield(rival, "npc_script_done")
		Utils.get_scene_manager().transition_to_trainer_battle_scene(rival)
	elif Flags.Starter_Pokemon_Chosen == false:
		pass
	
