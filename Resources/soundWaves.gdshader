shader_type canvas_item;

uniform sampler2D audio_data;

float sigmoid(float x)
{
    return 1. / (1. + exp(x));
}

vec3 sigmoid2(vec3 xyz)
{
    return vec3(sigmoid(xyz.x), sigmoid(xyz.y), sigmoid(xyz.z));
}

float sample_at(float f)
{
    return texture(audio_data, vec2(f / 16.0, 0.)).x;
}

float sample_multiple(float f)
{
    float delta = .1;
    return 0.2 * (sample_at(f - 2. * delta) + sample_at(f - delta) + sample_at(f) + sample_at(f + delta) + sample_at(f + 2. * delta));
}

void fragment() {
    vec2 uv = (FRAGCOORD.xy - 0.5) / SCREEN_PIXEL_SIZE;
    uv = 2. * uv - 1.;
    uv.x *= SCREEN_PIXEL_SIZE.x/SCREEN_PIXEL_SIZE.y;

    vec2 center = vec2(0.);
    float d = length(uv - center);

    float amplitude = sample_multiple(d * d);
    d -= amplitude;
    float weird = sigmoid(abs(uv.x) * abs(uv.y));
    float speed = 6. * amplitude * sin(TIME * weird * 0.005) * 0.001;
    float dist_diagonal = abs(abs(uv.x) - abs(uv.y));
    dist_diagonal += d * amplitude;
    dist_diagonal *= dist_diagonal;
    amplitude += .1 / (.1 + smoothstep(1., 0.1, dist_diagonal));
    float brightness = 3. * amplitude * sigmoid(sin(d * d * 16. - speed * TIME + 2. * speed * amplitude));

    vec3 col = sigmoid2(vec3(uv, sin(TIME)));

    COLOR = vec4(col * brightness,1.0);
}
