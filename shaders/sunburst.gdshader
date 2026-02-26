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

void fragment() {
	// 1. Coordenadas centradas y corregidas por aspect ratio
	// TEXTURE_PIXEL_SIZE nos da el tamaño del pixel (1/width, 1/height)
	// Relación de aspecto: width / height
	float aspect_ratio = TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;
	vec2 uv = UV - vec2(center_x, center_y);
	uv.x *= aspect_ratio; // Corregir el estiramiento horizontal
	
	// 2. Ángulo polar
	// atan() da un rango de -PI a PI
	float angle = atan(uv.y, uv.x);
	
	// 3. ANIMACIÓN 1: Rotar en el centro
	// Sumamos el tiempo multiplicado por la velocidad para rotar
	float rotated_angle = angle + (TIME * rotation_speed);
	
	// 4. Calcular los rayos (Sunburst)
	// Multiplicamos el ángulo por la cantidad de rayos.
	// Usamos cos() para obtener ondas de -1 a 1.
	float ray_wave = cos(rotated_angle * float(num_rays));
	
	// Convertimos la onda en franjas (0.0 a 1.0)
	// smoothstep suaviza los bordes para combatir el aliasing
	float rays = smoothstep(-ray_softness, ray_softness, ray_wave);
	
	// 5. ANIMACIÓN 2: Pulsar / Cambiar a un color más claro
	// sin() genera un oscilador de -1 a 1. Lo normalizamos a 0.0 - 1.0.
	float pulse = (sin(TIME * pulse_speed) + 1.0) * 0.5;
	
	// Mezclamos el color base con el color de pulso según la variable pulse
	vec4 current_ray_color = mix(ray_color_base, ray_color_pulse, pulse * pulse_intensity);
	
	// 6. Resultado final
	// Mezclar el color de fondo con el color del rayo donde corresponde
	COLOR = mix(bg_color, current_ray_color, rays);
}
