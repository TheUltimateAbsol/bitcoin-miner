extends Control

func activate(message):
	$Panel/Label.text = str(message)
	$AnimationPlayer.play("Activate");