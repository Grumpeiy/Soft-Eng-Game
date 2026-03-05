extends Node2D

signal dialogueFinished

const dialogLines : Array[Dictionary] = [
	{"Text": "There was once a thriving farm in [rainbow]Biringan[/rainbow]..."}, # ID 0 -> Starts IntroP2
	{"Text": "With your Grandfather's hardwork, it was sparkled with produce, [wave][color=green]vegetables[/color] and [color=orange]fruits[/color][/wave], left and right!"}, # ID 1 -> KEEPS IntroP2
	{"Text": "It was a [rainbow]place of harmony[/rainbow]. And he always had a blast taking care of his plants."}, # ID 2 -> IntroP3? (Adjust in match block)
	{"Text": "However, a [color=red][shake]terrible[/shake][/color] news had struck his farm.."}, # ID 3
	{"Text": "Biringan encountered its [color=red][shake]driest season[/shake][/color] yet"}, # ID 4
	{"Text": "Your Grandfather's farm was no exception, all of the [color=blue][wave]water[/wave][/color] turned into [color=brown]dust.[/color]"}, # ID 5
	{"Text": "Without water, vegetation can't continue. And soon enough, all the [color=green]plant life[/color] will start to [color=brown][pulse]dry out![/pulse][/color]"}, # ID 6
	{"Text": "You are tasked to find all the [color=blue][wave]water[/wave][/color] in your province and save the [rainbow]Biringan[/rainbow]!"} # ID 7
]

@onready var narration = $Path2D/PathFollow2D/CanvasLayer2/ColorRect/Narration
@onready var path_follow = $Path2D/PathFollow2D
@onready var camera = $Path2D/PathFollow2D/Camera2D
@onready var anim_player = $Animation 

var current_tween : Tween
var currentDialogueID = -1 
var dActive = false 
var type_speed = 0.05
var is_animating = false

func _ready():
	narration.visible = false
	$AnimatedSprite2D2.visible = false
	if anim_player.has_animation("RESET"):
		anim_player.play("RESET")
	
	await get_tree().create_timer(1.0).timeout
	start_intro()

func start_intro():
	if dActive: return
	dActive = true
	
	# 1. Play IntroP1 (Cinematic Borders/Camera Setup)
	# We MUST wait for this to finish, otherwise IntroP2 will be skipped.
	run_animation_safely("IntroP1")
	$AnimationPlayer.play("fadeOut")
	
	# 2. Start Camera movement logic
	camera.enabled = true
	start_camera_movement()
	
	await anim_player.animation_finished
	# 3. Show UI and start the first dialogue (Line 0)
	narration.visible = true
	currentDialogueID = -1
	next_script() # This triggers IntroP2

func start_camera_movement():
	var camera_tween = create_tween()
	camera_tween.set_trans(Tween.TRANS_SINE)
	camera_tween.set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(path_follow, "progress_ratio", 1.0, 10.0)

func _input(event):
	if not dActive: return
	
	if event.is_action_pressed("ui_accept"):
		# Skip typewriter effect
		if current_tween and current_tween.is_running():
			current_tween.kill()
			narration.visible_ratio = 1.0
			return 
		
		# Prevent skipping if the animation is currently playing
		if is_animating:
			return
			
		next_script()
		
func next_script():
	currentDialogueID += 1
	
	if currentDialogueID >= dialogLines.size():
		end_intro()
		return
		
	# --- MANUAL ANIMATION CONTROL ---
	match currentDialogueID:
		0: 
			# Line 0: "Thriving farm" -> Start IntroP2
			pass
		1:
			# Line 1: "Grandfather's hardwork" -> DO NOTHING (Pass)
			# This ensures IntroP2 keeps playing and isn't replaced by IntroP3 yet.
			run_animation_safely("IntroP2")
		2:
			# Line 2: "Place of harmony" -> Start IntroP3
			run_animation_safely("IntroP3")
		3:
			run_animation_safely("IntroP4")
		4:
			run_animation_safely("IntroP5")
		# Add more cases (5, 6, 7) as needed to match your animations
		7:
			run_animation_safely("IntroP6")
		
	
	# --- TEXT LOGIC ---
	var current_text = dialogLines[currentDialogueID]['Text']
	narration.text = current_text
	narration.visible_ratio = 0.0
	
	var duration = current_text.length() * type_speed
	current_tween = create_tween()
	current_tween.tween_property(narration, "visible_ratio", 1.0, duration)

# Helper function to play animation and lock input
func run_animation_safely(anim_name: String):
	if not anim_player.has_animation(anim_name): return
	
	is_animating = true
	anim_player.play(anim_name)
	await anim_player.animation_finished
	is_animating = false

func end_intro():
	dActive = false
	narration.visible = false
	$AnimatedSprite2D2.visible = true
	await iris_wipe_close($AnimatedSprite2D2, 3.0)
	dialogueFinished.emit()
	
func iris_wipe_close(subject: Node2D, duration: float = 1.5):
	var iris = $IrisColorRect
	var viewport_size = get_viewport().get_visible_rect().size

	# correct way to convert world to screen position in 2D
	var screen_pos = get_viewport().get_canvas_transform() * subject.global_position
	var center = screen_pos / viewport_size

	iris.material.set_shader_parameter("center", center)
	iris.material.set_shader_parameter("radius", 1.5)

	var tween = create_tween()
	tween.tween_method(
		func(val): iris.material.set_shader_parameter("radius", val),
		1.5, 0.0, duration
	)
	await tween.finished
