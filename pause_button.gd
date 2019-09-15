extends Button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
#	if (is_pressed()):
#		print("pressed")
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass




func _on_pause_button_pressed():
	print("PAUSED")
	get_tree().paused = true
	
	$pause_menu.draw()
