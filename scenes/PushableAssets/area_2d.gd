extends Area2D

var is_filled: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if is_filled:
		return

	if not body.has_meta("letter"):
		return

	if not has_meta("expected_letter"):
		print("ERROR: expected_letter meta is missing on this placeholder!")
		return

	var entered_letter = body.get_meta("letter")
	var expected_letter = get_meta("expected_letter")

	print("entered: ", entered_letter, " | expected: ", expected_letter)

	if entered_letter == expected_letter:
		is_filled = true
		body.position = position
		body.freeze = true
		var indicator = get_meta("indicator")
		indicator.play("correct")
	else:
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
