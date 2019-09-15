extends Node2D
signal unpause

func _ready():
	set_process_input(true)


func _process(delta):
	if (Input.is_key_pressed(KEY_ESCAPE)):
		emit_signal("unpause")



func _on_Sprite_unpause():
	emit_signal("unpause");
	print("ASD");
