extends Control

@export var enemy: Resource
@export var enemy_pokemon: Array[PokemonModel]
@export var player_pokemon: Array[PokemonModel]

var enemy_party
var player_party
var current_enemy_pokemon: PokemonModel
var current_pokemon: PokemonModel
var isPlayersTurn = true
var players_turn_complete = false
var enemy_turn_complete = false
var escape_attempts = 0

@onready var enemyHealth = $EnemyContainer/HBoxContainer/Control2/Node2D/enemyHealth
@onready var playerHealth = $PlayerContainer/HBoxContainer/Container/enemy_status/playerHealth
@onready var dialogueContainer = $Dialogue
@onready var dialogue = $Dialogue/Dialogue/Label
@onready var actionMenu = $Actions
@onready var fightMenu = $FightMenu
@onready var actionMenuText = $Actions/HBoxContainer/Container/ActionMenuText
@onready var animationPlayer = $AnimationPlayer
@onready var enemyPokemonSprite = $EnemyContainer/HBoxContainer/Control/EnemyPokemonSprite
@onready var playerPokemonSprite = $PlayerContainer/HBoxContainer/Control/PlayerPokemonSprite

signal dialogue_finished
signal enter_pressed

var dialogueTween
var skip_dialogue = false

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_party = enemy_pokemon.duplicate()
	player_party = GameState.player_pokemon_party
	current_pokemon = player_party[0]
	current_enemy_pokemon = enemy_party[0]
	enemyHealth.max_value = current_enemy_pokemon.max_hp
	enemyHealth.value = current_enemy_pokemon.hp
	playerHealth.max_value = current_pokemon.max_hp
	playerHealth.value = current_pokemon.hp
	enemyPokemonSprite.texture = current_enemy_pokemon.sprite_sheet
	playerPokemonSprite.texture = current_pokemon.sprite_sheet
	$EnemyContainer/HBoxContainer/Control2/Node2D/enemy_name.text = current_enemy_pokemon.name
	dialogue.text = ""
	actionMenu.hide()
	fightMenu.hide()
	animationPlayer.play("BATTLE_START")
	await animationPlayer.animation_finished
	opening_dialogue()

	set_moves()

func load_pokemon(pokemon):
	enemy_pokemon = [pokemon]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("enter"):
		emit_signal("enter_pressed")
		

func _fight_button_pressed():
	$Actions.hide()
	$FightMenu.show()

func set_moves():
	if current_pokemon.moves.size() > 0:
		$FightMenu/VBoxContainer/HBoxContainer/Move1.text = current_pokemon.moves[0].name
		$FightMenu/VBoxContainer/HBoxContainer/Move1.disabled = false
	if current_pokemon.moves.size() > 1:
		$FightMenu/VBoxContainer/HBoxContainer/Move2.text = current_pokemon.moves[1].name
		$FightMenu/VBoxContainer/HBoxContainer/Move2.disabled = false
	if current_pokemon.moves.size() > 2:
		$FightMenu/VBoxContainer/HBoxContainer2/Move3.text = current_pokemon.moves[2].name
		$FightMenu/VBoxContainer/HBoxContainer2/Move3.disabled = false
	if current_pokemon.moves.size() > 3:
		$FightMenu/VBoxContainer/HBoxContainer2/Move4.text = current_pokemon.moves[3].name
		$FightMenu/VBoxContainer/HBoxContainer2/Move4.disabled = false

func _on_fight_action_pressed(buttonIndex):
	fight(buttonIndex)
	
func _on_run_pressed():
	run()
	
func run():
	var rng = RandomNumberGenerator.new()
	var fmod = fposmod(current_enemy_pokemon.speed / 4, 256)
	escape_attempts += 1
	var odds_of_escape = ((current_pokemon.speed * 32) / fmod) + 30 * escape_attempts

	if odds_of_escape > 255:
		play_dialogue("YOU GOT AWAY")
		await dialogue_finished
		Utils.get_scene_manager().transition_exit_pokemon_scene()
	else:
		var random_number = rng.randf_range(0, 255)
		if random_number < odds_of_escape:
			play_dialogue("YOU GOT AWAY")
			await dialogue_finished
			Utils.get_scene_manager().transition_exit_pokemon_scene()
		else:
			play_dialogue("YOU TRIED TO RUN BUT FAILED")
			await dialogue_finished
	

func fight(moveIndex):
	#play fight animation
	
	if isPlayersTurn:
		escape_attempts = 0
		play_dialogue("Come on! Let's fight this guy!")
		await dialogue_finished
		var damage = damage_formula(current_pokemon, current_pokemon.moves[moveIndex].power)
#		calculate_hp(current_pokemon.moves[moveIndex].power)
		var hp_value: int = current_enemy_pokemon.hp - damage
		current_enemy_pokemon.hp = hp_value
		var tween = create_tween()
		tween.tween_property(enemyHealth, "value", hp_value, 2)
		await tween.finished

		if current_enemy_pokemon.hp > 0:
			players_turn_complete = true
			if players_turn_complete and enemy_turn_complete:
				show_action_menu()
			else:
				isPlayersTurn = false
				enemy_turn()
		else:
			if is_enemy_blacked_out():
				play_player_won()
			else:
				pass
		
	else:
		play_dialogue("The other guy is about to swing")
		await dialogue_finished
		var damage = damage_formula(current_enemy_pokemon, current_enemy_pokemon.moves[moveIndex].power)
#		calculate_hp(current_enemy_pokemon.moves[moveIndex].power)
		var hp_value: int = current_pokemon.hp - damage
		current_pokemon.hp = hp_value
		var tween = create_tween()
		tween.tween_property(playerHealth, "value", hp_value, 2)
		await tween.finished
		
		if current_pokemon.hp > 0:
			enemy_turn_complete = true
			if players_turn_complete and enemy_turn_complete:
				if is_player_blacked_out():
					play_player_blacked_out()
				else:
					isPlayersTurn = true
					show_action_menu()
		else:
			if is_player_blacked_out():
				play_player_blacked_out()
			else:
				player_switch_pokemon()
		
func enemy_turn():
	fight(0)
				
func damage_formula(pokemon: PokemonModel, attack_power):
	var rng = RandomNumberGenerator.new()
		
	var same_type_attack_bonus = 1
	var weakness_resistance = 1
	var random_number = rng.randf_range(85, 100)
	var damage = ((((2 * pokemon.level / 5 + 2) * pokemon.attack * attack_power / pokemon.defense) / 50) + 2) * same_type_attack_bonus * weakness_resistance * random_number / 100
	#var damage = (((2 * pokemon.level) + 10)/250 * pokemon.attack/pokemon.defense * attack_power + 2) * modifier
	return damage

func weakness_resistance():
	return
		
func show_action_menu():
	dialogueContainer.hide()
	$FightMenu.hide()
	players_turn_complete = false
	enemy_turn_complete = false
	actionMenuText.text = "What will\n" + current_pokemon.name + " do?"
	
	actionMenu.show()

func play_dialogue(text):
	actionMenu.hide()
	$FightMenu.hide()
	dialogueContainer.show()
	dialogue.visible_ratio = 0
	dialogueTween = create_tween()
	dialogue.text = text
	dialogueTween.tween_property(dialogue, "visible_ratio", 1, 1.5)

	while true:
		if Input.is_action_just_pressed("enter"):
			if dialogueTween.is_running():
				dialogueTween.pause()
				dialogueTween.custom_step(1.5)
			else:
				dialogue.visible_ratio = 0
				break
		
		await enter_pressed
	emit_signal("dialogue_finished")
	
func opening_dialogue():
	play_dialogue("Wild " + current_enemy_pokemon.name + " appeared!")
	await dialogue_finished
	play_dialogue("Go! " + current_pokemon.name + "!")
	await dialogue_finished
	show_action_menu()

func is_player_blacked_out():
	var playable_pokemon = []
	for mon in player_party:
		if mon.hp > 0:
			playable_pokemon.append(mon)

	if playable_pokemon.size() != 0:
		return false
	else:
		return true
		
func is_enemy_blacked_out():
	var playable_pokemon = []
	for mon in enemy_party:
		if mon.hp > 0:
			playable_pokemon.append(mon)
	if playable_pokemon.size() != 0:
		return false
	else:
		return true
		
func play_player_blacked_out():
	play_dialogue("YOU DIED")
	await dialogue_finished
	Utils.get_scene_manager().transition_exit_pokemon_scene()
	
func play_player_won():
	play_dialogue("You won!")
	await dialogue_finished
	play_dialogue("Your pokemon gained some experience")
	await dialogue_finished
	Utils.get_scene_manager().transition_exit_pokemon_scene()
	
func player_switch_pokemon():
	play_dialogue("Switch your pokemon")
	await dialogue_finished

