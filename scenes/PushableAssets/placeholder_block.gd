extends Area2D

var is_filled: bool = false
var sfx: AudioStreamPlayer
var sfx_wrong: AudioStreamPlayer

func _ready():
	var err1 = body_entered.connect(_on_body_entered)
	var err2 = body_exited.connect(_on_body_exited)
	print("body_entered connected: ", err1)
	print("body_exited connected: ", err2)

	sfx = AudioStreamPlayer.new()
	sfx.volume_db = 20.0
	sfx.stream = load("res://Sounds/music/softpop.mp3")  # update to your sfx path
	add_child(sfx)
	
	sfx_wrong = AudioStreamPlayer.new()
	sfx_wrong.stream = load("res://Sounds/music/chime.mp3")  # update to your sfx path
	sfx_wrong.volume_db = -5.0
	add_child(sfx_wrong)
	
func _on_body_entered(body):
	if is_filled:
		return
	if not body.has_meta("letter"):
		return
	if not has_meta("expected_letter"):
		return

	var entered_letter = body.get_meta("letter")
	var expected_letter = get_meta("expected_letter")

	print("entered: ", entered_letter, " | expected: ", expected_letter)

	if entered_letter == expected_letter:
		is_filled = true
		body.teleport_to(global_position)
		sfx.play()
		var indicator = get_meta("indicator")
		indicator.play("correct")
	
	# notify the main scene to check win condition
		get_tree().get_root().get_node("minigameMap").check_win()
	else:
		sfx_wrong.play()
		var indicator = get_meta("indicator")
		indicator.play("wrong")
		
func _on_body_exited(body):
	print("body exited: ", body.get_meta("letter") if body.has_meta("letter") else "unknown")
	if is_filled:
		return
	if not body.has_meta("letter"):
		return
	var indicator = get_meta("indicator")
	indicator.play("idle")
