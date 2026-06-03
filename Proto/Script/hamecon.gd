extends CharacterBody2D
class_name Player

@export var Speed_down = 100
@export var Speed_coter = 1000
@export var Puissance_accoup : int = 5000
@onready var timer_invincibilite: Timer = $TimerInvincibilite

signal joueur_touche(degats: float)

func déclencher_degats() -> void:
	# 3. On lance le chrono de 0.5s dès qu'on prend un coup
	timer_invincibilite.start()
	
	# 4. On envoie le signal à la barre de vie
	joueur_touche.emit(10.0)

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	down(delta)
	deplacement(delta)
	move_and_slide()
# On vérifie toutes les collisions de ce frame
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		#Si =Danger 
		if collider.is_in_group("danger"):
			# 2. AVANT de faire des dégâts, on vérifie si le joueur n'est PAS invincible
			# 'is_stopped()' est VRAI si le timer ne tourne pas (donc joueur vulnérable)
			if timer_invincibilite.is_stopped():
				déclencher_degats()

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


func _on_joueur_touche(degats: float) -> void:
	pass # Replace with function body.
