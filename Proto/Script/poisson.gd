extends Node2D

enum State { RONDE, POURSUITE }
var etat_actuel = State.RONDE

@export var vitesse = 100.0
var point_right = Vector2(500, 500)  # destination en mode ronde
var point_left = Vector2(100, 500)  # destination en mode ronde
var distance_detection = 150.0

#parametre fixe
var switch_ronde = true
var joueur : Node2D = null
var player : Player = null

func _ready():
	joueur = $"../Hamecon"  # adapte le chemin

func _process(delta):
	match etat_actuel:
		State.RONDE:
			_faire_ronde(delta)
		State.POURSUITE:
			_poursuivre(delta)

			
	print(etat_actuel)

func _faire_ronde(delta):
	print("rond")
	# Mouvement vers la droite
	if switch_ronde :
		look_at(point_right)
		var direction = (point_right - position).normalized()
		position += direction * vitesse * delta
		#condition de rotation 
		if position >= point_right:
			switch_ronde=false
	# Mouvement vers la gauche
	if not(switch_ronde) : 
		look_at(point_left)
		var direction = (point_left - position).normalized()
		position += direction * vitesse * delta
		#condition de rotation
		if position <= point_left:
			switch_ronde=true
		
func _poursuivre(delta):
	look_at(joueur.position)
	var direction = (joueur.position - position).normalized()
	position += direction * vitesse * delta
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player :
		if player == null :
			etat_actuel = State.POURSUITE
			player = body
			print("found")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player : 
		if player == body :
			etat_actuel = State.RONDE
			player = null
			
			print("lose")
