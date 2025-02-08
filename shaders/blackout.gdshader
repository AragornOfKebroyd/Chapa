shader_type canvas_item;

uniform vec2 player_pos; // Player's position
uniform float light_radius; // Radius of the visibility area
uniform vec2 screen_size; // Screen size (passed from GDScript)

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Calculate distance from the "light source" (player)
	vec2 pixel_pos = UV * screen_size;
	
	float dist = distance(pixel_pos, player_pos);
    
    // Smooth fade effect
	float alpha_sq = (dist/light_radius); 
	float alpha = alpha_sq*alpha_sq;
    // Output black color with dynamic opacity
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
