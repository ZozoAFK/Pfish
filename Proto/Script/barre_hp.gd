extends Node2D

@onready var hp_gris: TextureProgressBar = $CanvasLayer/HPGris
@onready var hp_clair: TextureProgressBar = $CanvasLayer/HPClair
@onready var hp_vert: TextureProgressBar = $CanvasLayer/HPVert

@export var pv_max: int = 100
@export var vitesse_transition: float = 10.0
@export var degats_instantanes: float = 10.0

# --- NOUVELLES VARIABLES POUR LA DÉFAITE ---
# Le chemin vers ta scène de défaite
var scene_defaite = preload("res://Proto/Scene/Panneau_DEFAITE.tscn")
# Évite de lancer le chrono de défaite plusieurs fois
var mort : bool = false 

func _ready() -> void:
	add_to_group("barre_vie")  # ← permet à Fish de trouver ce nœud
	hp_vert.max_value = pv_max
	hp_clair.max_value = pv_max
	hp_gris.max_value = pv_max
	hp_vert.value = pv_max
	hp_clair.value = pv_max
	hp_gris.value = pv_max

func _process(delta: float) -> void:
	global_position.y = 10
	if Input.is_action_just_pressed("Fleche_droite"):
		collision_instantanee(degats_instantanes)
	if Input.is_action_just_pressed("Fleche_Gauche"):
		if hp_clair.value == hp_vert.value:
			collision_fluide(degats_instantanes)
	if hp_clair.value > hp_vert.value and not Input.is_action_pressed("Fleche_Gauche"):
		hp_clair.value = lerp(hp_clair.value, hp_vert.value, vitesse_transition * delta)
		if abs(hp_clair.value - hp_vert.value) < 0.5:
			hp_clair.value = hp_vert.value

func collision_fluide(degats: float) -> void:
	hp_vert.value = clamp(hp_vert.value - degats, 0, pv_max)
	# On vérifie la mort après la modification de la valeur
	verifier_mort()

func collision_instantanee(degats: float) -> void:
	hp_vert.value = clamp(hp_vert.value - degats, 0, pv_max)
	hp_clair.value = clamp(hp_clair.value - degats, 0, pv_max)
	# On vérifie la mort après la modification de la valeur
	verifier_mort()

func _on_hamecon_joueur_touche(degats: float) -> void:
	collision_instantanee(degats)

# --- NOUVELLE FONCTION : VÉRIFICATION ET CHANGEMENT DE SCÈNE ---
func verifier_mort() -> void:
	# Si les PV tombent à 0 et qu'on n'a pas déjà déclenché la mort
	if hp_vert.value <= 0 and not mort:
		mort = true
		declencher_defaite()

func declencher_defaite() -> void:
	print("Plus de PV ! Défaite dans 2 secondes...")
	
	# On attend 2 secondes
	await get_tree().create_timer(2.0).timeout
	
	# On change de scène vers le panneau défaite
	get_tree().change_scene_to_packed(scene_defaite)
