shader_type canvas_item;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // Si les trois composantes Rouge, Vert, Bleu sont très proches de 1.0 (blanc pur),
    // on efface le pixel (discard)
    if (color.r > 0.95 && color.g > 0.95 && color.b > 0.95) {
        discard;
    }
    
    COLOR = color;
}