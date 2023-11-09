extends Resource
class_name NPCModel

@export var id: String
@export var name: String
@export_enum("FACE LEFT", "FACE RIGHT", "FACE UP", "FACE DOWN", "WANDER LEFT AND RIGHT", "WANDER AROUND") var movement_type: String
@export var pokemon: Array[Resource]
@export var items: Array[Resource]
@export var is_player: bool
@export var world_encounter: Resource
@export var battle_begin: Resource
#export(Resource) var battle_loose
#export(Resource) var world_loose
@export var beat_flag_mutations: Array[Resource]
@export var loose_flag_mutations: Array[Resource]
@export var battle_graphic: PackedScene
@export var world_graphic: Texture

var active_pokemon

func is_dead() -> bool:
	for p in pokemon:
		if p.hp > 0:
			return false
	return true
