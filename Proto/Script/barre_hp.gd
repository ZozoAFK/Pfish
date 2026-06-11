extends Node2D

@onready var hp_gris: TextureProgressBar = $CanvasLayer/HPGris
@onready var hp_clair: TextureProgressBar = $CanvasLayer/HPClair
@onready var hp_vert: TextureProgressBar = $CanvasLayer/HPVert

# Récupération du nœud de bruitage
@onready var damage_sfx: AudioStreamPlayer = $Damage_SFX

@export var pv_max: int = 100
@export var vitesse_transition: float = 0.5 # Temps (en secondes) pour que HPClair descende
@export var degats_instantanes: float = 10.0

# --- VARIABLE POUR STOCKER LE TWEEN ACTIF ---
var tween_hp_clair: Tween

# --- VARIABLES POUR LA DÉFAITE ---
var scene_defaite = preload("res://Proto/Scene/Panneau_DEFAITE.tscn")
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

func collision_instantanee(degats: float) -> void:
	if not mort:
		damage_sfx.play()

	# 1. HPVert diminue INSTANTANÉMENT
	hp_vert.value = clamp(hp_vert.value - degats, 0, pv_max)
	
	# 2. On gère le Tween de HPClair de manière sécurisée
	# Si un Tween tournait déjà sur la barre claire, on l'arrête proprement
	if tween_hp_clair and tween_hp_clair.is_running():
		tween_hp_clair.kill()
	
	tween_hp_clair = create_tween()
	
	# 💡 CORRECTION ICI : La cible doit toujours être EXACTEMENT la valeur actuelle de HPVert !
	# Comme ça, même si on prend 3 coups d'affilée, elle sait exactement où elle doit atterrir.
	tween_hp_clair.tween_property(hp_clair, "value", hp_vert.value, vitesse_transition)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	verifier_mort()

func _on_hamecon_joueur_touche(degats: float) -> void:
	collision_instantanee(degats)

# --- VÉRIFICATION ET CHANGEMENT DE SCÈNE ---
func verifier_mort() -> void:
	if hp_vert.value <= 0 and not mort:
		mort = true
		declencher_defaite()

func declencher_defaite() -> void:
	print("Plus de PV ! Défaite dans 2 secondes...")
	
	# Désactive les collisions de la barre de vie pour éviter les signaux en boucle
	if has_node("CanvasLayer"):
		$CanvasLayer.hide()
	
	# On attend les 2 secondes pendant que l'animation ou le feedback se joue
	await get_tree().create_timer(2.0).timeout
	
	# --- C'EST ICI QU'ON RÉINITIALISE, JUSTE AVANT DE QUITTER ---
	if ScoreManager.has_method("reinitialiser_niveau_actuel"):
		ScoreManager.reinitialiser_niveau_actuel()
		
	get_tree().change_scene_to_packed(scene_defaite)
