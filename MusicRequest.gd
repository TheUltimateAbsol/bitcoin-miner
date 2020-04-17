extends Object
class_name MusicRequest
var track:String
var canceled = false;

func _init(xtrack):
	track = xtrack;

func play_track(player):
	if canceled == false:
		player.play_track(track)

func queue_track(player):
	if canceled == false:
		player.queue_track(track);
	
func cancel():
	canceled = true;
