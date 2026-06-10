extends TextureButton

# Configuration des effets au survol
@export var hover_scale : Vector2 = Vector2(1.2, 1.2) # Grossit de 20%
@export var hover_color : Color = Color(1.2, 1.2, 1.5) # Légère teinte lumineuse

# Référence pour le son
@export var hover_sfx : AudioStreamPlayer

# Variables pour stocker les valeurs d'origine
var base_scale : Vector2
var base_color : Color
var tween : Tween

func _ready() -> void:
	# On sauvegarde l'état initial
	base_scale = scale
	base_color = modulate
	
	# On attend que le layout soit complètement calculé et trié par Godot
	await get_tree().process_frame
	
	# Maintenant la taille 'size' est correcte et réelle !
	pivot_offset = size / 2

# Quand la souris entre dans le rectangle du bouton
func _on_mouse_entered() -> void:
	# On arrête l'animation précédente si elle était en cours
	if tween and tween.is_running():
		tween.kill()
		
	# On crée une nouvelle animation fluide en parallèle (scale + couleur en même temps)
	tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", hover_scale, 0.1).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", hover_color, 0.1)
	
	# On joue le son s'il est assigné
	if hover_sfx:
		hover_sfx.play()

# Quand la souris sort du rectangle du bouton
func _on_mouse_exited() -> void:
	if tween and tween.is_running():
		tween.kill()
		
	# Retour fluide à la taille et à la couleur d'origine
	tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", base_scale, 0.1).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", base_color, 0.1)
