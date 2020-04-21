extends Control

func _ready():
	yield(get_node("Starting Cover/AnimationPlayer"), "animation_finished")
	GlobalMusic.play_track(Global.GameMusic.TITLE)
	get_node("Starting Cover/Button").disabled = false

func play_game():
	SceneChanger.change_scene("res://main.tscn")

func _on_Button_pressed():
	GlobalMusic.fade_into_track(VNGlobal.Music.NONE)
	get_node("Starting Cover/Button").disabled = true
	$TransitionMask.transition_out2()
	yield($TransitionMask, "transition_completed")
	play_game()
