extends CharacterBody2D

@onready var droite_limite =$droite_limite
@onready var droite_bas_limite =$droite_bas_limite
@onready var bas_limite =$bas_limite
@onready var gauche_bas_limite =$gauche_bas_limite
@onready var gauche_limite =$gauche_limite
@onready var recharge_endurance : Timer = $recharge_endurance #temps pour recharger l'endurance  
@onready var temps_du_dash : Timer = $temps_du_dash # duree du dash 
@onready var temps_entre_dash : Timer = $temps_entre_dash # duree entre deux dash different 

var tableau : Array = ["gauche" , "bas_gauche" ,  "bas" , "bas_droite" , "droite"] 
var dure_dash = false  #switch qui limite la duree du dash 
var endurance = max_endurance #dash durant le gameplay
var can_dash = false #switch qui definit si on peut dash ou pas (avec pour timer le temps entre deux dash)
var position_depard 
var direction 
@export var max_endurance = 3 # nombre de dash maximum que le poisson a  
@export var dash_speed = 1000 #vitesse du dash 

enum State { RONDE, POURSUITE, COMBAT }
var etat_actuel = State.COMBAT



var joueur : Node2D = null
var player : Player = null




@export var waypoints: Array[Vector2] = []
@export var speed: float = 80.0 # Vitesse en pixels/seconde
@export var ping_pong: bool = false # false = boucle circulaire | true = aller-retour
var _current_wp: int = 0
var _direction: int  = 1   # utilisé seulement en ping-pong





func _ready() -> void:
	joueur = $"../Hamecon.tscn" # adapte le chemin
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
			print(direction)
			if not(can_dash) :
				begin_dash(delta)
			if can_dash :
				_dash (tableau,position_depard,delta)


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


var acc = 0.5
func _dash (tableau, position_depard, delta):
	var direction_x = position.x
	var direction_y = position.y

	if not(dure_dash):
		temps_entre_dash.start()
		tableau.shuffle()
		temps_du_dash.start()
	dure_dash = true 
	
	if tableau[0] == "gauche" and dure_dash: 
		look_at(Vector2(gauche_limite.position))
		direction = Vector2(gauche_limite.position)
		velocity = lerp(velocity , direction * dash_speed, acc)
	if tableau[0] == "bas_gauche" and dure_dash: 
		look_at(Vector2(gauche_bas_limite.position))
		direction = Vector2(gauche_bas_limite.position)
		velocity = lerp(velocity , direction * dash_speed, acc)
	if tableau[0] == "bas" and dure_dash: 
		look_at(Vector2(bas_limite.position))
		direction = Vector2(bas_limite.position)
		velocity = lerp(velocity , direction * dash_speed, acc)
	if tableau[0] == "bas_droite" and dure_dash: 
		look_at(Vector2(droite_bas_limite.position))
		direction = Vector2(droite_bas_limite.position)
		velocity = lerp(velocity , direction * dash_speed, acc)
	if tableau[0] == "droite" and dure_dash: 
		look_at(Vector2(droite_limite.position))
		direction = Vector2(droite_limite.position)
		velocity = lerp(velocity , direction * dash_speed, acc)

func begin_dash (delta)->bool:
	if(endurance != 0):
		can_dash = true
		position_depard = position
		return true
	else :
		recharge_endurance.start()
		return false


func _on_temps_du_dash_timeout() -> void:
	dure_dash= false


func _on_temps_entre_dash_timeout() -> void:
	can_dash = false


func _on_recharge_endurance_timeout() -> void:
	endurance = max_endurance
