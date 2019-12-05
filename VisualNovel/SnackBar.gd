extends Control

func activate(message):
	$Panel/Label.text = message
	$AnimationPlayer.play("Activate");