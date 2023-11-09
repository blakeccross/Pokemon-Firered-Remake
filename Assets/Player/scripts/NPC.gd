extends CharacterBody2D

signal npc_moving_signal
signal npc_stopped_signal

signal npc_script_done

signal player_entering_door_signal
signal player_entered_door_signal

@export var NPC: Resource = null:
	set(val):
		NPC = val

const LandingDustEffect = preload("res://world/LandingDustEffect.tscn")
const Balloon = preload("res://dialogue/balloon.tscn")
@export var dialogue_resource: DialogueResource

@export var walk_speed = 4.0
@export var jump_speed = 4.0
const TILE_SIZE = 16

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var ray = $BlockingRayCast2D
@onready var ledge_ray = $LedgeRayCast2D
@onready var door_ray = $DoorRayCast2D

@onready var shadow = $Shadow
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
var tween

func _ready():
	$Sprite.visible = true
	$Sprite.texture = NPC.world_graphic
	anim_tree.active = true
	initial_position = position
	shadow.visible = false
	anim_tree.set("parameters/Idle/blend_position", input_direction)
	anim_tree.set("parameters/Walk/blend_position", input_direction)
	anim_tree.set("parameters/Turn/blend_position", input_direction)
	var player = Utils.get_player()
	player.dialogue.connect(interact)
	
	if NPC.movement_type == "WANDER AROUND":
		pass
#		wander_around()
	
func set_spawn(location: Vector2, direction: Vector2):
		anim_tree.set("parameters/Idle/blend_position", direction)
		anim_tree.set("parameters/Walk/blend_position", direction)
		anim_tree.set("parameters/Turn/blend_position", direction)
		position = location
	
func _physics_process(delta):	
	if input_direction != Vector2.ZERO && !GameState.is_talking:
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)
		
		if need_to_turn():
			npc_state = NPCState.TURNING
			anim_state.travel("Turn")
			raycast_update()
		else:
			move(delta)
	else:
		anim_state.travel("Idle")
		
		
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

func raycast_update():
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	ray.target_position = desired_step
	ray.force_raycast_update()
	
	ledge_ray.target_position = desired_step
	ledge_ray.force_raycast_update()

	door_ray.target_position = desired_step
	door_ray.force_raycast_update()
	
func finished_turning():
	npc_state = NPCState.IDLE
	
func entered_door():
	emit_signal("npc_entered_door_signal")
	
func enter_door():
	is_moving = false
	emit_signal("npc_stopped_signal")
	tween.kill()
	$AnimationPlayer.play("Disappear")

func move(delta):
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	raycast_update()
	
	if door_ray.is_colliding():
		emit_signal("npc_entering_door_signal")
		tween = create_tween()
		is_moving = true
		tween.tween_property(self, "position", initial_position + (input_direction * TILE_SIZE), .20).set_trans(Tween.TRANS_LINEAR)
		tween.connect("finished", enter_door)
		
	elif ledge_ray.is_colliding() && !jumping_over_ledge && !is_moving:
		is_moving = true
		jumping_over_ledge = true
		shadow.visible = true
		tween.tween_property(self, "position", initial_position + (input_direction * TILE_SIZE * 2), .60).from_current().set_trans(Tween.TRANS_SPRING)
		
		await tween.finished
		
		is_moving = false
		jumping_over_ledge = false
		initial_position = position
		shadow.visible = false
		var dust_effect = LandingDustEffect.instantiate()
		add_child(dust_effect)

	elif ray.is_colliding():
		tween.kill()
		is_moving = false
		
	elif !is_moving && !jumping_over_ledge:
		anim_state.travel("Walk")
		is_moving = true
		tween.tween_property(self, "position", initial_position + (input_direction * TILE_SIZE), .20).from_current().set_trans(Tween.TRANS_LINEAR)
		await tween.finished
		
		is_moving = false
		initial_position = position
		emit_signal("npc_stopped_signal")
		
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
		await self.npc_stopped_signal

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
	
	
func interact(name):
	print("NAME", name)
	var player_facing_direction = Utils.get_player().facing_direction
	stop_input = true
	var balloon = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource,"start")
	#var dialogue = Utils.get_dialogue()

	var directions = []
	var dialogue_text = NPC.world_encounter.text

	if player_facing_direction == 0:
		directions = ["TURN RIGHT"]
	if player_facing_direction == 1:
		directions = ["TURN LEFT"]
	if player_facing_direction == 2:
		directions = ["TURN DOWN"]
	if player_facing_direction == 3:
		directions = ["TURN UP"]
	cutscene_turn_player(directions)
#
#	await dialogue.set_text(dialogue_text).done

func wander_around():
	if !stop_input:
		await get_tree().create_timer(4.0).timeout
		var direction = ["LEFT", "RIGHT", "UP", "DOWN"]
		randomize()
		direction.shuffle()
		var rand = direction.front()
		var directions = [rand]
		cutscene_input_action_pressed(directions)
		wander_around()
	

#func _on_NPC_body_entered(body: Node) -> void:
#	print("LETS TALK")
#	interacting = true
#
#func _on_NPC_body_exited(body: Node) -> void:
#	interacting = false
