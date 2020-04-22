extends AudioStreamPlayer

const Music = {"TITLE":"TITLE"}

const tracks = { 
	VNGlobal.Music.DEFAULT: preload("res://Music/Tracks/normal.ogg"),
	VNGlobal.Music.SUSPENSE:preload("res://Music/Tracks/suspense.ogg"),
	VNGlobal.Music.DESPAIR:preload("res://Music/Tracks/despair.ogg"),
	VNGlobal.Music.ENGAGING:preload("res://Music/Tracks/engaging.ogg"),
	VNGlobal.Music.BOISTEROUS: preload("res://Music/Tracks/boistrous.ogg"),
	Global.GameMusic.LEVEL:preload("res://Music/Tracks/level.ogg"),
	Global.GameMusic.BOSS:preload("res://Music/Tracks/boss.ogg"),
	Global.GameMusic.TITLE:preload("res://Music/Tracks/title.ogg"),
	Global.GameMusic.VICTORY:preload("res://Music/Tracks/victory.ogg"),
	Global.GameMusic.GAMEOVER:preload("res://Music/Tracks/dead.ogg")
}

var current_request:MusicRequest = null;

func fade_out():
	$Tween.stop_all();
	$Tween.interpolate_property(self, "volume_db", 0, -80, 2.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	
func fade_into_track(track):
	cancel()
	
	fade_out()
	current_request = MusicRequest.new(track);
	$Tween.connect("tween_all_completed", current_request, "queue_track", [self], CONNECT_ONESHOT)
	
func queue_track(track):
	cancel()
	
	current_request = MusicRequest.new(track);
	$Timer.start()
	$Timer.connect("timeout", current_request, "play_track", [self], CONNECT_ONESHOT)
	
func play_track(track):
	cancel();
	
	$Tween.stop_all();
	volume_db = 0;
	if playing: stop();
	if (track != VNGlobal.Music.NONE): stream = tracks[track];
	else:
		stream = null;
	play()

func cancel():
	if current_request != null:
		current_request.cancel()
		current_request = null;
