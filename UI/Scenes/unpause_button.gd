extends Sprite

signal unpause



func _on_Button_pressed():
	print("BUTTON");
	emit_signal("unpause");
