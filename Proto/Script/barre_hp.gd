extends Node2D

# On récupère les composants de votre scène en utilisant leurs noms exacts
@onready var hp_gris: TextureProgressBar = $CanvasLayer/HPGris
@onready var hp_clair: TextureProgressBar = $CanvasLayer/HPClair
@onready var hp_vert: TextureProgressBar = $CanvasLayer/HPVert
@export var pv_max = 100
func _Static(_delta: float) -> void:
	# 1. Bloquer la position : on force X à rester à sa place (ex: 20 pixels du bord gauche)
	# et Y à sa hauteur initiale.
	global_position.y = 10
	pass
	
	

func _ready() -> void:
	# On définit la valeur maximale (par exemple 100) pour les trois barres
	var pv_max = 100
	
	hp_vert.max_value = pv_max
	hp_clair.max_value = pv_max
	hp_gris.max_value = pv_max
	
	# Au début du jeu, les trois barres sont pleines
	hp_vert.value = pv_max
	hp_clair.value = pv_max
	hp_gris.value = pv_max

func _process(_delta: float) -> void:
	# Détection de la pression sur la touche "Flèche de droite"
	# "ui_right" correspond par défaut à la flèche directionnelle droite dans Godot
	if Input.is_action_just_pressed("Fleche_droite"):
		collision(10)


# La fonction demandée pour réduire les barres Verte et Claire de 10 unités
func collision(degats: float) -> void:
	# On réduit la valeur de HPVert et HPClair
	hp_vert.value -= degats
	hp_clair.value -= degats
	
	# Sécurité pour éviter que la vie descende en dessous de 0
	if hp_vert.value < 0:
		hp_vert.value = 0
	if hp_clair.value < 0:
		hp_clair.value = 0
