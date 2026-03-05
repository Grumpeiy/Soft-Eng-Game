extends CharacterBody2D

signal dialogueStarted

const SPEED = 50.0
var inDialogue = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_direction = "down"

func _physics_process(delta: float) -> void:
	if inDialogue:
		velocity = Vector2.ZERO
		move_and_slide()
		play_idle_animation()
		return
	
	var direction = Vector2.ZERO
	
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	velocity = direction * SPEED
	move_and_slide()
	
	update_animation(direction)
	
	# PUSHING PHYSICS
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is RigidBody2D:
			var push_direction = -collision.get_normal()
			var push_force = 30.0

			if collider.linear_velocity.length() < 30.0:
				collider.apply_central_impulse(push_direction * push_force)

func update_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		play_idle_animation()
		return
	
	# determine direction
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			current_direction = "right"
		else:
			current_direction = "left"
	else:
		if direction.y > 0:
			current_direction = "down"
		else:
			current_direction = "up"
	
	play_move_animation()

func play_move_animation():
	match current_direction:
		"down":
			sprite.flip_h = false
			sprite.play("MoveDown")
		
		"left":
			sprite.flip_h = true
			sprite.play("MoveLeft")
		
		"right":
			sprite.flip_h = false
			sprite.play("MoveLeft")
		
		"up":
			sprite.flip_h = false
			sprite.play("MoveUp")

func play_idle_animation():
	match current_direction:
		"down":
			sprite.flip_h = false
			sprite.play("Idle")
		
		"left":
			sprite.flip_h = true
			sprite.play("IdleLeft")
		
		"right":
			sprite.flip_h = false
			sprite.play("IdleLeft")
		
		"up":
			sprite.flip_h = false
			sprite.play("IdleUp")
