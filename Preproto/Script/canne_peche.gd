extends CharacterBody2D



func _process(delta: float) -> void:
	rotation = (get_global_mouse_position()-global_position).angle()+deg_to_rad(90)
	#look_at(get_global_mouse_position())


func _physics_process(delta: float) -> void:
	
	
	move_and_slide()
