extends Node2D

enum State { RONDE, POURSUITE }
var etat_actuel = State.RONDE

var vitesse = 100.0
var point_right = Vector2(500, 500)  # destination en mode ronde
var point_left = Vector2(100, 500)  # destination en mode ronde
var joueur : Node2D = null
var distance_detection = 150.0

#parametre fixe
var switch_ronde = true

func _ready():
	joueur = $"../Hamecon"  # adapte le chemin

func _process(delta):
	match etat_actuel:
		State.RONDE:
			_faire_ronde(delta)
			_verifier_detection()
		State.POURSUITE:
			_poursuivre(delta)
			_verifier_perte()

func _faire_ronde(delta):
	# Mouvement vers la droite
	if switch_ronde :
		var direction = (point_right - position).normalized()
		position += direction * vitesse * delta
		#condition de rotation 
		if position >= point_right:
			switch_ronde=false
	# Mouvement vers la gauche
	if not(switch_ronde) : 
		var direction = (point_left - position).normalized()
		position += direction * vitesse * delta
		#condition de rotation
		if position <= point_left:
			switch_ronde=true

func _poursuivre(delta):
	var direction = (joueur.position - position).normalized()
	position += direction * vitesse * delta

func _verifier_detection():
	if position.distance_to(joueur.position) < distance_detection:
		etat_actuel = State.POURSUITE

func _verifier_perte():
	if position.distance_to(joueur.position) > distance_detection * 2:
		etat_actuel = State.RONDE
