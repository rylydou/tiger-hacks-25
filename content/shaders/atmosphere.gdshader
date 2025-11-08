shader_type canvas_item;
render_mode blend_add;


varying flat vec4 MODULATE;


void vertex() {
	MODULATE = COLOR;
}


void fragment() {
	vec2 center = vec2(0.5);
	vec2 uv = (UV - center) * 2.0;
	
	float r = length(uv);
	
	COLOR = texture(TEXTURE, vec2(r, 0.0));
	COLOR *= MODULATE;
}
