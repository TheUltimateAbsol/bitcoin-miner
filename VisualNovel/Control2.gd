extends Control


signal btn_pressed(btn);
#signal blue_pressed();
#signal yellow_pressed();
#signal green_pressed;

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	emit_signal("btn_pressed", "green");


func _on_Button2_pressed():
	emit_signal("btn_pressed", "red")


func _on_Button3_pressed():
	emit_signal("btn_pressed", "yellow")


func _on_Button4_pressed():
	emit_signal("btn_pressed", "blue")
