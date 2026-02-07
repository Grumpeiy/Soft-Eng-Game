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
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()
			$NinePatchRect/Text.visible_ratio = 1.0
		else:
			next_script()
		
func next_script():
	currentDialogueID += 1
	if currentDialogueID >= len(dialogue):
		dActive = false
		$NinePatchRect.visible = false
		emit_signal("dialogueFinished")
		return
		
	$NinePatchRect/Name.text = dialogue[currentDialogueID]['Name']
	var current_text = dialogue[currentDialogueID]['Text']
	$NinePatchRect/Text.text = current_text
	
	$NinePatchRect/Text.visible_ratio = 0.0
	
	var duration = current_text.length() * type_speed
	
	if duration > 0:
		$NinePatchRect/AnimationPlayer.speed_scale = 1.0 / duration
	else:
		$AnimationPlayer.speed_scale = 1.0

	$NinePatchRect/AnimationPlayer.play("typewriterfx")
		
	
