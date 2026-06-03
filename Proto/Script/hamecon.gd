extends CharacterBody2D
class_name Player

@export var Speed_down = 100
@export var Speed_coter = 1000
@export var Puissance_accoup : int = 5000
@onready var timer_invincibilite: Timer = $TimerInvincibilite

# --- NOUVELLES VARIABLES POUR LES DÉCHETS ---
var dechet_accroche: Node2D = null # Stocke le déchet actuellement attrapé
# Ajustez ce Vector2 pour définir où le déchet se place par rapport au centre de l'hameçon
@export var position_accroche: Vector2 = Vector2(0, 20) 

signal joueur_touche(degats: float)

func déclencher_degats() -> void:
	timer_invincibilite.start()
	joueur_touche.emit(10.0)

func _process(delta: float) -> void:
	# Si un déchet est accroché, on force sa position à suivre l'hameçon
	if dechet_accroche != null and is_instance_valid(dechet_accroche):
		dechet_accroche.global_position = global_position + position_accroche

func _physics_process(delta: float) -> void:
	down(delta)
	deplacement(delta)
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("danger"):
			if timer_invincibilite.is_stopped():
				déclencher_degats()

func down (delta):
	if not(Input.is_action_just_pressed("SPACE")):
		velocity.y = Speed_down

func deplacement (delta):
	if Input.is_action_just_pressed("SPACE"):
		velocity.y = -Puissance_accoup
		
	var direction := Input.get_axis("LEFT", "RIGHT")
	if direction:
		velocity.x = direction * Speed_coter
	else:
		velocity.x = move_toward(velocity.x, 0, Speed_coter)

# --- NOUVELLE FONCTION : DÉTECTION ET ACCROCHE ---
func _on_zone_accroche_body_entered(body: Node2D) -> void:
	# 1. On vérifie si l'objet touché fait partie du groupe "dechet"
	# 2. On vérifie si on n'a pas DÉJÀ un déchet sur l'hameçon
	if body.is_in_group("dechet") and dechet_accroche == null:
		# On stocke la référence du déchet
		dechet_accroche = body
		
		# Optionnel : Si le déchet a des collisions qui bloquent le joueur, 
		# on les désactive pour qu'il se laisse porter sans physique
		if body is CharacterBody2D or body is StaticBody2D:
			body.process_mode = PROCESS_MODE_DISABLED 
			# (Désactive ses scripts et sa physique propre pour qu'il devienne passif)
		
		print("Déchet accroché !")


func test_ferrage (delta):
	pass

func _on_joueur_touche(degats: float) -> void:
	pass
