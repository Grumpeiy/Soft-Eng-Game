extends CharacterBody2D

signal dialogueStarted

const SPEED = 50.0
var inDialogue = false

func _physics_process(delta: float) -> void:
	if inDialogue:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var direction = Vector2.ZERO
	
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	velocity = direction * SPEED
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is RigidBody2D:
			var push_direction = -collision.get_normal()
			var push_force = 30.0
			# Only push if the object isn't already moving fast
			if collider.linear_velocity.length() < 30.0:
				collider.apply_central_impulse(push_direction * push_force)
			# Only push if the object isn't already moving fast
		
