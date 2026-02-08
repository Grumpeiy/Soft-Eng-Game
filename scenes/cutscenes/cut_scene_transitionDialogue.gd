extends Node2D

signal dialogueFinished

const dialogLines : Array[Dictionary] = [
	{"Text": "There was once a thriving farm in [rainbow]Biringan[/rainbow]..."},
	{"Text": "With your Grandfather's hardwork, it was sparkled with produce, [wave][color=green]vegetables[/color] and [color=orange]fruits[/color][/wave], left and right!"},
	{"Text": "It was a [rainbow]place of harmony[/rainbow]. And he always had a blast taking care of his plants."},
	{"Text": "However, a [color=red][shake]terrible[/shake][/color] news had struck his farm.."},
	{"Text": "Biringan encountered its [color=red][shake]driest season[/shake][/color] yet"},
	{"Text": "Your Grandfather's farm was no exception, all of the [color=blue][wave]water[/wave][/color] turned into [color=brown]dust.[/color]"},
	{"Text": "Without water, vegetation can't continue. And soon enough, all the [color=green]plant life[/color] will start to [color=brown][pulse]dry out![/pulse][/color]"},
	{"Text": "You are tasked to find all the [color=blue][wave]water[/wave][/color] in your province and save the [rainbow]Biringan[/rainbow]!"}
]

@onready var narration = $Narration

# We create a variable to hold our active Tween
var current_tween : Tween
var currentDialogueID = 0  
var dActive = false 
var type_speed = 0.05

func _ready():
	narration.visible = false
	await get_tree().create_timer(1.0).timeout
	start_intro()
	
func start_intro():
	if dActive: return
	dActive = true
	narration.visible = true
	currentDialogueID = -1
	next_script()

func _input(event):
	if not dActive: return
	
	if event.is_action_pressed("ui_accept"):
		# CHECK: Is the tween currently running?
		if current_tween and current_tween.is_running():
			# SKIP: Kill the tween and show all text instantly
			current_tween.kill()
			narration.visible_ratio = 1.0
		else:
			# NEXT: Move to the next line
			next_script()
		
func next_script():
	currentDialogueID += 1
	
	if currentDialogueID >= dialogLines.size():
		end_intro()
		return
		
	var current_text = dialogLines[currentDialogueID]['Text']
	narration.text = current_text
	narration.visible_ratio = 0.0
	
	# Calculate how long this specific sentence should take
	var duration = current_text.length() * type_speed
	
	# Create the Tween
	current_tween = create_tween()
	
	# "Tween Property":
	# 1. Who? (narration)
	# 2. What? ("visible_ratio")
	# 3. To Value? (1.0)
	# 4. How long? (duration)
	current_tween.tween_property(narration, "visible_ratio", 1.0, duration)

func end_intro():
	dActive = false
	narration.visible = false
	dialogueFinished.emit()
