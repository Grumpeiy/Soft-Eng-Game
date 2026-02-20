extends AudioStreamPlayer

const LEVEL_MUSIC = preload("res://sfx/music/Menu.mp3")

func _ready():
	play_music_level()


func play_music_level():
	stream = LEVEL_MUSIC
	
	if stream is AudioStreamMP3:
		stream.loop = true
	
	volume_db = -12
	play()


func stop_music():
	stop()


func play_FX(fx_stream: AudioStream, volume := 0.0):
	var fx_player = AudioStreamPlayer.new()
	fx_player.stream = fx_stream
	fx_player.volume_db = volume
	add_child(fx_player)
	fx_player.play()
	
	await fx_player.finished
	fx_player.queue_free()
