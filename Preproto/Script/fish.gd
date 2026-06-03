extends CharacterBody2D

enum State { RONDE, POURSUITE, COMBAT }
var etat_actuel = State.RONDE

var joueur : Node2D = null
var player : Player = null

@export var waypoints: Array[Vector2] = []


@export var speed: float = 80.0 # Vitesse en pixels/seconde


@export var ping_pong: bool = false # false = boucle circulaire | true = aller-retour

var _current_wp: int = 0
var _direction: int  = 1   # utilisé seulement en ping-pong

@onready var _sprite: Sprite2D = $Sprite2D




func _ready() -> void:
	joueur = $"../Hamecon" # adapte le chemin
	if waypoints.is_empty():
		push_warning("Fish '" + name + "' : aucun waypoint défini !")
		return
	global_position = waypoints[0]

func _physics_process(delta: float) -> void:
	
	match etat_actuel:
		State.RONDE:
			ronde(delta)
		State.POURSUITE:
			_poursuivre(delta)
		State.COMBAT:
			pass


func ronde (delta)->void:

	if waypoints.is_empty():
		return
	var target: Vector2 = waypoints[_current_wp]
	var diff: Vector2   = target - global_position
	if diff.length() < 4.0:
		_advance_waypoint()
		return
	velocity = diff.normalized() * speed
	look_at(waypoints[_current_wp])
	move_and_slide()
	# Retourne le sprite selon le sens de déplacement
	


func _advance_waypoint() -> void:
	if ping_pong:
		_current_wp += _direction
		if _current_wp >= waypoints.size() or _current_wp < 0:
			_direction *= -1
			_current_wp += _direction * 2
			_current_wp = clamp(_current_wp, 0, waypoints.size() - 1)
	else:
		_current_wp = (_current_wp + 1) % waypoints.size()

func _poursuivre(delta):
	look_at(joueur.position)
	var direction = (joueur.position - position).normalized()
	position += direction * speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("2")
	if body is Player :
		if player == null :
			etat_actuel = State.POURSUITE
			player = body
			print("found")

func _on_area_2d_body_exited(body: Node2D) -> void:
	print("1")
	if body is Player : 
		if player == body :
			etat_actuel = State.RONDE
			player = null
			print("lose")
