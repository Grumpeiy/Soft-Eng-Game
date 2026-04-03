extends Node

signal capitalization_changed

var menu_narration_enabled = false
var narration_gender       = "male"
var narration_player       : AudioStreamPlayer
var sound_cues_enabled     = true
var user_sfx_volume        = 2.0
var current_main_menu_scene = "res://scenes/main_menu.tscn"

var capitalization_enabled := true:
	set(value):
		capitalization_enabled = value
		emit_signal("capitalization_changed")

var difficulty_level    = "normal"
var guided_mode_enabled = true
var tutorial_mode_enabled = false
var has_seen_tutorial     = false

enum AssistanceTier { LOW, MID, HIGH }
var current_assistance_tier       = AssistanceTier.LOW
var consecutive_incorrect_answers = 0
var correct_answers_count         = 0
var incorrect_answers_count       = 0

# ─────────────────────────────────────────────────────────────────────────────
# ASSISTANCE
# ─────────────────────────────────────────────────────────────────────────────
func reset_assistance_tier():
	current_assistance_tier       = AssistanceTier.LOW
	consecutive_incorrect_answers = 0

func record_correct_answer():
	correct_answers_count += 1
	reset_assistance_tier()

func record_incorrect_answer():
	incorrect_answers_count       += 1
	consecutive_incorrect_answers += 1
	if guided_mode_enabled:
		if consecutive_incorrect_answers >= 3:
			current_assistance_tier = AssistanceTier.HIGH
		elif consecutive_incorrect_answers >= 2:
			current_assistance_tier = AssistanceTier.MID

func get_assistance_tier() -> AssistanceTier:
	return current_assistance_tier

# ─────────────────────────────────────────────────────────────────────────────
# SYNC — restore UI state from Settings variables
# ─────────────────────────────────────────────────────────────────────────────
func sync_accessibility(scene):
	if scene.has_node("3 settings/Capitilzation"):
		scene.get_node("3 settings/Capitilzation").button_pressed = capitalization_enabled
	if scene.has_node("3 settings/MenuNarration"):
		scene.get_node("3 settings/MenuNarration").button_pressed = menu_narration_enabled
	if scene.has_node("Sensory Settings/SoundCues"):
		scene.get_node("Sensory Settings/SoundCues").button_pressed = sound_cues_enabled
	if scene.has_node("VoiceNarration"):
		var gender_option = scene.get_node("VoiceNarration")
		gender_option.select(0 if narration_gender == "male" else 1)
	apply_sound_cues()

func sync_gameplay(scene):
	if scene.has_node("DifficultyOptions"):
		var dd = scene.get_node("DifficultyOptions")
		match difficulty_level:
			"easy":   dd.select(0)
			"normal": dd.select(1)
			"hard":   dd.select(2)
	if scene.has_node("gameplay/guided"):
		scene.get_node("gameplay/guided").button_pressed = guided_mode_enabled
	if scene.has_node("gameplay/tutorial"):
		scene.get_node("gameplay/tutorial").button_pressed = tutorial_mode_enabled

# ─────────────────────────────────────────────────────────────────────────────
# NARRATION — fixed: guard against freed narration_player node
# ─────────────────────────────────────────────────────────────────────────────
func play_narration(button_name: String):
	if not menu_narration_enabled:
		return

	# Guard: narration_player may be null or freed after a scene change
	if narration_player == null or not is_instance_valid(narration_player):
		return

	var path = "res://Sounds/%s/%s.mp3" % [narration_gender, button_name]
	if ResourceLoader.exists(path):
		narration_player.stop()
		narration_player.stream = load(path)
		narration_player.play()
	else:
		print("Missing narration file: ", path)

# ─────────────────────────────────────────────────────────────────────────────
# SOUND CUES
# ─────────────────────────────────────────────────────────────────────────────
func apply_sound_cues():
	if sound_cues_enabled:
		Audio.set_bus_volume("SFX", user_sfx_volume)
	else:
		Audio.set_bus_volume("SFX", 0.0)
