extends Control
signal dialogueFinished
@export_file("*.json") var d_file
var dialogue = [] 
var currentDialogueID = 0
var dActive = false
var type_speed = 0.05

func _ready():
	$NinePatchRect.visible = false
	$ColorRect/SpriteFrontNPC.visible = false
	$ColorRect.visible = false
	$ColorRect/SpriteFrontNPC.visible = false
	$ColorRect/PLAYER1x1.visible = false
	
func start(file_path: String = "res://dialogue/sampleDialogueMan.json"):
	if dActive:
		return
	dActive = true
	$NinePatchRect.visible = true
	$ColorRect/SpriteFrontNPC.visible = true
	$ColorRect.visible = true
	dialogue = load_dialogue(file_path)
	currentDialogueID = -1
	next_script()

func start_random(file_path: String):
	if dActive:
		return
	dActive = true
	$NinePatchRect.visible = true
	$ColorRect/SpriteFrontNPC.visible = true
	$ColorRect.visible = true
	var all_dialogues = load_dialogue(file_path)
	dialogue = all_dialogues[randi() % all_dialogues.size()]
	currentDialogueID = -1
	next_script()

func load_dialogue(file_path: String):
	if not FileAccess.file_exists(file_path):
		print("ERROR: File not found: ", file_path)
		return []
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("ERROR: Could not open file: ", file_path)
		return []
	var content = JSON.parse_string(file.get_as_text())
	if content == null:
		print("ERROR: Could not parse JSON: ", file_path)
		return []
	return content

func _input(event):
	if !dActive:
		return
	if event.is_action_pressed("ui_accept"):
		if $NinePatchRect/AnimationPlayer.is_playing():
			$NinePatchRect/AnimationPlayer.stop()
			$NinePatchRect/Text.visible_ratio = 1.0
			return
		next_script()

func next_script():
	currentDialogueID += 1
	if currentDialogueID >= len(dialogue):
		dActive = false
		$NinePatchRect.visible = false
		$ColorRect/SpriteFrontNPC.visible = false
		$ColorRect.visible = false
		emit_signal("dialogueFinished")
		return
	var portrait = dialogue[currentDialogueID].get("Portrait", "")
	if portrait == "Grandpa":
		$ColorRect/SpriteFrontNPC.visible = true
		$ColorRect/PLAYER1x1.visible = false
	elif portrait == "You":
		$ColorRect/SpriteFrontNPC.visible = false
		$ColorRect/PLAYER1x1.visible = true
		
	$NinePatchRect/Name.text = dialogue[currentDialogueID]['Name']
	var current_text = dialogue[currentDialogueID]['Text']
	$NinePatchRect/Text.text = current_text

	$NinePatchRect/Text.visible_ratio = 0.0

	var duration = current_text.length() * type_speed

	if duration > 0:
		$NinePatchRect/AnimationPlayer.speed_scale = 1.0 / duration
	else:
		$NinePatchRect/AnimationPlayer.speed_scale = 1.0

	$NinePatchRect/AnimationPlayer.play("typewriterfx")
