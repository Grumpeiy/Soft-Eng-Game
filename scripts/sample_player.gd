extends CharacterBody2D
const SPEED = 70.0
@onready var anim = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	# 1. Get the input direction for all 4 directions.
	# get_vector returns a normalized vector (length of 1), so diagonal movement isn't faster.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Apply movement.
	if direction:
		velocity = direction * SPEED
		if direction.x > 0:
			anim.play("MoveRight")
				
		elif direction.x < 0:
			anim.play("MoveLeft")
		elif direction.y > 0:
			anim.play("MoveDown")
		elif direction.y < 0:
			anim.play("MoveUp")
	else:
		# This brings the character to a smooth stop (friction).
		# You can adjust the last parameter (SPEED) to change how strictly it stops.
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		anim.stop()
		
	move_and_slide()
