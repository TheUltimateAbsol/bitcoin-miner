extends Node

func _ready():
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)
	timer.start()
	yield(timer, "timeout")
	timer.queue_free()
	
	GlobalMusic.fade_into_track(VNGlobal.Music.NONE)
	GlobalMusic.queue_track(Global.GameMusic.BOSS)
	
