extends Node2D

enum State { RONDE, POURSUITE, COMBAT }
var etat_actuel = State.RONDE

@export var vitesse = 100.0
@export var point_1 = Vector2(500, 500)  # destination en mode ronde
@export var point_2 = Vector2(100, 500)  # destination en mode ronde

#variable dash
@onready var droite_limite =$Droite
@onready var droite_bas_limite =$Droite_Bas
@onready var bas_limite =$Bas
@onready var gauche_bas_limite =$Gauche_Bas
@onready var gauche_limite =$Gauche

@onready var recharge_endurance : Timer = $Recharge_endurance #temps pour recharger l'endurance  
@onready var temps_du_dash : Timer = $Temps_du_dash # duree du dash 
@onready var temps_entre_dash : Timer = $Temps_entre_dash # duree entre deux dash different 
var tableau : Array = ["gauche" , "bas_gauche" ,  "bas" , "bas_droite" , "droite"] 
var dure_dash = false  #switch qui limite la duree du dash 
var endurance = max_endurance #dash durant le gameplay
var can_dash = false #switch qui definit si on peut dash ou pas (avec pour timer le temps entre deux dash)
var position_depard 
@export var max_endurance = 3 # nombre de dash maximum que le poisson a  
@export var dash_speed = 300 #vitesse du dash 
@export var time_min = 0 #temps minimum entre deux dash 
@export var time_max = 5 #temps maximum entre deux dash
@export var time_endurance = 5 #temps pour recupere l'endurance lorsqu on n en a plus 
@export var time_dash = 5 #durée d'un dash 

#parametre fixe
var switch_ronde = true
var joueur : Node2D = null
var player : Player = null



func _ready():
	joueur = $"../Hamecon"  # adapte le chemin

func _process(delta):
	print(position)
	match etat_actuel:
		State.RONDE:
			_faire_ronde(delta)
		State.POURSUITE:
			_poursuivre(delta)
		State.COMBAT:

			if not(can_dash) :
				begin_dash(delta)
			if can_dash :
				_dash (tableau,position_depard,delta)
			


func _faire_ronde(delta):
	# Mouvement vers la droite
	if switch_ronde :
		look_at(point_1)
		var direction = (point_1 - position).normalized()
		position +=direction * vitesse * delta
		#condition de rotation 
		if position >= point_1:
			switch_ronde=false
			
	# Mouvement vers la gauche
	if not(switch_ronde) : 
		look_at(point_2)
		var direction = (point_2 - position).normalized()
		position += direction * vitesse * delta
		#condition de rotation
		if position <= point_2:
			switch_ronde=true

func _poursuivre(delta):
	look_at(joueur.position)
	var direction = (joueur.position - position).normalized()
	position += direction * vitesse * delta

#hamecon entre de l'AREA 
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player :
		if player == null :
			etat_actuel = State.POURSUITE
			player = body
			print("found")
#hamecon sort de l'AREA 
func _on_area_2d_body_exited(body: Node2D) -> void:
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
		position = position.move_toward(gauche_limite.position, dash_speed * acc*delta)
	if tableau[0] == "bas_gauche" and dure_dash: 
		look_at(Vector2(gauche_bas_limite.position))
		position = position.move_toward(gauche_bas_limite  .position, dash_speed * acc * delta)
	if tableau[0] == "bas" and dure_dash: 
		look_at(Vector2(bas_limite.position))
		position = position.move_toward(bas_limite.position, dash_speed * acc * delta)
	if tableau[0] == "bas_droite" and dure_dash: 
		look_at(Vector2(droite_limite.position))
		position = position.move_toward(droite_limite.position, dash_speed * acc * delta)
	if tableau[0] == "droite" and dure_dash: 
		look_at(Vector2(droite_bas_limite.position))
		position = position.move_toward(droite_bas_limite.position, dash_speed * acc * delta)



func begin_dash (delta)->bool:
	if(endurance != 0):
		can_dash = true
		position_depard = position
		return true
	else :
		recharge_endurance.start(time_endurance)
		return false
	


func _on_recharge_endurance_timeout() -> void:
	endurance = max_endurance

func _on_temps_du_dash_timeout() -> void:
	dure_dash= false
	
func _on_temps_entre_dash_timeout(delta : float) -> void:
	can_dash = false
