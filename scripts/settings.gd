extends Node

signal capitalization_changed

var menu_narration_enabled = false
var narration_gender = "male"
var narration_player : AudioStreamPlayer
var sound_cues_enabled = true
var current_main_menu_scene = "res://scenes/main_menu.tscn"


var capitalization_enabled := true:
	set(value):
		capitalization_enabled = value
		emit_signal("capitalization_changed")

func sync_accessibility(scene):
	scene.get_node("3 settings/Capitilzation").button_pressed = capitalization_enabled
	scene.get_node("3 settings/MenuNarration").button_pressed = menu_narration_enabled
	
	scene.get_node("Sensory Settings/SoundCues").button_pressed = sound_cues_enabled
	
	var gender_option = scene.get_node("VoiceNarration")
	if narration_gender == "male":
		gender_option.select(0)
	else:
		gender_option.select(1)
	
	apply_sound_cues()

func play_narration(button_name: String):
	if not menu_narration_enabled:
		return
	
	var path = "res://Sounds/%s/%s.mp3" % [narration_gender, button_name]
	
	if ResourceLoader.exists(path):
		narration_player.stop()
		narration_player.stream = load(path)
		narration_player.play()
	else:
		print("Missing file: ", path)

func apply_sound_cues():
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(bus_index, !sound_cues_enabled)
	print("Sound cues: ", "ON" if sound_cues_enabled else "OFF")
