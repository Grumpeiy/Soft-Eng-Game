extends Node2D

const PUZZLE_SCENE = "res://scenes/minigame_map.tscn"
const LESSON_DIALOG = preload("res://scenes/StartLessonDialogtscn.tscn")

var lesson_instance = null
var dialog_canvas = null

func _ready():
	$fade_transition/AnimationPlayer.play("fade_out")
	MenuMusic.stop_music()

func _on_choice_a_pressed() -> void:
	Audio.play_click()
	pass
func _on_choice_b_pressed() -> void:
	Audio.play_click()
	pass
func _on_choice_c_pressed() -> void:
	Audio.play_click()
	pass
func _on_choice_d_pressed() -> void:
	Audio.play_click()
	pass


func _on_puzzle_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("Area entered: ", body.name, " | in group: ", body.is_in_group("player"))
	if body.is_in_group("player"):
		get_tree().change_scene_to_file(PUZZLE_SCENE)


func _on_tutorial_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and lesson_instance == null:
		# Create a CanvasLayer so it renders on top of the 2D world
		dialog_canvas = CanvasLayer.new()
		dialog_canvas.layer = 10
		add_child(dialog_canvas)

		lesson_instance = LESSON_DIALOG.instantiate()
		dialog_canvas.add_child(lesson_instance)

		# Center on screen
		await get_tree().process_frame
		var screen_size = get_viewport().get_visible_rect().size
		lesson_instance.position = (screen_size - lesson_instance.size) / 2


func _on_tutorial_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if lesson_instance != null:
			lesson_instance.queue_free()
			lesson_instance = null
		if dialog_canvas != null:
			dialog_canvas.queue_free()
			dialog_canvas = null
