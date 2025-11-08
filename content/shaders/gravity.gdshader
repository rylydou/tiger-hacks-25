shader_type canvas_item;

uniform float scale = 2.0;
uniform float speed = 1.0;
uniform float arrow_x_density = 10.0;
uniform float arrow_y_density = 5.0;
uniform float stagger = 1.0;
uniform float twist = 0.0;

uniform float inner_feather_start = 0.25;
uniform float inner_feather_end = 0.5;
uniform float outer_feather = 0.9;

float remap(float value, float in_min, float in_max, float out_min, float out_max) {
    return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min);
}

void fragment() {
	vec2 center = vec2(0.5);
	vec2 uv = (UV - center) * 2.0;
	
	float t = TIME * speed;
	
	float r = length(uv);
	float theta = atan(uv.y, uv.x);
	float theta_ratio = remap(theta, -PI, PI, 0.0, 1.0);
	
	float y = fract(r * arrow_y_density + t);
	
	float x = fract(theta_ratio * arrow_x_density);
	
	float slice_index = floor(theta_ratio * arrow_x_density);
	bool is_even_slice = mod(slice_index, 2.0) == 0.0; 
	bool is_odd_slice = mod(slice_index, 2.0) == 1.0;
	
	x += y * twist;
	
	COLOR = texture(TEXTURE, vec2(x, y));
	COLOR.a *= smoothstep(1.0, outer_feather, r);
	COLOR.a *= smoothstep(inner_feather_start, inner_feather_end, r);
	
	// COLOR.r = r;
	// COLOR.g = theta / PI / 2.0;
	// COLOR.b = 0.0;
	// COLOR.a = theta_ratio;
}
