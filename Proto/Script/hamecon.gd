extends CharacterBody2D
class_name Player

@export var Speed_down = 100
@export var Speed_coter = 1000
@export var Puissance_accoup : int = 5000

@onready var timer_invincibilite: Timer = $TimerInvincibilite
@onready var chest_catch_sfx: AudioStreamPlayer = $Chest_Catch_SFX

# --- RÉFÉRENCES VISUELLES ---
@onready var bulles_degats: CPUParticles2D = $BullesDegats
# AJOUT ICI : Récupère ton nœud Sprite2D (adapte le nom si besoin)
@onready var sprite: Sprite2D = $ZoneAccroche/Sprite2D

# --- NOUVELLES VARIABLES POUR LES DÉCHETS ---
var dechet_accroche: Node2D = null # Stocke le déchet actuellement attrapé
# Ajustez ce Vector2 pour définir où le déchet se place par rapport au centre de l'hameçon
@export var position_accroche: Vector2 = Vector2(0, 20) 

var Time_presse = 0
var temps_max = 1

# Variable pour stocker le Tween de couleur (pour éviter les conflits si on reprend des dégâts)
var tween_couleur: Tween

signal joueur_touche(degats: float)

func déclencher_degats() -> void:
	timer_invincibilite.start()
	# On émet le signal.
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
		# CORRECTION LÉGÈRE : J'ai remis lerp(0,...) car lerp(0,...) n'a pas de sens si on n'utilise pas Time_presse/temps_max
		velocity.y = lerp(0.0, float(Speed_down), Time_presse / temps_max) * delta 
	if Input.is_action_just_pressed("SPACE"):
		Time_presse = 0 

func deplacement (delta):
	if Input.is_action_pressed("SPACE"):
		Time_presse += delta 
		if Time_presse > temps_max : 
			Time_presse = temps_max
		velocity.y = -lerp(0.0, float(Puissance_accoup), Time_presse / temps_max) * delta 
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
		area.set_deferred("monitoring", false)
		area.set_deferred("monitorable", false)
		
		print("Déchet accroché !")

func test_ferrage (delta):
	pass

# --- FONCTION DE FEEDBACK DE DÉGÂTS MODIFIÉE ---
func _on_joueur_touche(degats: float) -> void:
	# 1. Feedback Particules (déjà là)
	if bulles_degats:
		bulles_degats.restart()
		bulles_degats.emitting = true
	
	# 2. Feedback Couleur (AJOUT ICI)
	if sprite:
		# SÉCURITÉ : Si un Tween de couleur tournait déjà (dégâts rapides), on le tue
		if tween_couleur and tween_couleur.is_running():
			tween_couleur.kill()
		
		# On crée un nouveau Tween
		tween_couleur = create_tween()
		
		# ÉTAPE A : On applique immédiatement la couleur rouge (Color.RED)
		sprite.modulate = Color.RED
		
		# ÉTAPE B : On attend 1 seconde (create_timer est parfait ici car il ne bloque pas le code)
		# et après cette seconde, on transitionne doucement vers la couleur normale (Color.WHITE)
		tween_couleur.tween_property(sprite, "modulate", Color.WHITE, 1.0)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_delay(0.1) # Un mini délai optionnel pour que le rouge "claque" bien avant de fondre
			
	print("Le joueur a pris un tick de dégâts : ", degats, " -> Flash rouge !")
