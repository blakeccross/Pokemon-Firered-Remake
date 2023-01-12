extends Resource
class_name NPCModel

export(String) var id
export(String) var name
export(String, "FACE LEFT", "FACE RIGHT", "FACE UP", "FACE DOWN", "WANDER LEFT AND RIGHT", "WANDER AROUND") var movement_type
export(bool) var disable_collision
export(Array, Resource) var pokemon
export(Array, Resource) var items
export(bool) var is_player
export(Resource) var world_encounter
export(Resource) var battle_begin
export(Resource) var battle_loose
export(Resource) var world_loose
export(Array, Resource)    var beat_flag_mutations
export(Array, Resource)    var loose_flag_mutations
export(PackedScene) var battle_graphic
export(Texture) var world_graphic

var active_pokemon

func is_dead() -> bool:
	for p in pokemon:
		if p.hp > 0:
			return false
	return true
