extends AudioStreamPlayer

const MENU_MUSIC = preload("res://Sounds/music/MenuMusic.mp3")

func _ready():
	bus = "MUSIC"

func play_music_level():
	if stream == MENU_MUSIC and playing:
		return

	stream = MENU_MUSIC
	volume_db = -12
	play()

func stop_music():
	stop()

func play_FX(fx_stream: AudioStream, volume := 0.0):
	var fx_player = AudioStreamPlayer.new()
	fx_player.stream = fx_stream
	fx_player.volume_db = volume
	fx_player.bus = "SFX"
	add_child(fx_player)
	fx_player.play()

	await fx_player.finished
	fx_player.queue_free()
