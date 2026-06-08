extends TextureButton

# Configuration des effets au survol
@export var hover_scale : Vector2 = Vector2(1.2, 1.2) # Grossit de 20%
@export var hover_color : Color = Color(1.2, 1.2, 1.5) # Légère teinte bleutée/lumineuse

# On stocke les valeurs de base pour pouvoir y retourner
var base_scale : Vector2
var base_color : Color

func _ready() -> void:
	# --- CODE AJOUTÉ : Génération automatique du masque de collision ---
	var texture_bouton = texture_normal
	if texture_bouton:
		var img = texture_bouton.get_image()
		var masque = BitMap.new()
		masque.create_from_image_alpha(img)
		texture_click_mask = masque
	# -------------------------------------------------------------------

	# On sauvegarde la taille et la couleur d'origine au lancement
	base_scale = scale
	base_color = self.modulate

# Quand la souris passe sur la barque
func _on_mouse_entered() -> void:
	# On applique le grossissement
	scale = hover_scale
	# On change la couleur (modulate). 
	# Astuce : Dépasser 1.0 (ex: 1.5) crée un effet "lumineux" en Pixel Art !
	self.modulate = hover_color

# Quand la souris s'en va
func _on_mouse_exited() -> void:
	# On remet tout comme au début
	scale = base_scale
	self.modulate = base_color
