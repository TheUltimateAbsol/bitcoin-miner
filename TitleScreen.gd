extends Control

func _ready():
	GlobalMusic.play_track(GlobalMusic.Music.TITLE)

func play_game():
	SceneChanger.change_scene("res://main.tscn")

func _on_Button_pressed():
	get_node("Starting Cover/Button").disabled = true
	$TransitionMask.transition_out2()
	yield($TransitionMask, "transition_completed")
	play_game()
