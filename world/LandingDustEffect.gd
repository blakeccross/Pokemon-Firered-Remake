extends AnimatedSprite2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	frame = 0
	play()


func _on_LandingDustEffect_animation_finished():
	queue_free()
