extends CharacterBody2D

signal player_moving_signal
signal player_stopped_signal
signal player_entering_door_signal
signal player_entered_door_signal
signal dialogue

const LandingDustEffect = preload("res://world/LandingDustEffect.tscn")

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

enum PlayerState { IDLE, TURNING, WALKING }
enum FacingDirection { LEFT, RIGHT, UP, DOWN }

var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

var initial_position = Vector2(0, 0)
var input_direction = Vector2(0, 1)
var is_moving = false
var cut_scene = false
var stop_input = false
var tween

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.visible = true
	anim_tree.active = true
	initial_position = position
	shadow.visible = false
	anim_state.travel("Idle")
	anim_tree.set("parameters/Idle/blend_position", input_direction)
	
func set_spawn(location: Vector2, direction: Vector2):
	anim_tree.set("parameters/Idle/blend_position", direction)
	position = location
	
func _physics_process(delta):
	if player_state == PlayerState.TURNING or is_moving:
		return
	else:
		process_player_movement_input(delta)
		
	if ray.is_colliding():
		if ray.get_collider().is_in_group("npc") && Input.is_action_pressed("x") && !GameState.is_talking:
			run_dialogue(ray.get_collider().name)

func process_player_movement_input(delta):
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))

	if input_direction != Vector2.ZERO && !stop_input:
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)
		
		if need_to_turn():
			raycast_update()
			anim_state.travel("Idle")
			anim_tree.set("parameters/conditions/idle", false)
			anim_tree.set("parameters/conditions/is_turning", true)
			anim_tree.set("parameters/conditions/is_walking", false)
			player_state = PlayerState.TURNING
		else:
			anim_tree.set("parameters/conditions/idle", false)
			anim_tree.set("parameters/conditions/is_turning", false)
			anim_tree.set("parameters/conditions/is_walking", true)
			player_state = PlayerState.WALKING
			move(delta)
	else:
		if !is_moving:
			anim_tree.set("parameters/conditions/idle", true)
			anim_tree.set("parameters/conditions/is_turning", false)
			anim_tree.set("parameters/conditions/is_walking", false)
		
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
	else:
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
	player_state = PlayerState.IDLE
	
func entered_door():
	emit_signal("player_entered_door_signal")
	
func enter_door():
	is_moving = false
	emit_signal("player_stopped_signal")
	tween.kill()
	$AnimationPlayer.play("Disappear")
	
func surprise():
	var surprise = get_node("surprise")
	surprise.visible = true
	surprise.play()
	await get_tree().create_timer(2).timeout
	surprise.visible = false

func move(delta):
	raycast_update()
	
	if door_ray.is_colliding():
		emit_signal("player_entering_door_signal")
		tween = create_tween()
		is_moving = true
		tween.tween_property(self, "position", initial_position + (input_direction * TILE_SIZE), walk_speed / 10).set_trans(Tween.TRANS_LINEAR)
		tween.connect("finished", enter_door)
		
	elif ledge_ray.is_colliding() && !jumping_over_ledge && !is_moving:
		tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
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
		emit_signal("player_stopped_signal")

	elif ray.is_colliding():
		is_moving = false
		
	elif !is_moving && !jumping_over_ledge:
		tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		anim_state.travel("Walk")
		is_moving = true
		tween.tween_property(self, "position", initial_position + (input_direction * TILE_SIZE), walk_speed / 10).from_current().set_trans(Tween.TRANS_LINEAR)
		await tween.finished
		
		is_moving = false
		initial_position = position
		emit_signal("player_stopped_signal")

func run_dialogue(name):
	emit_signal("dialogue", name)
		
func cutscene_input_action_pressed(directions):
	for d in directions:
		is_moving = true
		if d == "DOWN":
			input_direction = Vector2.DOWN
		elif d == "UP":
			input_direction = Vector2.UP
		elif d == "LEFT":
			input_direction = Vector2.LEFT
		elif d == "RIGHT":
			input_direction = Vector2.RIGHT

		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)
		initial_position = position
		#yield(get_node("."), "player_stopped_signal")

func cutscene_turn_player(directions):
	for d in directions:
		is_moving = false
		player_state = PlayerState.TURNING
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

func stop_movement():
	stop_input = true

func resume_movement():
	stop_input = false
