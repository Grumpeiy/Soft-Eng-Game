extends CharacterBody2D

@export var roam_rect: ColorRect

signal dialogueStarted
signal dialogueFinished

const speed = 30

var currentState = IDLE
var dir          = Vector2.RIGHT
var startPos
var isRoaming    = true
var isChatting   = false
var sampPlayer
var playerInChatZone = false
var prev_position    = Vector2.ZERO
var canInteract      = false:
	set(value):
		canInteract = value

var interaction_count = 0

enum { IDLE, newDir, MOVE }

# ── Quest marker reference — assigned in _ready ───────────────────────────────
var quest_marker = null

func _ready():
	randomize()
	startPos = position
	# Find the quest marker anywhere in the scene tree
	quest_marker = get_tree().get_root().find_child("quest_marker", true, false)

func _process(delta):
	# Animations
	if currentState == 0 or currentState == 1:
		$AnimatedSprite2D.play("IDLE")
	elif currentState == 2 and !isChatting:
		if dir.x == -1: $AnimatedSprite2D.play("walkWest")
		if dir.x ==  1: $AnimatedSprite2D.play("walkEast")
		if dir.y == -1: $AnimatedSprite2D.play("walkNorth")
		if dir.y ==  1: $AnimatedSprite2D.play("walkSouth")

	if isRoaming:
		match currentState:
			IDLE:   pass
			newDir: dir = choose([Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN])
			MOVE:   move(delta)

	if Input.is_action_just_pressed("interact") and playerInChatZone:
		print("Chatting with NPC, interaction_count: ", interaction_count)
		isRoaming  = false
		isChatting = true
		$AnimatedSprite2D.play("IDLE")
		_start_dialogue_for_step()
		dialogueStarted.emit()

# ─────────────────────────────────────────────────────────────────────────────
# Dialogue selection — one dialogue per quest marker step that involves the NPC
# Steps that involve the NPC: 0, 3, 4, 6
# Steps 1 (wizard), 2 (puzzle), 5 (skeletons) are handled by other scripts
# ─────────────────────────────────────────────────────────────────────────────
func _start_dialogue_for_step():
	var step = 0
	if quest_marker:
		step = quest_marker.current_step

	match step:
		0:
			# First ever interaction — "Where's My Water" begins
			$Dialogue.start("res://dialogue/sampleDialogueMan.json")
		3:
			# Player returns after solving the puzzle — Wizard's Training complete
			$Dialogue.start("res://dialogue/grandpa_after_puzzle.json")
		4:
			# Grandpa gives the Fetching Bones quest
			$Dialogue.start("res://dialogue/grandpa_fetching_bones_start.json")
		6:
			# Player returns after all 3 skeletons — final ending
			$Dialogue.start("res://dialogue/grandpa_final.json")
		_:
			# Fallback idle chatter if player talks to NPC mid-quest
			if interaction_count == 1:
				$Dialogue.start("res://dialogue/sampleDialogueManSecond.json")
			else:
				$Dialogue.start_random("res://dialogue/sampleDialogueManRandom.json")

	interaction_count += 1

# ─────────────────────────────────────────────────────────────────────────────
func choose(array):
	array.shuffle()
	return array.front()

func move(_delta):
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
		sampPlayer       = body
		playerInChatZone = true

func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body is Player:
		playerInChatZone = false
		if isChatting:
			isChatting = false
			isRoaming  = true
			$Dialogue.force_stop()

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5, 1, 1.5])
	currentState = choose([IDLE, newDir, MOVE])

func _on_dialogue_dialogue_finished() -> void:
	isChatting = false
	isRoaming  = true
	emit_signal("dialogueFinished")

	# Advance the quest marker after NPC dialogues at steps 0, 3, 4, 6
	if quest_marker:
		var step = quest_marker.current_step
		if step in [0, 3, 4, 6]:
			quest_marker.advance_step()
