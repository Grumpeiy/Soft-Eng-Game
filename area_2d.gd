extends Area2D

var is_filled: bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if is_filled:
		return

	if not body.has_meta("letter"):
		return

	if not has_meta("expected_letter"):
		print("ERROR: expected_letter meta is missing!")
		return

	var entered_letter = body.get_meta("letter")
	var expected_letter = get_meta("expected_letter")

	print("entered: ", entered_letter, " | expected: ", expected_letter)

	if entered_letter == expected_letter:
		is_filled = true

	# call snap_to instead of setting position directly
	body.snap_to(global_position)

	await get_tree().process_frame

	body.freeze = true
	body.get_node("CollisionShape2D").disabled = true

	var indicator = get_meta("indicator")
	indicator.play("correct")
	
func _on_body_exited(body):
	print("body exited: ", body.get_meta("letter") if body.has_meta("letter") else "unknown")
	if is_filled:
		return
	if not body.has_meta("letter"):
		return
	var indicator = get_meta("indicator")
	indicator.play("idle")
