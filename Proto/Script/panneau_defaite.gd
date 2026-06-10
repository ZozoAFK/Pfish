extends Control

# On récupère le nœud qui va jouer le son
@onready var sfx_player: AudioStreamPlayer = $Bouttons

func _ready() -> void:
	# On force la souris à redevenir visible et utilisable pour l'UI
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_retry_btn_pressed() -> void:
	# On lance le bruitage de clic
	sfx_player.play()
	
	# On attend 1 seconde pour entendre le son
	await get_tree().create_timer(1.0).timeout
	
	# SOLUTION DYNAMIQUE : On charge le dernier niveau enregistré dans le GameManager
	get_tree().change_scene_to_file(GameManager.dernier_niveau_joue)

func _on_main_menu_btn_pressed() -> void:
	# On lance le bruitage de clic
	sfx_player.play()
	
	# On attend 1 seconde pour entendre le son
	await get_tree().create_timer(1.0).timeout
	
	# Solution directe pour le menu principal
	get_tree().change_scene_to_file("res://Proto/Scene/menu_principal.tscn")
