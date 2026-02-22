extends CharacterBody2D
class_name Player

@onready var walk: AudioStreamPlayer2D = $walk
@onready var animations = $Animations
var canMove = true

const SPEED = 100
const ACCEL = 1000
const FRICTION = 1200
var current_dir = "down"

func _ready():
	animations.play("front_idle")
	walk.pitch_scale = 0.75
	
	
	var trigger = get_parent().get_node("NPC")
	trigger.dialogueStarted.connect(inDialogue)
	trigger.get_node("Dialogue").dialogueFinished.connect(outOfDialogue) 

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
		if not walk.playing:
			walk.play()
	
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
	var dir = current_dir
	var anim = animations
	
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
		anim.flip_h = false 
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			anim.play("front_idle")
			
	if dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			anim.play("back_idle")

func samplePlayer():
	pass #player identifier, stub
	
func inDialogue():
	print("in dialogue")
	canMove = false	

func outOfDialogue():
	print("out dialogue")
	canMove = true
