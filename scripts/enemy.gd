extends CharacterBody2D

var character_name : String = "Skeleton"
var lvl : int = 49
var speed = 50
var player_chase = false
var player = null

func _physics_process(delta):
	if player_chase and player:
		var direction = (player.position - position).normalized()
		var collision = move_and_collide(direction * speed * delta)
		
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
			
		$AnimatedSprite2D.play("walk")
		
		if collision:
			var body = collision.get_collider()
			if body.is_in_group("player"):
				player_chase = false
				#event_handler.battle_started.emit(character_name, lvl)
				event_handler.battle_started.emit(self, character_name, lvl)
				
	else:
		$AnimatedSprite2D.play("idle")

func _on_detection_area_body_entered(body):
	#START CHASING THE PLAYER
	if body.is_in_group("player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		player_chase = false
