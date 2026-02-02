extends Control

@export_file("*.json") var d_file

var dialogue = [] 
var currentDialogueID = 0 #identifier for current dialogue

func _ready():
	start()
	
func start():
	dialogue = load_dialogue()
	currentDialogueID = -1
	next_script()
	
func load_dialogue():
	var file = FileAccess.open("res://dialogue/sampleDialogueMan.json", FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content

func _input(event):
	if event.is_action_pressed("ui_accept"):
		next_script()
		
func next_script():
	currentDialogueID += 1
	if currentDialogueID >= len(dialogue):
		return
		
	$NinePatchRect/Name.text = dialogue[currentDialogueID]['Name']
	$NinePatchRect/Text.text = dialogue[currentDialogueID]['Text']
	
