extends CharacterBody2D
enum State { RONDE, POURSUITE, PAUSE }
var etat_actuel = State.RONDE
var joueur : Node2D = null
var player : Player = null
@export var waypoints: Array[Vector2] = []
@export var speed: float = 80.0
@export var ping_pong: bool = false
var _current_wp: int = 0
var _direction: int = 1
var _pause_timer: float = 0.0
const DEGATS: float = 10.0
const PAUSE_DUREE: float = 1.0

func _ready() -> void:
	joueur = $"../Hamecon"
	if joueur == null:
		push_error("Le nœud Hamecon n'a pas été trouvé ! Vérifiez le chemin.")
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
		State.PAUSE:
			_attendre(delta)

func ronde(delta) -> void:
	if waypoints.is_empty():
		return
	var target: Vector2 = waypoints[_current_wp]
	var diff: Vector2 = target - global_position
	if diff.length() < 4.0:
		_advance_waypoint()
		return
	velocity = diff.normalized() * speed
	look_at(waypoints[_current_wp])
	move_and_slide()

func _advance_waypoint() -> void:
	if ping_pong:
		_current_wp += _direction
		if _current_wp >= waypoints.size() or _current_wp < 0:
			_direction *= -1
			_current_wp += _direction * 2
			_current_wp = clamp(_current_wp, 0, waypoints.size() - 1)
	else:
		_current_wp = (_current_wp + 1) % waypoints.size()

func _poursuivre(delta) -> void:
	look_at(joueur.position)
	var direction = (joueur.position - position).normalized()
	position += direction * speed * delta

func _attendre(delta) -> void:
	# Le poisson reste immobile pendant PAUSE_DUREE secondes
	velocity = Vector2.ZERO
	_pause_timer -= delta
	if _pause_timer <= 0.0:
		# Reprend la poursuite si le joueur est toujours dans la zone
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
			# Ne pas interrompre une pause en cours
			if etat_actuel != State.PAUSE:
				etat_actuel = State.RONDE
			player = null

# À connecter au signal de collision entre le poisson et l'hameçon
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body == joueur:
		# Infliger les dégâts à la barre de vie
		var barre_vie = get_tree().get_first_node_in_group("barre_vie")
		if barre_vie:
			barre_vie.collision_instantanee(DEGATS)
		# Déclencher la pause
		etat_actuel = State.PAUSE
		_pause_timer = PAUSE_DUREE
		velocity = Vector2.ZERO
