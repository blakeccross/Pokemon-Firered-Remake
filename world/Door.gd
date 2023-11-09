extends Area2D

@export_file("*.txt") var next_scene_path = ""
@export var is_invisible = false

@export var spawn_location = Vector2(0, 0)
@export var spawn_direction = Vector2(0, 0)

@onready var sprite = $Sprite
@onready var anim_player = $AnimationPlayer
@onready var player = get_parent().get_node("Player")

var player_entered = false

func _ready():
	
	if is_invisible:
		$Sprite.texture = null
	sprite.visible = false
	#var player = Utils.get_player()
	player.player_entering_door_signal.connect(enter_door)
	player.player_entered_door_signal.connect(close_door)
	
func enter_door():
	print("ENTERING")
	if player_entered:
		anim_player.play("OpenDoor")
	
func close_door():
	if player_entered:
		anim_player.play("CloseDoor")
		
func door_closed():
	if player_entered:
		Utils.get_scene_manager().transition_to_scene(next_scene_path, spawn_location, spawn_direction)

func _on_Door_body_entered(body):
	player_entered = true

func _on_Door_body_exited(body):
	player_entered = false
