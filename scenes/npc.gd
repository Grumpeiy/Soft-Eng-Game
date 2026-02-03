extends CharacterBody2D

signal dialogueStarted
const speed = 30

var currentState = IDLE
var dir = Vector2.RIGHT
var startPos

var isRoaming = true
var isChatting = false

var sampPlayer
var playerInChatZone = false

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
		$Dialogue.start()
		isRoaming = false
		isChatting = true
		$AnimatedSprite2D.play("IDLE")
		dialogueStarted.emit()

func choose(array):
	array.shuffle() #shuffle godot command
	return array.front()
	
func move(delta): #actual movement of charac
	if !isChatting:
		position += dir * speed * delta

func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("sampPlayer"):
		sampPlayer = body
		playerInChatZone = true 

func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("sampPlayer"):
		playerInChatZone = false 

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5,1,1.5])
	currentState = choose([IDLE, newDir, MOVE])  

func _on_dialogue_dialogue_finished() -> void:
	isChatting = false
	isRoaming = true
	emit_signal("dialogueFinished")
