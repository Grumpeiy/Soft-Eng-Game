extends Node2D

const ACCESSIBILITY_SCENE = "res://scenes/Options/accessbilitySmallNonCapi.tscn"
const GAMEPLAY_SCENE = "res://scenes/Options/GameplaySmallNonCapi.tscn"
const OTHER_SCENE = "res://scenes/Options/OtherSmallNonCapi.tscn"
const MAIN_MENU_SCENE = "res://scenes/options/MainMenuNonCapiSmall.tscn"

func _ready():
	Settings.narration_player = $NarrationPlayer
	Audio.volume_changed.connect(_on_volume_changed)

	$"AudioSmall/SettingsSmall/Master".value = Audio.master_volume
	$"AudioSmall2/BalanceSmall/Music".value = Audio.music_volume
	$"AudioSmall2/BalanceSmall/SFX".value = Audio.sfx_volume
	$"AudioSmall2/BalanceSmall/Narration".value = Audio.narration_volume
	
func _on_volume_changed(bus_name, value):
	match bus_name:
		"Master":
			$"AudioSmall/SettingsSmall/Master".value = value
		"MUSIC":
			$"AudioSmall2/BalanceSmall/Music".value = value
		"Narration":
			$"AudioSmall2/BalanceSmall/Narration".value = value
		"SFX":
			$"AudioSmall2/BalanceSmall/SFX".value = value

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
