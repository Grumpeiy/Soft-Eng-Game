extends Control

signal dialogueFinished
@export_file("*.json") var d_file

var dialogue = [] 
var currentDialogueID = 0 #identifier for current dialogue
var dActive = false

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
		
	$NinePatchRect/Name.text = dialogue[currentDialogueID]['Name']
	$NinePatchRect/Text.text = dialogue[currentDialogueID]['Text']
	
