extends Control

func play_game():
	pass

func _on_Button_pressed():
	$TransitionMask.transition_out2()
	yield($TransitionMask, "transition_completed")
	play_game()
