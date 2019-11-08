extends Node

signal pressed_attack

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		emit_signal("pressed_attack");