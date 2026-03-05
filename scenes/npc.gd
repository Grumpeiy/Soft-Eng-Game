extends CharacterBody2D
@export var roam_rect: ColorRect

signal dialogueStarted
const speed = 30

var currentState = IDLE
var dir = Vector2.RIGHT
var startPos

var isRoaming = true
var isChatting = false

var sampPlayer
var playerInChatZone = false

var prev_position = Vector2.ZERO

var canInteract = false:
	set(value):
		canInteract = value
		
var interaction_count = 0

enum {
	IDLE,
	newDir,
	MOVE}
	
func _ready():
	randomize()
	startPos = position
	
func _process(delta): #code for NPC animations walking directions
		
	if currentState == 0 or currentState == 1: #charac is 0 when not moving
		$AnimatedSprite2D.play("IDLE") #idle animation will play if charac is not moving (when val is 00
	elif currentState ==  2 and !isChatting:
		if dir.x == -1:
			$AnimatedSprite2D.play("walkWest")
		if dir.x == 1:
			$AnimatedSprite2D.play("walkEast")
		if dir.y == -1:
			$AnimatedSprite2D.play("walkNorth")
		if dir.y == 1:
			$AnimatedSprite2D.play("walkSouth")
		
	if isRoaming: #charac is roaming AND not chatting
		match currentState:
			IDLE:
				pass
			newDir:
				dir = choose([Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]) #chooses val from array that contains direction [n,s,e,w]
			MOVE:
				move(delta) 	 
	if Input.is_action_just_pressed("interact") and playerInChatZone == true:
		print("chatting with NPC")
		isRoaming = false
		isChatting = true
		$AnimatedSprite2D.play("IDLE")
		interaction_count += 1
		
		if interaction_count == 1:
			$Dialogue.start("res://dialogue/sampleDialogueMan.json")
		elif interaction_count == 2:
			$Dialogue.start("res://dialogue/sampleDialogueManSecond.json")
		else:
			$Dialogue.start_random("res://dialogue/sampleDialogueManRandom.json")
		dialogueStarted.emit()

func choose(array):
	array.shuffle() #shuffle godot command
	return array.front()
	
func move(delta):
	if !isChatting:
		velocity = dir * speed
		move_and_slide()
		
		if roam_rect:
				position.x = clamp(position.x, roam_rect.global_position.x, roam_rect.global_position.x + roam_rect.size.x)
				position.y = clamp(position.y, roam_rect.global_position.y, roam_rect.global_position.y + roam_rect.size.y)
				
		if position.distance_to(prev_position) < 0.1:
			currentState = IDLE
			dir = choose([Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN])
func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		print("body enter")
		sampPlayer = body
		playerInChatZone = true 

func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body is Player:
		playerInChatZone = false 
		if isChatting:
			isChatting = false
			isRoaming = true
			$Dialogue.force_stop()

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5,1,1.5])
	currentState = choose([IDLE, newDir, MOVE])  

func _on_dialogue_dialogue_finished() -> void:
	isChatting = false
	isRoaming = true
	emit_signal("dialogueFinished")
