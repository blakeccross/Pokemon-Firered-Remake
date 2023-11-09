extends Resource
class_name PokemonModel

signal name_changed 
signal level_changed
signal hp_changed
signal max_hp_changed
signal xp_changed

@export var name: String

@export_range(0, 100) var encounter_chance = 0
@export_range(0, 100) var level: int
		
@export var hp: int
@export var max_hp: int
@export var xp:int = 1
@export var exp_stat:int = 1
@export var attack:int = 1
@export var defense:int = 1
@export var speed:int = 1
@export var wild: bool
@export var moves: Array[Resource]
@export var moves_to_learn: Dictionary
#@export var battle_graphics: PackedScene
#@export var front_battle_graphic: AtlasTexture
#@export var back_battle_graphic: AtlasTexture
@export var sprite_sheet: Texture2D

func prop_change_(property:String, from, to) -> void:
	emit_signal(property + "_changed", from, to)
	emit_signal("changed")

#func set_name(value):
#	var old := name
#	name = value
#	prop_change_("name", old, value)

func set_level(value) -> void:
	pass

func set_hp(value:int) -> void:
	var old := hp
	hp = max(0, value)
	prop_change_("hp", old, value)

func set_max_hp(value:int) -> void:
	var old := max_hp
#	max_hp = value
#	prop_change_("max_hp", old, value)

func set_xp(value:int) -> void:
	var old := xp
#	xp = value
#	prop_change_("xp", old, value)

func is_dead() -> bool:
	return hp <= 0

func get_exp_if_beat() -> float:
	return float(get_level()) * float(exp_stat) * (1.0 if wild else 1.5)

const exp_table_ = {
	"fast": [100, 51, 21, 6, 0]
}

func get_level() -> int:
	for i in exp_table_.fast.size():
		if xp >= exp_table_.fast[i]:
			return exp_table_.fast.size() - i
	return 1
