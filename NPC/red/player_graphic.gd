extends Node2D
class_name PlayerGraphic

onready var front_position_:Vector2 = $front.position
onready var back_position_:Vector2 = $back.position

onready var anim_player = $AnimationPlayer

func begin(tween:TweenEx) -> void:
	anim_player.play("idle")
	$front.position.x = - 40
	tween.interpolate_property($front, "position:x", -40, front_position_.x, 1.0)
	$back.position.x = 180
	tween.interpolate_property($back,  "position:x", 180, back_position_.x, 1.0)
	if $front.visible:
		tween.step_property($enter, "playing", false, true, 1.0)
	tween.step_property($front, "modulate:a", 1.0, 0.0, 1.0)
	tween.step_property($front, "modulate:a", 0.0, 1.0, 1.2)
	tween.step_property($back, "modulate:a", 1.0, 0.0, 1.0)
	tween.step_property($back, "modulate:a", 0.0, 1.0, 1.2)
	tween.start()

func exit(tween:TweenEx) -> void:
	anim_player.play("throw")
	tween.interpolate_property($front, "position:x", null, 200, 0.2)
	tween.interpolate_property($back,  "position:x", null, -80, 0.5)
	tween.start()

func enter(tween:TweenEx) -> void:
	tween.interpolate_property($front, "position:x", null, front_position_.x, 0.2)
	tween.interpolate_property($back,  "position:x", null, back_position_.x, 0.2)
	tween.start()

func show_back() -> void:
	$front.visible = false
	$back.visible = true

func show_front() -> void:
	$front.visible = true
	$back.visible = false
