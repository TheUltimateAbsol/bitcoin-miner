extends Node

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		print("Not a touch")
		return
	if event.pressed:
		print("touch start")
	else:
		print("touch end")

func _on_Button_pressed():
	print("pressed")
