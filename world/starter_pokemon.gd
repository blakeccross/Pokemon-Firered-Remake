extends Area2D

var interact = false
enum STARTER { bulbasaur,squirtle,charmander }
export(STARTER) var starter
export(Resource) var pokemon

onready var player = Utils.get_player()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if interact == true && Input.is_action_pressed("x"):
		choose_starter()
		
func _on_player_entered(body: Node) -> void:
	interact = true

func choose_starter():
	var dialogue = Utils.get_dialogue()
	interact = false
	if starter == STARTER.bulbasaur:
		yield(dialogue.set_text("Ah! BULBASUAR is your choice.\nIt's very easy to raise."), "done")
		yield(dialogue.set_question("So, RED, you're claiming the GRASS POKeMON BULBASAUR?"), "done")
		get_node(".").visible = false
		yield(dialogue.set_text("This POKeMON is really quite\nenergetic!"), "done")
		yield(dialogue.set_text("RED received the BULBASAUR\nfrom PROF.OAK!"), "done")
		player.trainer.pokemon.insert(0, pokemon)
		get_node(".").queue_free()
	elif starter == STARTER.squirtle:
		yield(dialogue.set_text("Hm! SQUIRTLE is your choice.\nIt's one worth raising."), "done")
		yield(dialogue.set_question("So, RED, you've decided on the WATER POKeMON SQUIRTLE?"), "done")
		get_node(".").visible = false
		yield(dialogue.set_text("This POKeMON is really quite\nenergetic!"), "done")
		yield(dialogue.set_text("RED received the BULBASAUR\nfrom PROF.OAK!"), "done")
		player.trainer.pokemon.insert(0, pokemon)
		queue_free()
	elif starter == STARTER.charmander:
		yield(dialogue.set_text("Ah! CHARMANDER is your choice.\nYou should raise it patiently."), "done")
		yield(dialogue.set_text("So, RED, you're claiming the FIRE POkeMON CHARMANDER?"), "done")
		get_node(".").visible = false
		yield(dialogue.set_text("This POKeMON is really quite\nenergetic!"), "done")
		yield(dialogue.set_text("RED received the BULBASAUR\nfrom PROF.OAK!"), "done")
		player.trainer.pokemon.insert(0, pokemon)
		queue_free()
