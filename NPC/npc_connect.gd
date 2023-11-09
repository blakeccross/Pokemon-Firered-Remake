extends Area2D

signal encounter
signal beat

@export var trainer setget set_trainer

func _ready() -> void:
	print(trainer.world_encounter.text)

func set_trainer(value) -> void:
	trainer = value
	#$sprite.call_deferred("create_instance", true, trainer.world_graphic)
