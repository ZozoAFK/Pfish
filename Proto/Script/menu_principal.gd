extends Control

@onready var LVL1 = preload("res://Proto/Scene/Niv1.tscn")
# On récupère le nœud qui va jouer le son
@onready var sfx_player: AudioStreamPlayer = $Bouttons

func _on_start_btn_button_down() -> void:
	# On lance le bruitage de clic
	sfx_player.play()
	
	# Ton timer de 1 seconde est parfait ici ! 
	# Il laisse le temps au son de se jouer avant que la scène ne change.
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(LVL1)


func _on_quit_btn_button_down() -> void:
	# On lance le bruitage de clic
	sfx_player.play()
	
	# ATTENTION : Si on quitte instantanément, le son n'aura pas le temps d'être entendu.
	# On attend un tout petit instant (0.2 seconde) pour entendre le "clic" avant de fermer.
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
