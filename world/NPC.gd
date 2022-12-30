extends Area2D

signal npc_moving_signal
signal npc_stopped_signal

signal npc_script_done

signal player_entering_door_signal
signal player_entered_door_signal

export(Resource) var NPC setget set_trainer

const LandingDustEffect = preload("res://world/LandingDustEffect.tscn")

export var walk_speed = 4.0
export var jump_speed = 4.0
const TILE_SIZE = 16

onready var anim_tree = $Area2D/AnimationTree
onready var anim_state = anim_tree.get("parameters/playback")
onready var ray = $Area2D/BlockingRayCast2D
onready var ledge_ray = $Area2D/LedgeRayCast2D
onready var door_ray = $Area2D/DoorRayCast2D

onready var shadow = $Area2D/Shadow
var jumping_over_ledge: bool = false

enum NPCState { IDLE, TURNING, WALKING }
enum FacingDirection { LEFT, RIGHT, UP, DOWN }

var npc_state = NPCState.IDLE
var facing_direction = FacingDirection.DOWN

var initial_position = Vector2(0, 0)
var input_direction = Vector2(0, 0)
var is_moving = false
var stop_input: bool = false
var percent_moved_to_next_tile = 0.0
var interacting = false

func _ready():
	$Area2D/Sprite.visible = true
	anim_tree.active = true
	initial_position = position
	shadow.visible = false
	anim_tree.set("parameters/Idle/blend_position", input_direction)
	anim_tree.set("parameters/Walk/blend_position", input_direction)
	anim_tree.set("parameters/Turn/blend_position", input_direction)
	if NPC.movement_type == "WANDER AROUND":
		wander_around()

	
func set_trainer(value) -> void:
	NPC = value
	$Area2D/Sprite.texture = NPC.world_graphic
	#$Area2D/Sprite.call_deferred("create_instance", true, NPC.world_graphic)

	
func set_spawn(location: Vector2, direction: Vector2):
		anim_tree.set("parameters/Idle/blend_position", direction)
		anim_tree.set("parameters/Walk/blend_position", direction)
		anim_tree.set("parameters/Turn/blend_position", direction)
		position = location
	
func _physics_process(delta):
	if input_direction != Vector2.ZERO:
		anim_state.travel("Walk")
		move(delta)
	elif interacting == true && Input.is_action_pressed("x"):
		interact()
	else:
		anim_state.travel("Idle")
		is_moving = false
	
		
func disable_collision():
	get_node("Area2D/CollisionShape2D2").queue_free()

func need_to_turn():
	var new_facing_direction
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN
	
	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	facing_direction = new_facing_direction
	return false

func finished_turning():
	npc_state = NPCState.IDLE
	
func entered_door():
	emit_signal("npc_entered_door_signal")

func move(delta):
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	ray.cast_to = desired_step
	ray.force_raycast_update()
	
	ledge_ray.cast_to = desired_step
	ledge_ray.force_raycast_update()
	
	door_ray.cast_to = desired_step
	door_ray.force_raycast_update()
	
	if door_ray.is_colliding():
		if percent_moved_to_next_tile == 0.0:
			emit_signal("player_entering_door_signal")
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			stop_input = true
			$Area2D/AnimationPlayer.play("Disappear")
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
		
	elif (ledge_ray.is_colliding() && input_direction == Vector2(0, 1)) or jumping_over_ledge:
		percent_moved_to_next_tile += jump_speed * delta
		if percent_moved_to_next_tile >= 2.0:
			position = initial_position + (input_direction * TILE_SIZE * 2)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			jumping_over_ledge = false
			shadow.visible = false
			
			var dust_effect = LandingDustEffect.instance()
			dust_effect.position = position
			get_tree().current_scene.add_child(dust_effect)
			
		else:
			shadow.visible = true
			jumping_over_ledge = true
			var input = input_direction.y * TILE_SIZE * percent_moved_to_next_tile
			position.y = initial_position.y + (-0.96 - 0.53 * input + 0.05 * pow(input, 2))
		
	elif !ray.is_colliding():
		if percent_moved_to_next_tile == 0:
			emit_signal("npc_moving_signal")
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			emit_signal("npc_stopped_signal")
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
	else:
		is_moving = false
		
func cutscene_input_action_pressed(directions):
	for d in directions:
		if d == "DOWN":
			is_moving = true
			input_direction = Vector2.DOWN
		elif d == "UP":
			is_moving = true
			input_direction = Vector2.UP
		elif d == "LEFT":
			is_moving = true
			input_direction = Vector2.LEFT
		elif d == "RIGHT":
			is_moving = true
			input_direction = Vector2.RIGHT
			
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)
		initial_position = position
		yield(get_node("."), "npc_stopped_signal")
	input_direction = Vector2.ZERO
	emit_signal("npc_script_done")

func cutscene_turn_player(directions):
	for d in directions:
		is_moving = false
		npc_state = NPCState.TURNING
		anim_state.travel("Turn")
		if d == "TURN DOWN":
			input_direction = Vector2.DOWN
		elif d == "TURN UP":
			input_direction = Vector2.UP
		elif d == "TURN LEFT":
			input_direction = Vector2.LEFT
		elif d == "TURN RIGHT":
			input_direction = Vector2.RIGHT

		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)
		initial_position = position
	input_direction = Vector2.ZERO
	
	
func interact():
	var player_facing_direction = Utils.get_player().facing_direction
	var dialogue = Utils.get_dialogue()
	var directions = []
	var dialogue_text = NPC.world_encounter.text
	#print(NPC.world_encounter.text)
	if player_facing_direction == 0:
		directions = ["TURN RIGHT"]
	if player_facing_direction == 1:
		directions = ["TURN LEFT"]
	if player_facing_direction == 2:
		directions = ["TURN DOWN"]
	if player_facing_direction == 3:
		directions = ["TURN UP"]
	cutscene_turn_player(directions)
	
	yield(dialogue.set_text(dialogue_text), "done")

func wander_around():
	var direction = ["LEFT", "RIGHT", "UP", "DOWN"]
	randomize()
	direction.shuffle()
	var rand = direction.front()
	var directions = [rand]
	cutscene_input_action_pressed(directions)
	yield(get_tree().create_timer(4.0), "timeout")
	wander_around()
	

func _on_NPC_body_entered(body: Node) -> void:
	interacting = true

func _on_NPC_body_exited(body: Node) -> void:
	interacting = false
