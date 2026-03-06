shader_type canvas_item;

// Loser/defeat shader — text trembles, desaturates, and drips away miserably.

uniform float shake_speed : hint_range(1.0, 30.0) = 12.0;
uniform float shake_amount : hint_range(0.0, 10.0) = 3.0;
uniform float desaturation : hint_range(0.0, 1.0) = 0.6;
uniform float drip_speed : hint_range(0.1, 3.0) = 0.8;
uniform float drip_amount : hint_range(0.0, 0.05) = 0.02;
uniform float darken : hint_range(0.0, 0.6) = 0.3;
uniform vec4 gloom_color : source_color = vec4(0.4, 0.1, 0.1, 1.0);

void fragment() {
	vec2 uv = UV;

	// Trembling / shaking distortion
	float shake_x = sin(TIME * shake_speed + uv.y * 20.0) * shake_amount * TEXTURE_PIXEL_SIZE.x;
	float shake_y = cos(TIME * shake_speed * 0.7 + uv.x * 15.0) * shake_amount * TEXTURE_PIXEL_SIZE.y * 0.5;
	uv += vec2(shake_x, shake_y);

	// Drip distortion — letters melt downward unevenly
	float drip = sin(uv.x * 25.0 + TIME * drip_speed) * drip_amount * uv.y;
	uv.y += drip;

	vec4 tex = texture(TEXTURE, uv);
	vec4 base = tex * COLOR;

	// Desaturate — drain the life out
	float gray = dot(base.rgb, vec3(0.299, 0.587, 0.114));
	base.rgb = mix(base.rgb, vec3(gray), desaturation);

	// Darken and tint with gloomy color
	base.rgb = mix(base.rgb, gloom_color.rgb, darken);

	// Pulsing darkness — slow, oppressive throb
	float throb = sin(TIME * 2.5) * 0.1 + 0.9;
	base.rgb *= throb;

	COLOR = base;
}
