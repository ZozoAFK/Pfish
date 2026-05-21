extends CharacterBody2D

var hamecon : Hamecon = null


@onready var limit_left = $"../Limit_left"
@onready var limit_right = $"../Limit_right"

var switch :bool = true


var direction := Vector2.ZERO 
var SPEED = 2



func _physics_process(delta: float) -> void:
	#poisson en deplacement attente d etre attraper
	if switch:
		#print("attente")
		#mouvement du poisson dans l eau lorsque hamecon dessant
		global_position.x += SPEED
		
		if global_position.x >= limit_right.global_position.x :
			SPEED = -SPEED
			scale.x = -1
			# a changer selon la taille de l image
			position.x = position.x -200
		elif global_position.x <= limit_left.global_position.x:
			SPEED = -SPEED
			scale.x = 1
			# a changer selon la taille de l image
			position.x = position.x +200
	
	# poisson attrapper 
	if not switch:
		if hamecon != null:
			
			look_at(hamecon.global_position)
			#deplacement de l ennemis en ligne droite vers le player 
			var ennemy_to_player = (hamecon.global_position-global_position)
			#ce if permet d eviter qu un enemie reste coller et fait perdre tout c est vie 
			direction = ennemy_to_player.normalized()
			print("look")
			
			if direction != Vector2.ZERO:
				print("o")
				velocity = SPEED * direction
				
			else:
				print("k")
				velocity.x = move_toward(velocity.x,0,SPEED)
				velocity.y = move_toward(velocity.y,0,SPEED)
				
		move_and_slide()



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Hamecon:
		if hamecon == null:
			hamecon = body
			#print("enter")
			switch = false
