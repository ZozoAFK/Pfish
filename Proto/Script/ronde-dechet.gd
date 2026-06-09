extends CharacterBody2D

@export var waypoints: Array[Vector2] = []
@export var speed: float = 80.0
@export var ping_pong: bool = false

var _current_wp: int = 0
var _direction: int = 1

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("dechet")  # ← le joueur détecte déjà ce groupe
	if waypoints.is_empty():
		push_warning("Déchet '" + name + "' : aucun waypoint défini !")
		return
	global_position = waypoints[0]

func _physics_process(delta: float) -> void:
	if waypoints.is_empty():
		return
	var target: Vector2 = waypoints[_current_wp]
	var diff: Vector2   = target - global_position
	if diff.length() < 4.0:
		_advance_waypoint()
		return
	velocity = diff.normalized() * speed
	move_and_slide()
	if _sprite:
		if velocity.x > 0.01:
			_sprite.flip_h = false
		elif velocity.x < -0.01:
			_sprite.flip_h = true

func _advance_waypoint() -> void:
	if ping_pong:
		_current_wp += _direction
		if _current_wp >= waypoints.size() or _current_wp < 0:
			_direction *= -1
			_current_wp += _direction * 2
			_current_wp = clamp(_current_wp, 0, waypoints.size() - 1)
	else:
		_current_wp = (_current_wp + 1) % waypoints.size()
