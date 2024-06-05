shader_type canvas_item;
render_mode blend_mix;

uniform float u_amp_flutter: hint_range(0, 100) = 10.0;
uniform float u_angle_flutter: hint_range(-180, 180) = 30.0;
uniform float u_speed_flutter: hint_range(0.1, 10) = 1.0;
uniform float u_amp_wave: hint_range(0, 100) = 10.0;
uniform float u_angle_wave: hint_range(-180, 180) = -30.0;
uniform float u_speed_wave: hint_range(0, 10) = 2.0;
uniform float u_len_wave: hint_range(10, 1000) = 100.0;
uniform float u_shape_wave: hint_range(1, 10) = 3;
uniform float u_width_wave: hint_range(0.1, 4) = 1;
uniform float u_x_light: hint_range(-1, 4) = 0.2;
uniform float u_shape_light: hint_range(0.5, 4) = 2;
uniform float u_width_light: hint_range(0.1, 2) = 1;



vec2 rotate(vec2 v, float angle) {
	mat2 rotation_matrix = mat2(
			vec2(cos(angle / 180.0 * PI), -sin(angle / 180.0 * PI)),
			vec2(sin(angle / 180.0 * PI), cos(angle / 180.0 * PI)));
	return v * rotation_matrix;
}

float lorentzian(float x, float x0, float w, float shp) {
	// modified lorentzian peak function with half-width w and exponent shp
	// around center of x0. Normalized to be 1 at x0.
	return pow(w, 2) / (pow(abs(x - x0), shp) + pow(w, 2));
}

float lorentzian_periodic(float x, float x0, float w, float shp, float per) {
	return lorentzian(mod(x - per/ 2.0 - x0, per), per / 2.0, w, shp);
}

void light() {
	float x = FRAGCOORD.x / 200.0 / u_width_light;
	float x0 = u_x_light * 4.0 / u_width_light;
	LIGHT.a = lorentzian(x, x0, 1, u_shape_light);
}

void vertex() {
	float x = mod(VERTEX.x / u_len_wave, 1.0) * 4.0 - 2.0;
	float x0 = TIME * u_speed_wave;
	float amp_wave = u_amp_wave * lorentzian_periodic(x, x0, u_width_wave, u_shape_wave, 4);
	vec2 wave = rotate(vec2(amp_wave, 0), u_angle_wave);
	float amp_flutter = u_amp_flutter * sin(u_speed_flutter * TIME);
	vec2 flutter = rotate(vec2(amp_flutter, 0), u_angle_flutter);
	VERTEX = VERTEX + flutter + wave;
}