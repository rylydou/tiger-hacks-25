shader_type canvas_item;


uniform float radius = 0.5;
uniform float feather = 0.5;
uniform float contrast = 1.0;


varying flat vec4 MODULATE;


void vertex() {
	MODULATE = COLOR;
}


void fragment() {
	vec2 center = vec2(0.5);
	vec2 uv = (UV - center) * 2.0;
	
	float r = length(uv);
	
	float a = smoothstep(radius, radius + feather, r);
	
	a = pow(a, contrast);
	
	COLOR.a *= a;
}
