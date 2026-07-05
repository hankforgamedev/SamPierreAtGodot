shader_type canvas_item;

// Arctic Eggs 風格後製：限色量化 + 4x4 Bayer dithering + 綠灰色調
// 掛在 SubViewportContainer 上，TEXTURE 是低解析度 3D 畫面

uniform int color_steps : hint_range(2, 16) = 5;
uniform float dither_strength : hint_range(0.0, 2.0) = 1.0;
uniform float saturation : hint_range(0.0, 1.5) = 0.45;
uniform vec3 tint : source_color = vec3(0.80, 1.0, 0.84);

const float BAYER[16] = float[16](
	 0.0,  8.0,  2.0, 10.0,
	12.0,  4.0, 14.0,  6.0,
	 3.0, 11.0,  1.0,  9.0,
	15.0,  7.0, 13.0,  5.0
);

void fragment() {
	vec4 src = texture(TEXTURE, UV);

	// 去飽和後套上綠灰色調
	float lum = dot(src.rgb, vec3(0.299, 0.587, 0.114));
	vec3 c = mix(vec3(lum), src.rgb, saturation) * tint;

	// 以低解析度像素為單位對齊 dither 格，讓抖動點跟大像素一致
	vec2 px = floor(UV / TEXTURE_PIXEL_SIZE);
	int idx = int(mod(px.y, 4.0)) * 4 + int(mod(px.x, 4.0));
	float threshold = (BAYER[idx] + 0.5) / 16.0 - 0.5;

	float steps = float(color_steps - 1);
	c = clamp(c + threshold * dither_strength / steps, 0.0, 1.0);
	c = floor(c * steps + 0.5) / steps;

	COLOR = vec4(c, src.a);
}
