extends Node2D

# Glisse et dépose le fichier de ta scène de victoire ici depuis le système de fichiers
@export var scene_victoire: PackedScene 
func _ready() -> void:
	GameManager.dernier_niveau_joue = "res://Proto/Scene/niveau_2.tscn"
	
func gagner_partie() -> void:
	print("Victoire ! Le trésor est remonté !")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Proto/Scene/Panneau_VICTOIRE.tscn")


func _on_zone_victoire_area_entered(area: Area2D) -> void:
	print("UNE AREA EST ENTRÉE : ", area.name)
	# Si c'est la zone de l'hameçon qui est détectée, on remonte au script du joueur
	if area.owner is Player or area.get_parent() is Player:
		var joueur = area.owner if area.owner is Player else area.get_parent()
		if joueur.dechet_accroche != null and is_instance_valid(joueur.dechet_accroche):
			gagner_partie()
