extends Area2D

var interact = false
enum STARTER { bulbasaur,squirtle,charmander }
export(STARTER) var starter
export(Resource) var pokemon
var choice

onready var player = Utils.get_player()
onready var rival = get_parent().get_parent().get_node("Rival")
onready var dialogue = Utils.get_dialogue()

onready var bulbasaur = get_parent().get_node("bulbasaur")
onready var squirtle = get_parent().get_node("squirtle")
onready var charmander = get_parent().get_node("charmander")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue.connect("yes_no_selection", self, "_select")

func _physics_process(delta: float) -> void:
	if interact == true && Input.is_action_pressed("x"):
		choose_starter()
		
func _on_player_entered(body: Node) -> void:
	interact = true

func choose_starter():
	interact = false
	if starter == STARTER.bulbasaur:
		yield(dialogue.set_text("Ah! BULBASUAR is your choice.\nIt's very easy to raise."), "done")
		yield(dialogue.set_question("So, RED, you're claiming the GRASS POKeMON BULBASAUR?"), "done")
		if choice == "yes":
			bulbasaur.visible = false
			yield(dialogue.set_text("This POKeMON is really quite\nenergetic!"), "done")
			yield(dialogue.set_text("RED received the BULBASAUR\nfrom PROF.OAK!"), "done")
			find_parent("OaksLab").starter_chosen = true
			player.trainer.pokemon.insert(0, pokemon)
			var directions = ["DOWN", "DOWN", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "UP"]
			rival.cutscene_input_action_pressed(directions)
			yield(rival, "npc_script_done")
			yield(dialogue.set_text("GARY: I'll take this one then!"), "done")
			charmander.queue_free()
			yield(dialogue.set_text("Gary revieved the CHARMANDER\nfrom PROF OAK"), "done")
			bulbasaur.queue_free()
		elif choice == "no":
			pass
		
	elif starter == STARTER.squirtle:
		yield(dialogue.set_text("Hm! SQUIRTLE is your choice.\nIt's one worth raising."), "done")
		yield(dialogue.set_question("So, RED, you've decided on the WATER POKeMON SQUIRTLE?"), "done")
		if choice == "yes":
			get_node(".").visible = false
			yield(dialogue.set_text("This POKeMON is really quite\nenergetic!"), "done")
			yield(dialogue.set_text("RED received the BULBASAUR\nfrom PROF.OAK!"), "done")
			find_parent("OaksLab").starter_chosen = true
			player.trainer.pokemon.insert(0, pokemon)
			queue_free()
		elif choice == "no":
			pass
	elif starter == STARTER.charmander:
		yield(dialogue.set_text("Ah! CHARMANDER is your choice.\nYou should raise it patiently."), "done")
		yield(dialogue.set_text("So, RED, you're claiming the FIRE POkeMON CHARMANDER?"), "done")
		if choice == "yes":
			get_node(".").visible = false
			yield(dialogue.set_text("This POKeMON is really quite\nenergetic!"), "done")
			yield(dialogue.set_text("RED received the BULBASAUR\nfrom PROF.OAK!"), "done")
			find_parent("OaksLab").starter_chosen = true
			player.trainer.pokemon.insert(0, pokemon)
			queue_free()
		elif choice == "no":
			pass

func _select(yes_no):
	if yes_no == 0:
		choice = "yes"
	elif yes_no == 1:
		choice = "no"
	
	
