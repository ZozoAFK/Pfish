shader_type canvas_item;

// Tu pourras ajuster la vitesse directement dans l'inspecteur
uniform float speed : hint_range(-0.5, 0.5) = 0.02;

void fragment() {
    // Le "mod(..., 1.0)" force la texture à boucler à l'infini horizontalement
    vec2 moving_uv = vec2(mod(UV.x + TIME * speed, 1.0), UV.y);
    COLOR = texture(TEXTURE, moving_uv);
}