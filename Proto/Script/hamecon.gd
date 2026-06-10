extends CharacterBody2D
class_name Player

@export var Speed_down = 100
@export var Speed_coter = 1000
@export var Puissance_accoup : int = 5000

@onready var timer_invincibilite: Timer = $TimerInvincibilite
@onready var chest_catch_sfx: AudioStreamPlayer = $Chest_Catch_SFX

# --- LA SEULE LIGNE AJOUTÉE AU DÉBUT ---
@onready var bulles_degats: CPUParticles2D = $BullesDegats

# --- NOUVELLES VARIABLES POUR LES DÉCHETS ---
var dechet_accroche: Node2D = null # Stocke le déchet actuellement attrapé
# Ajustez ce Vector2 pour définir où le déchet se place par rapport au centre de l'hameçon
@export var position_accroche: Vector2 = Vector2(0, 20) 

var Time_presse = 0
var temps_max = 1



signal joueur_touche(degats: float)

func déclencher_degats() -> void:
	timer_invincibilite.start()
	# On émet le signal. On retire l'effet de bulles d'ici, 
	# car il va maintenant être géré de manière centrale juste en dessous.
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
		if collider.is_in_group("dechet"):
			if timer_invincibilite.is_stopped():
				déclencher_degats()

func down (delta):
	if not(Input.is_action_pressed("SPACE")):
		Time_presse += delta 
		if Time_presse > temps_max : 
			Time_presse = temps_max
		velocity.y = lerp(0,Speed_down, Time_presse/ temps_max ) * delta 
	if Input.is_action_just_pressed("SPACE"):
		Time_presse = 0 

func deplacement (delta):
	if Input.is_action_pressed("SPACE"):
		Time_presse += delta 
		if Time_presse > temps_max : 
			Time_presse = temps_max
		velocity.y = -lerp(0,Puissance_accoup, Time_presse/temps_max ) * delta 
	if Input.is_action_just_released("SPACE"):
		Time_presse = 0 
		
	var direction := Input.get_axis("LEFT", "RIGHT")+ Input.get_axis("Fleche_Gauche", "Fleche_droite")
	direction = clamp(direction, -1.0, 1.0)
	if direction :
		velocity.x = direction * Speed_coter
	else:
		velocity.x = move_toward(velocity.x, 0, Speed_coter)

# --- NOUVELLE FONCTION : DÉTECTION ET ACCROCHE MODIFIÉE ---
func _on_zone_accroche_area_entered(area: Area2D) -> void:
	# 1. On vérifie si l'objet touché fait partie du groupe "dechet"
	# 2. On vérifie si on n'a pas DÉJÀ un déchet sur l'hameçon
	if area.is_in_group("dechet") and dechet_accroche == null:
		# On stocke la référence du déchet
		dechet_accroche = area
		chest_catch_sfx.play()
		# On désactive la détection de la zone pour qu'elle ne déclenche plus d'événements
		# NOUVELLE ÉCRITURE (sécurisée pour Godot) :
		area.set_deferred("monitoring", false)
		area.set_deferred("monitorable", false)
		
		print("Déchet accroché !")

func test_ferrage (delta):
	pass

func _on_joueur_touche(degats: float) -> void:

	bulles_degats.restart()
	bulles_degats.emitting = true
	print("Le joueur a pris un tick de dégâts : ", degats)
