shader_type canvas_item;

void fragment() {
    COLOR = texture(TEXTURE, UV);
    COLOR.rgb *= 1.5; // Adds emission (tweak this value for brightness)
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
