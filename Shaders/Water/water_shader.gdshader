shader_type canvas_item;

uniform vec4 color: source_color;

uniform sampler2D fast_noise: repeat_enable;
uniform sampler2D screen_content: hint_screen_texture;

uniform vec2 world_offset;
uniform vec2 speed = vec2(0.01, 0.0);

uniform float wave_strength = 2;

// Called for every pixel the material is visible on.
void fragment() {
	vec2 uv = UV + world_offset * 0.01 + speed * TIME;
	vec2 noise = texture(fast_noise, uv).rg;
	vec2 distortion = noise * (wave_strength / 100.0);

	COLOR = texture(screen_content, SCREEN_UV + distortion) * color;
}
