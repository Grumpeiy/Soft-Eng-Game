extends CanvasLayer

func _ready() -> void:
	visible = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT
	process_mode = Node.PROCESS_MODE_PAUSABLE
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		pause_or_unpause()

func pause_or_unpause():
	if get_tree().paused == true:
		$".".hide()
		get_tree().paused = false
	elif get_tree().paused == false:
		$".".hide() 
		get_tree().paused = true
