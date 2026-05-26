extends CharacterBody2D
class_name  Hamecon

var SPEED = 300.0
var JUMP_VELOCITY = 200.0


func _physics_process(delta: float) -> void:

	# desente du hamecon
	for i in 1000:
		if not(Input.is_action_just_pressed("SPACE")):
			velocity.y = JUMP_VELOCITY
	# remonter du hamecon
		if Input.is_action_just_pressed("SPACE"):
			velocity.y = -7000
		
		
	# mouverment droit gauche hamecon
	var direction := Input.get_axis("LEFT", "RIGHT")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
