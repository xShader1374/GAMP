shader_type canvas_item;

uniform float led_spacing = 0.35;
uniform float glow_intensity = 1.5;
uniform float color_speed = 1.0;
uniform float decay_factor = 0.2;

const int VU_COUNT = 40;
const float segment_count = 240.0;

uniform float[VU_COUNT] freq_data;
uniform float time = 0.0;

void fragment() {
	vec2 uv = UV;
	uv.y = 1.0 - uv.y;
	
	float vu_count = float(VU_COUNT);
	float segment_height = 1.0 / segment_count;
	
	vec2 pos = vec2(floor(uv.x * vu_count)/vu_count, floor(uv.y * segment_count)/segment_count);
	int index = clamp(int(uv.x * vu_count), 0, VU_COUNT-1);
	float fft = freq_data[index];
	
	// Modificato: invertito color1 e color2 nel mix
	vec3 color1 = 0.5 + 0.5 * cos(vec3(0.9, 0.5, 0.3) + time * color_speed); // Colori "caldi"
	vec3 color2 = 0.5 + 0.5 * cos(vec3(0.2, 0.7, 1.0) + time * color_speed); // Colori "freddi"
	vec3 color = mix(color1, color2, sqrt(uv.y)) * (1.0 + fft * glow_intensity); // Invertito l'ordine del mix
	
	float mask = smoothstep(fft + decay_factor * segment_height, fft, pos.y);
	mask = mix(0.25, 1.0, mask);
	
	vec2 dist = fract((uv - pos) * vec2(vu_count, segment_count)) - 0.5;
	float led = 
		smoothstep(1.5, led_spacing, abs(dist.x)) * 
		smoothstep(1.5, led_spacing, abs(dist.y));
	
	float glow = pow(fft, 4.0) * 1.0;
	color += vec3(glow * 0.5, glow * 0.3, glow);
	
	COLOR = vec4(led * color * mask, 1.0);
}