extends Node2D

const ACCESSIBILITY_SCENE = "res://scenes/Options/accessbility.tscn"
const GAMEPLAY_SCENE      = "res://scenes/Options/Gameplay.tscn"
const OTHER_SCENE         = "res://scenes/Options/Other.tscn"
const MAIN_MENU_SCENE     = "res://scenes/options/main_menu.tscn"

@onready var master_slider    = $"Audio Settings 1/Audio Settings/Master"
@onready var music_slider     = $"Audio Settings 2/Audio balance/Music"
@onready var sfx_slider       = $"Audio Settings 2/Audio balance/SFX"
@onready var narration_slider = $"Audio Settings 2/Audio balance/Narration"

func _ready():
	Settings.narration_player = $NarrationPlayer

	# Restore saved audio volumes
	master_slider.value    = Audio.master_volume
	music_slider.value     = Audio.music_volume
	sfx_slider.value       = Audio.sfx_volume
	narration_slider.value = Audio.narration_volume

	Audio.volume_changed.connect(_on_volume_changed)

func _on_volume_changed(bus_name, value):
	match bus_name:
		"Master":    master_slider.value    = value
		"MUSIC":     music_slider.value     = value
		"SFX":       sfx_slider.value       = value
		"Narration": narration_slider.value = value

func change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)

# ── Volume sliders — save on every change ────────────────────────────────────
func _on_master_value_changed(value: float) -> void:
	Audio.set_bus_volume("Master", value)
	PlayerData.save_settings()

func _on_music_value_changed(value: float) -> void:
	Audio.set_bus_volume("MUSIC", value)
	PlayerData.save_settings()

func _on_sfx_value_changed(value: float) -> void:
	Audio.set_bus_volume("SFX", value)
	PlayerData.save_settings()

func _on_narration_value_changed(value: float) -> void:
	Audio.set_bus_volume("Narration", value)
	PlayerData.save_settings()

# ── Navigation ────────────────────────────────────────────────────────────────
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

# ── Narration ─────────────────────────────────────────────────────────────────
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
