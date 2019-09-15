extends Node2D
signal unpause

func _on_Sprite_unpause():
	emit_signal("unpause");
	print("ASD");
