shader_type canvas_item;

uniform int visible_rows = 0;
uniform float offset = 0.0;

const float viewport_height = 1.0 / 240.0;
const float row_size = 1.0 / 8.0;

void fragment() {
	float y = UV.y / viewport_height;
	float row = float((y * row_size) + (offset * row_size));

	if (row > float(visible_rows)) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	}
}