extends CharacterBody2D
class_name Player

@export var Speed_down = 100
@export var Speed_coter = 1000
@export var Puissance_accoup : int = 5000


func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	down(delta)
	deplacement(delta)
	move_and_slide()

func down (delta):
	# descente du hamecon
	if not(Input.is_action_just_pressed("SPACE")):
		velocity.y = Speed_down

func deplacement (delta):
	# remonter du hamecon grace a un accoup
	if Input.is_action_just_pressed("SPACE"):
		velocity.y = -Puissance_accoup
		
	# mouverment droit gauche hamecon
	var direction := Input.get_axis("LEFT", "RIGHT")
	if direction:
		velocity.x = direction * Speed_coter
	else:
		velocity.x = move_toward(velocity.x, 0, Speed_coter)
	
func test_ferrage (delta):
	pass
