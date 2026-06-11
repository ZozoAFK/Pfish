extends Control

@onready var LVL1 = preload("res://Proto/Scene/Niv1.tscn")
@onready var sfx_player: AudioStreamPlayer = $Tuto_sfx

func _ready() -> void:
	sfx_player.play()
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_packed(LVL1)
