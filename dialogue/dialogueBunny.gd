extends Control

signal dialogueFinished
@export_file("*.json") var d_file

var dialogue = [] 
var currentDialogueID = 0 #identifier for current dialogue
var dActive = false

var type_speed = 0.05

func _ready():
	$NinePatchRect.visible = false
	
func start():
	if dActive:
		return
	dActive = true
	$NinePatchRect.visible = true
	dialogue = load_dialogue()
	currentDialogueID = -1
	next_script()
	
func load_dialogue():
	var file = FileAccess.open("res://dialogue/sampleDialogueMan.json", FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content

func _input(event):
	if !dActive:
		return
	if event.is_action_pressed("ui_accept"):
		next_script()
		
func next_script():
	currentDialogueID += 1
	if currentDialogueID >= len(dialogue):
		dActive = false
		$NinePatchRect.visible = false
		emit_signal("dialogueFinished")
		return
		
		# 1. Update content
	$NinePatchRect/Name.text = dialogue[currentDialogueID]['Name']
	var current_text = dialogue[currentDialogueID]['Text']
	$NinePatchRect/Text.text = current_text
	
	# 2. Reset visibility so it starts invisible
	$NinePatchRect/Text.visible_ratio = 0.0
	
	# 3. Calculate Duration based on text length
	var duration = current_text.length() * type_speed
	
	# 4. Set Animation Speed
	# Assuming your animation in the editor is exactly 1.0 second long
	if duration > 0:
		$NinePatchRect/AnimationPlayer.speed_scale = 1.0 / duration
	else:
		$AnimationPlayer.speed_scale = 1.0
	
	# 5. Play!
	$NinePatchRect/AnimationPlayer.play("typewriterfx")
		
	
