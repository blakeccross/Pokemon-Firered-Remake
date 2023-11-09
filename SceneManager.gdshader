shader_type canvas_item;

uniform float num_lines = 20.;
uniform float x_threshold: hint_range(0.0, 1.0) = 0.5;
uniform vec2 size = vec2(32.0, 28.0);

uniform sampler2D left_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D right_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec4 white_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 black_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec2 norm_size = SCREEN_PIXEL_SIZE;
    bool half = mod(SCREEN_UV.x / 2.0, norm_size.x) / norm_size.x < 0.5;
    vec2 uv = SCREEN_UV + vec2(0.0, norm_size.y * 0.5 * float(half));
    vec2 center_uv = floor(uv / norm_size) * norm_size;

    float offset = (x_threshold - 0.5) * 2.0 * (norm_size.x / 2.0);
    // Calculate the horizontal offset for left and right textures
    float left_offset = -x_threshold / 2.0;
    float right_offset = x_threshold / 2.0;

    vec2 tiled_uv = vec2(UV.x, fract(UV.y * num_lines / 2.0));
    if (tiled_uv.y < 0.5) {
        if (tiled_uv.x > x_threshold) {
            COLOR = textureLod(left_texture, center_uv + vec2(left_offset, 0.0), 0.0);
        } else {
            COLOR = vec4(COLOR.rgb, 1.0);
        }
    } else {
        if (tiled_uv.x < 1. - x_threshold) {
            COLOR = textureLod(right_texture, center_uv + vec2(right_offset, 0.0), 0.0);
        } else {
            COLOR = vec4(COLOR.rgb, 1.0);
        }
    }
}
