extends AudioStreamPlayer

const tracks = { 
	VNGlobal.Music.DEFAULT: preload("res://Music/Tracks/Default.ogg"),
	VNGlobal.Music.SUSPENSE:preload("res://Music/Tracks/Suspense.ogg"),
	VNGlobal.Music.DESPAIR:preload("res://Music/Tracks/Despair.ogg"),
	VNGlobal.Music.ENGAGING:preload("res://Music/Tracks/Engaging.ogg"),
	VNGlobal.Music.BOISTEROUS: preload("res://Music/Tracks/Boistrous.ogg"),
	Global.GameMusic.LEVEL:preload("res://Music/Tracks/Level.wav"),
	Global.GameMusic.BOSS :preload("res://Music/Tracks/Boss.ogg")
}


func play_track(track):
	if playing: stop();
	if (track != VNGlobal.Music.NONE): stream = tracks[track];
	play()

