extends InputBase

# id inputs
onready var value_input = $GridContainer/HBoxContainer2/value_input

func get_data():
	# get the IDs
	var value = bool(value_input.pressed)
		
	return {
		"value": value
	};
	
func load_data(page_data):
	value_input.pressed = bool(page_data.value);

func _on_value_input_toggled(button_pressed):
	update();
