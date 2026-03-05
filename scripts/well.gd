extends Node2D

const PUZZLE_SCENE = "res://scenes/minigame_map.tscn"

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
