shader_type canvas_item;

uniform float alpha : hint_range(0.0, 1.0);

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    color.a *= alpha;  // Apply alpha mask here to control visibility
    COLOR = color;
}
