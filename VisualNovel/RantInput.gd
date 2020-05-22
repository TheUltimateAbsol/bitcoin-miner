extends InputBase

# id inputs
onready var value_input = $GridContainer/HBoxContainer2/value_input

func get_data():
	# get the IDs
	var rant = bool(value_input.pressed)
		
	return {
		"rant": rant
	};
	
func load_data(page_data):
	value_input.pressed = bool(page_data.rant);

func _on_value_input_toggled(button_pressed):
	update();
