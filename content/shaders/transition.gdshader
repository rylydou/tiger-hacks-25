shader_type canvas_item;


uniform float inner_fill: hint_range(0.0, 1.0);
uniform float outer_fill: hint_range(0.0, 1.0);


const float SQRT_2 = sqrt(2.0);


float circle(vec2 uv, float inner_radius, float outer_radius) {
	float d = length(uv);
	float blur = fwidth(d);
	float t = smoothstep(
		outer_radius + blur,
		outer_radius - blur,
		d
	) - smoothstep(
		inner_radius + blur,
		inner_radius - blur,
		d
	);

	return t;
}

void fragment() {
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 uv = SCREEN_UV;
	uv = uv - vec2(0.5);
	uv.x /= ratio;

	float inner_radius = mix(0.0, 1.0 / ratio * SQRT_2, inner_fill);
	float outer_radius = mix(0.0, 1.0 / ratio * SQRT_2, outer_fill);

	COLOR.a = circle(uv, inner_radius, outer_radius);
}
