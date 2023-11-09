extends ColorRect

@export_range(0.0, 1.0) var value:
	set(v):
		set_value(v)

func set_value(v:float) -> void:
	value = v
	material.set_shader_param("value", value)
