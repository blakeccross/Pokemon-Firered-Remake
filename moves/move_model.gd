extends Resource
class_name MoveModel

enum Type {
	normal,
	fire,
	water,
	electric
}

@export var name: String
@export var pp: int = 1
@export var power: int = 1
@export_range(0, 1.0) var accuracy: float = 1.0
@export var type: Type
@export var fx: PackedScene
