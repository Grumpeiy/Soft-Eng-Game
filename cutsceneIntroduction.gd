extends Control

signal dialogueFinished
@export_file("*.json") var d_file

# Point this to your "cutSceneTransition/AnimationPlayer" in the Inspector
# @export var cutscene_anim_player: AnimationPlayer 

var dialogue = [] 
var currentDialogueID = 0
#var dActive = false
var type_speed = 0.05

func _ready():
	$Narration.visible = false
	
	# Start the theatrical borders first!
#	if cutscene_anim_player:
#		cutscene_anim_player.play("blackBorderTOP") # Use your actual animation name
	
	await get_tree().create_timer(1.5).timeout
	start_intro()

func start_intro():
#	if dActive: return
#	dActive = true
	$ColorRect.visible = true
	$narration.visible = true
	
	dialogue = load_dialogue()
	currentDialogueID = -1
	next_script()

func load_dialogue():
	var file = FileAccess.open("res://dialogue/dialogueIntroduction.json", FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content

func _input(event):
#	if !dActive: return
	
	if event.is_action_pressed("ui_accept"):
		# We check if the typewriter animation is playing 
		# without stopping the theatrical borders
		#if cutscene_anim_player.is_playing() and cutscene_anim_player.current_animation == "typewriterfx":
		#	cutscene_anim_player.stop()
		$narration.visible_ratio = 1.0
	else:
		next_script()

func next_script():
	currentDialogueID += 1
	
	if currentDialogueID >= dialogue.size():
		end_intro()
		return
		
	var current_text = dialogue[currentDialogueID]['Text']
	$narration.text = current_text
	$narration.visible_ratio = 0.0
	
	var duration = current_text.length() * type_speed
	
	#if duration > 0:
		# We use the AnimationPlayer from your cutSceneTransition node
#		cutscene_anim_player.speed_scale = 1.0 / duration
#		cutscene_anim_player.play("typewriterfx")
	#else:
		#$narration.visible_ratio = 1.0

func end_intro():

#	dActive = false
	$ColorRect.visible = false
	$narration.visible = false
	emit_signal("dialogueFinished")
