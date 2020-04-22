extends Node

enum {
	PAGE_SWITCH,
	TITLE_START,
	ANGRY,
	FLOWERY,
	FRUSTRATED,
	MUSIC_NOTE,
	SWEAT,
	EXCLAMATION,
	SLAM,
	CHOICE_SELECTION,
	CHOICE_JUMP,
	ARROW_ENTRANCE
}

const tracks = {
	PAGE_SWITCH : preload("res://Music/SFX/NextPage.wav"),
	TITLE_START : preload("res://Music/SFX/TitleStart.wav"),
	ANGRY: preload("res://Music/SFX/angry.wav"),
	FLOWERY: preload("res://Music/SFX/flowery.wav"),
	SWEAT: preload("res://Music/SFX/sweat.wav"),
	FRUSTRATED: preload("res://Music/SFX/frustrated.wav"),
	MUSIC_NOTE: preload("res://Music/SFX/music_note.wav"),
	EXCLAMATION: preload("res://Music/SFX/exclamation.wav"),
	SLAM: preload("res://Music/SFX/slam.wav"),
	CHOICE_JUMP: preload("res://Music/SFX/arrow_jump.wav"),
	CHOICE_SELECTION: preload("res://Music/SFX/choice_selection.wav"),
	ARROW_ENTRANCE: preload("res://Music/SFX/arrow_entrance.wav")
}

func play_sound(sound:int):
	var player = AudioStreamPlayer.new()
	player.stream = tracks[sound]
	add_child(player)
	player.play()
	yield(player, "finished")
	player.queue_free()
	
func delay_sound(sound:int, time:float):
	var timer = Timer.new()
	timer.wait_time = time;
	timer.one_shot = true
	add_child(timer)
	yield(timer, "timeout")
	play_sound(sound)

