extends CharacterBody2D


signal joueur_touche(degats: float)
@onready var detection : Area2D = $Area2D
@onready var sprite = $Sprite2D

enum State { RONDE, POURSUITE, PAUSE }
var etat_actuel = State.RONDE
var joueur : Node2D = null
var player : Player = null
var flip_direction = 1 
var _last_flip = 1  # variable de classe

@export var waypoints: Array[Vector2] = []
@export var speed: float = 80.0
@export var position_start : Vector2

var ping_pong: bool = false

var _current_wp: int = 0
var _direction: int = 1
var _pause_timer: float = 0.0
const DEGATS: float = 10.0
const PAUSE_DUREE: float = 1.0

func _ready() -> void:
	joueur = $"../Hamecon"
	if joueur == null:
		push_error("Hamecon introuvable !")
	else:
		# --- AJOUT : Connecte le signal du poisson à la fonction de dégâts de l'hameçon ---
		if joueur.has_method("_on_joueur_touche"):
			joueur_touche.connect(joueur._on_joueur_touche)
			print("✅ Signal de dégâts du poisson connecté à l'Hameçon")

	await get_tree().process_frame
	var barre_hp = get_tree().get_first_node_in_group("barre_vie")
	if barre_hp:
		# On garde aussi ta connexion à la barre d'HP
		joueur_touche.connect(barre_hp._on_hamecon_joueur_touche)
		print("✅ Signal connecté à BarreHP")
	else:
		push_error("❌ BarreHP introuvable !")

	if waypoints.is_empty():
		push_warning("Fish '" + name + "' : aucun waypoint défini !")
		return
	global_position = position_start

func _physics_process(delta: float) -> void:
	match etat_actuel:
		State.RONDE:
			_ronde(delta)
		State.POURSUITE:
			_poursuivre(delta)
		State.PAUSE:
			_attendre(delta)


func _ronde(delta) -> void:
	if waypoints.is_empty():
		return
	var target: Vector2 = waypoints[_current_wp]
	var diff: Vector2 = target - global_position
	if diff.length() < 4.0:
		_advance_waypoint()
		return

	
	velocity = diff.normalized() * speed
	look_at(waypoints[_current_wp])
	detection.look_at(waypoints[_current_wp])
	move_and_slide()



func _advance_waypoint() -> void:
	var precedent = waypoints[_current_wp]
	
	if ping_pong:
		_current_wp += _direction
		if _current_wp >= waypoints.size() or _current_wp < 0:
			_direction *= -1
			_current_wp += _direction * 2
			_current_wp = clamp(_current_wp, 0, waypoints.size() - 1)
	else:
		_current_wp = (_current_wp + 1) % waypoints.size()
	
	var prochain = waypoints[_current_wp]
	
	if prochain.x < precedent.x:
		flip_direction = -1
	else:
		flip_direction = 1
	
	# applique le scale seulement si la direction a changé
	if flip_direction != _last_flip:
		scale.x *= -1
		_last_flip = flip_direction

func _poursuivre(delta) -> void:
	look_at(joueur.position)
	var direction = (joueur.position - position).normalized()
	position += direction * speed * delta

func _attendre(delta) -> void:
	velocity = Vector2.ZERO
	_pause_timer -= delta
	if _pause_timer <= 0.0:
		if player != null:
			etat_actuel = State.POURSUITE
		else:
			etat_actuel = State.RONDE

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		if player == null:
			etat_actuel = State.POURSUITE
			player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		if player == body:
			if etat_actuel != State.PAUSE:
				etat_actuel = State.RONDE
			player = null

func _on_hitbox_body_entered(body: Node2D) -> void:
	print("Hitbox touché par : ", body.name)
	if body == joueur:
		print(" Dégâts : ", DEGATS)
		emit_signal("joueur_touche", DEGATS)
		etat_actuel = State.PAUSE
		_pause_timer = PAUSE_DUREE
		velocity = Vector2.ZERO


func _on_joueur_touche(degats: float) -> void:
	pass # Replace with function body.
