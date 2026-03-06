shader_type canvas_item;

// Gold sweep highlight shader for text/labels
// A diagonal sheen sweeps across the text at a configurable interval.

uniform float sweep_speed : hint_range(0.1, 5.0) = 0.6;
uniform float sweep_width : hint_range(0.05, 0.5) = 0.15;
uniform float shine_intensity : hint_range(0.0, 2.0) = 0.8;
uniform float pause_ratio : hint_range(0.0, 0.8) = 0.4;
uniform vec4 shine_color : source_color = vec4(1.0, 0.95, 0.7, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Combine texture with vertex color (for text: white glyph * font color)
	vec4 base = tex * COLOR;

	// Cycle: sweep phase + pause phase
	float cycle = fract(TIME * sweep_speed);
	float sweep_phase = cycle / (1.0 - pause_ratio);

	if (sweep_phase <= 1.0) {
		float diag = (UV.x + UV.y) * 0.5;
		float pos = mix(-sweep_width, 1.0 + sweep_width, sweep_phase);
		float dist = abs(diag - pos);
		float highlight = smoothstep(sweep_width, 0.0, dist);

		vec3 sheen = shine_color.rgb * highlight * shine_intensity;
		base.rgb += sheen * base.a;
	}

	// Output final color (bypass default COLOR multiply)
	COLOR = base;
}
