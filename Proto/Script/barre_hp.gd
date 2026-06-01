extends Node2D

# On récupère les composants de ta scène
@onready var hp_gris: TextureProgressBar = $CanvasLayer/HPGris
@onready var hp_clair: TextureProgressBar = $CanvasLayer/HPClair
@onready var hp_vert: TextureProgressBar = $CanvasLayer/HPVert

# --- EXPORTS ---
@export var pv_max: int = 100
@export var vitesse_transition: float = 10.0
@export var degats_instantanes: float = 10.0

func _ready() -> void:
	hp_vert.max_value = pv_max
	hp_clair.max_value = pv_max
	hp_gris.max_value = pv_max
	
	hp_vert.value = pv_max
	hp_clair.value = pv_max
	hp_gris.value = pv_max

func _process(delta: float) -> void:
	# Bloquer la position Y
	global_position.y = 10

	# --- FLÈCHE DROITE : Tout descend instantanément ---
	if Input.is_action_just_pressed("Fleche_droite"):
		collision_instantanee(degats_instantanes)
		
	# --- FLÈCHE GAUCHE : On applique les dégâts une seule fois au clic ---
	if Input.is_action_just_pressed("Fleche_Gauche"):
		# MODIFICATION : On n'autorise les dégâts QUE SI la barre claire a fini de descendre.
		# Si hp_clair.value est plus grande que hp_vert.value, le clic est ignoré !
		if hp_clair.value == hp_vert.value:
			collision_fluide(degats_instantanes)

	# --- Logique d'animation de la barre claire ---
	if hp_clair.value > hp_vert.value and not Input.is_action_pressed("Fleche_Gauche"):
		hp_clair.value = lerp(hp_clair.value, hp_vert.value, vitesse_transition * delta)
		
		# Forcer la jonction parfaite
		if abs(hp_clair.value - hp_vert.value) < 0.5:
			hp_clair.value = hp_vert.value

# Logique Flèche gauche : Seule la verte descend d'un coup sec
func collision_fluide(degats: float) -> void:
	hp_vert.value = clamp(hp_vert.value - degats, 0, pv_max)

# Logique Flèche droite : Les deux descendent d'un coup sec
func collision_instantanee(degats: float) -> void:
	hp_vert.value = clamp(hp_vert.value - degats, 0, pv_max)
	hp_clair.value = clamp(hp_clair.value - degats, 0, pv_max)
