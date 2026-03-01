extends Node2D

const ACCESSIBILITY_SCENE = "res://scenes/Options/accessbilityLargeNonCapi.tscn"
const GAMEPLAY_SCENE = "res://scenes/Options/GameplayLargeNonCapi.tscn"
const OTHER_SCENE = "res://scenes/Options/OtherLargeNonCapi.tscn"
const MAIN_MENU_SCENE = "res://scenes/options/MainMenuNonCapiLarge.tscn"

func _ready():
	Settings.narration_player = $NarrationPlayer
	Audio.volume_changed.connect(_on_volume_changed)

	$"Audio Settings 1/Audio Settings/Master".value = Audio.master_volume
	$"Audio Settings 2/Audio balance/Music".value = Audio.music_volume
	$"Audio Settings 2/Audio balance/SFX".value = Audio.sfx_volume
	$"Audio Settings 2/Audio balance/Narration".value = Audio.narration_volume
	
func _on_volume_changed(bus_name, value):
	match bus_name:
		"Master":
			$"Audio Settings 1/Audio Settings/Master".value = value
		"MUSIC":
			$"Audio Settings 2/Audio balance/Music".value = value
		"SFX":
			$"Audio Settings 2/Audio balance/SFX".value = value
		"Narration":
			$"Audio Settings 2/Audio balance/Narration".value = value

func change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)

func _on_accessibility_pressed() -> void:
	Audio.play_click()
	change_scene(ACCESSIBILITY_SCENE)

func _on_gameplay_pressed() -> void:
	Audio.play_click()
	change_scene(GAMEPLAY_SCENE)

func _on_other_pressed() -> void:
	Audio.play_click()
	change_scene(OTHER_SCENE)

func _on_back_pressed() -> void:
	Audio.play_click()
	change_scene(MAIN_MENU_SCENE)

func _on_sfx_value_changed(value: float) -> void:
	Audio.set_bus_volume("SFX", value)


func _on_master_value_changed(value: float) -> void:
	Audio.set_bus_volume("Master", value)


func _on_music_value_changed(value: float) -> void:
	Audio.set_bus_volume("MUSIC", value)
	
func _on_narration_value_changed(value: float) -> void:
	Audio.set_bus_volume("Narration", value)

func _on_accessibility_mouse_entered() -> void:
	Settings.play_narration("Accessibility")

func _on_audio_mouse_entered() -> void:
	Settings.play_narration("Audio")

func _on_gameplay_mouse_entered() -> void:
	Settings.play_narration("Gameplay")

func _on_other_mouse_entered() -> void:
	Settings.play_narration("Other")

func _on_back_mouse_entered() -> void:
	Settings.play_narration("Back")

func _on_master_mouse_entered() -> void:
	Settings.play_narration("Volume")

func _on_music_mouse_entered() -> void:
	Settings.play_narration("Music")

func _on_narration_mouse_entered() -> void:
	Settings.play_narration("Narration")

func _on_sfx_mouse_entered() -> void:
	Settings.play_narration("SFX")
