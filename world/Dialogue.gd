extends CanvasLayer

onready var info_text_ = find_node("info_text")
onready var tween_ = find_node("Tween")
onready var arrow_ = find_node("arrow")
onready var control = get_node(".")
export(String, FILE, "*.json") var d_file
var dialogue_text = {}
signal finished
	

var dialogue_index = 0
var finished = false

func _ready() -> void:
	Utils.connect("display_dialogue", self, "set_dialogue")
	
func _physics_process(delta: float) -> void:
	arrow_.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		start()

func start():
	control.visible = true
	var player = Utils.get_player()
	player.stop_input = true
	player.anim_state.travel("Idle")
	if dialogue_index < dialogue_text.size():
		finished = false
		info_text_.bbcode_text = dialogue_text[dialogue_index]
		info_text_.percent_visible = 0
		tween_.interpolate_property(
			info_text_, "percent_visible", 0, 1, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		tween_.start()
	else:
		control.visible = false
		emit_signal("finished")
		player.stop_input = false
	dialogue_index += 1


func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	finished = true

func load_dialogue():
	var file = File.new()
	if file.file_exists(d_file):
		file.open(d_file, file.READ)
		return parse_json(file.get_as_text())
		
func set_dialogue(dialogue_key):
	dialogue_index = 0
	dialogue_text = load_dialogue()
	dialogue_text = dialogue_text[dialogue_key]
	start()
	
