shader_type canvas_item;

// --- Colores ---
uniform vec4 ray_color_base : source_color = vec4(1.0, 0.8, 0.0, 1.0); // Color principal (ej: amarillo cálido)
uniform vec4 ray_color_pulse : source_color = vec4(1.0, 1.0, 0.8, 1.0); // Color del pulsar (más claro/blanco)
uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.0, 0.0); // Color de fondo (transparente por defecto)

// --- Parámetros de la forma ---
uniform int num_rays = 12; // Cantidad de rayos
uniform float center_x = 0.5; // Centro X en coordenadas UV (0.0 a 1.0)
uniform float center_y = 0.5; // Centro Y en coordenadas UV (0.0 a 1.0)
uniform float ray_softness = 0.5; // Suavidad de los bordes del rayo (0.0 = bordes duros)

// --- Parámetros de Animación ---
uniform float rotation_speed = 0.5; // Velocidad de giro (positivo = horario, negativo = antihorario)
uniform float pulse_speed = 3.0; // Velocidad del parpadeo/pulsar
uniform float pulse_intensity = 1.0; // Qué tanto afecta el color del pulso (0.0 = nada, 1.0 = todo)

// --- Desvanecimiento de bordes ---
uniform float edge_fade_start = 0.3; // Distancia donde empieza a desvanecer (0.0 - 1.0)
uniform float edge_fade_end = 0.5;   // Distancia donde es totalmente transparente

void fragment() {
	// 1. Coordenadas centradas y corregidas por aspect ratio
	float aspect_ratio = TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;
	vec2 uv = UV - vec2(center_x, center_y);
	uv.x *= aspect_ratio;
	
	// 2. Distancia radial desde el centro (para desvanecimiento)
	float dist = length(uv);
	float edge_fade = 1.0 - smoothstep(edge_fade_start, edge_fade_end, dist);
	
	// 3. Ángulo polar
	float angle = atan(uv.y, uv.x);
	
	// 4. Rotar
	float rotated_angle = angle + (TIME * rotation_speed);
	
	// 5. Calcular los rayos (Sunburst)
	float ray_wave = cos(rotated_angle * float(num_rays));
	float rays = smoothstep(-ray_softness, ray_softness, ray_wave);
	
	// 6. Pulsar
	float pulse = (sin(TIME * pulse_speed) + 1.0) * 0.5;
	vec4 current_ray_color = mix(ray_color_base, ray_color_pulse, pulse * pulse_intensity);
	
	// 7. Resultado final con desvanecimiento radial
	vec4 result = mix(bg_color, current_ray_color, rays);
	result.a *= edge_fade;
	COLOR = result;
}
