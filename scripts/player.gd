extends CharacterBody2D

const SPEED = 100
const ACCEL = 1000      #max speed (higher = snappier)
const FRICTION = 1200   #higher = more precise stop

var current_dir = "down" # Default to down so it isn't "none" at start

func _ready():
	$Animations.play("front_idle")

func _physics_process(delta):
	player_movement(delta)

func player_movement(delta):
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_vector == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		play_anim(0) 
	else:
		velocity = velocity.move_toward(input_vector * SPEED, ACCEL * delta)
		update_animation_direction(input_vector)
		play_anim(1)
	
	move_and_slide()

func update_animation_direction(input_vector):
	if input_vector.x > 0:
		current_dir = "right"
	elif input_vector.x < 0:
		current_dir = "left"
	elif input_vector.y > 0:
		current_dir = "down"
	elif input_vector.y < 0:
		current_dir = "up"

func play_anim(movement):
	var dir =  current_dir
	var anim = $Animations
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
			
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
			
	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			anim.play("front_idle")
			
	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			anim.play("back_idle")
