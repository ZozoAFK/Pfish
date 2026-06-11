extends Control

@onready var LVL2 = preload("res://Proto/Scene/niveau_2.tscn")
@onready var MainMenu = preload("res://Proto/Scene/menu_principal.tscn")
@onready var sfx_player: AudioStreamPlayer = $Bouttons

# Références vers vos étoiles (Adaptez les chemins si nécessaire)
@onready var etoile_or_1: TextureRect = $Niveau1_Etoiles/Etoile_Or1
@onready var etoile_argent_1: TextureRect = $Niveau1_Etoiles/Etoile_Argent1
@onready var etoile_bronze_1: TextureRect = $Niveau1_Etoiles/Etoile_Bronze1

@onready var etoile_or_2: TextureRect = $Niveau2_Etoiles/Etoile_Or2
@onready var etoile_argent_2: TextureRect = $Niveau2_Etoiles/Etoile_Argent2
@onready var etoile_bronze_2: TextureRect = $Niveau2_Etoiles/Etoile_Bronze2

func _ready() -> void:
	# 1. On cache toutes les étoiles par défaut
	etoile_or_1.hide()
	etoile_argent_1.hide()
	etoile_bronze_1.hide()
	
	etoile_or_2.hide()
	etoile_argent_2.hide()
	etoile_bronze_2.hide()
	
	# 2. On affiche le résultat du Niveau 1
	var resultat_lvl1 = ScoreManager.obtenir_etoile_pour_niveau("Niveau_1")
	match resultat_lvl1:
		"Or": etoile_or_1.show()
		"Argent": etoile_argent_1.show()
		"Bronze": etoile_bronze_1.show()
		
	# 3. On affiche le résultat du Niveau 2
	var resultat_lvl2 = ScoreManager.obtenir_etoile_pour_niveau("Niveau_2")
	match resultat_lvl2:
		"Or": etoile_or_2.show()
		"Argent": etoile_argent_2.show()
		"Bronze": etoile_bronze_2.show()

func _on_main_menu_button_down() -> void:
	sfx_player.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(MainMenu)
