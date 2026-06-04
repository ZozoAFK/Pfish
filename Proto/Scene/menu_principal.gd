extends Control

@onready var World = preload("res://Proto/Scene/World.tscn")

func _on_start_btn_button_down() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(World)


func _on_quit_btn_button_down() -> void:
	get_tree().quit()
