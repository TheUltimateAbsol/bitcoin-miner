shader_type canvas_item;

// Executed for every pixel covered by the sprite on screen
void fragment() {
    vec4 col = texture(TEXTURE, UV);
    COLOR = vec4(1,1,1,col.a);
}