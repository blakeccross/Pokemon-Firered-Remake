extends Node2D

var tween_
var tween__

@onready var front_position_:Vector2 = $front.position
@onready var back_position_:Vector2 = $back.position

func _ready()-> void:
	tween_ = create_tween()
	tween__ = create_tween()
	
	tween__.repeat = true
	#$front.rotation_degrees = 5
	#tween__.interpolate_property($front, "rotation_degrees", 5,  -5, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.0)
	#tween__.interpolate_property($front, "rotation_degrees", -5, 5, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1.0)
	tween__.start()
	
func begin(tween) -> void:
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

func show_back():
	$front.visible = false
	$back.visible = true

func show_front():
	$front.visible = true
	$back.visible = false

func faint():
	$faint.play()
	tween_.interpolate_property(self, "position:y", null, 200, 0.5, Tween.TRANS_QUAD)
	return tween_.block()
	
func level_up():
	#$level_up.play()
	print("dying sound")

func learn():
	$learn.play()

func enter():
	$enter.pitch_scale = 1.0 + randf_range(-0.3, 0.9)
	$enter.play()
	tween_.interpolate_property(self, "scale", Vector2(), scale, 0.5, Tween.TRANS_QUAD)
	scale = Vector2()
	return tween_.block()

func withdraw():
	tween_.interpolate_property(self, "scale", null, Vector2(), 0.5, Tween.TRANS_QUAD)
	return tween_.block()
