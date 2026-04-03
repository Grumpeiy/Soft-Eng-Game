extends Node2D

const PUZZLE_SCENE  = "res://scenes/minigame_map.tscn"
const LESSON_DIALOG = preload("res://scenes/StartLessonDialogtscn.tscn")

var lesson_instance = null
var dialog_canvas   = null

var _position_save_timer : float = 0.0
const POSITION_SAVE_INTERVAL : float = 5.0

@onready var player_node = $player

func _ready():
	$fade_transition/AnimationPlayer.play("fade_out")
	MenuMusic.stop_music()
	if player_node:
		var saved_pos = PlayerData.get_last_position(Vector2.ZERO)
		if saved_pos != Vector2.ZERO:
			player_node.global_position = saved_pos
			
	# Check if the quest menu sent teleport coordinates
	var tp_x = PlayerData.get_save_value("teleport_x", null)
	var tp_y = PlayerData.get_save_value("teleport_y", null)
	
	if tp_x != null and tp_y != null:
		# Assuming your player node is named "Player". Change this path if needed!
		$player.global_position = Vector2(tp_x, tp_y)
		
		# Clear the teleport data so normal entry into the Well doesn't trigger this
		PlayerData.set_save_value("teleport_x", null)
		PlayerData.set_save_value("teleport_y", null)

func _process(delta):
	if player_node:
		_position_save_timer += delta
		if _position_save_timer >= POSITION_SAVE_INTERVAL:
			_position_save_timer = 0.0
			PlayerData.save_position(player_node.global_position)

func _on_choice_a_pressed() -> void:
	Audio.play_click()
func _on_choice_b_pressed() -> void:
	Audio.play_click()
func _on_choice_c_pressed() -> void:
	Audio.play_click()
func _on_choice_d_pressed() -> void:
	Audio.play_click()

# ─────────────────────────────────────────────────────────────────────────────
# PUZZLE ENTRANCE
# Blocked permanently once quest 1 (Where's My Water) is completed
# ─────────────────────────────────────────────────────────────────────────────
func _on_puzzle_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if not body.is_in_group("player"):
		return

	if PlayerData.get_save_value("quest_1_completed", false):
		print("Well: puzzle already completed, entrance blocked")
		return

	PlayerData.save_position(body.global_position)
	get_tree().call_deferred("change_scene_to_file", PUZZLE_SCENE)  # ← fixed

# ─────────────────────────────────────────────────────────────────────────────
# TUTORIAL / LESSON AREA
# ─────────────────────────────────────────────────────────────────────────────
func _on_tutorial_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and lesson_instance == null:
		dialog_canvas       = CanvasLayer.new()
		dialog_canvas.layer = 10
		add_child(dialog_canvas)
		lesson_instance = LESSON_DIALOG.instantiate()
		dialog_canvas.add_child(lesson_instance)
		await get_tree().process_frame
		var screen_size          = get_viewport().get_visible_rect().size
		lesson_instance.position = (screen_size - lesson_instance.size) / 2

func _on_tutorial_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if lesson_instance != null:
			lesson_instance.queue_free()
			lesson_instance = null
		if dialog_canvas != null:
			dialog_canvas.queue_free()
			dialog_canvas = null
