extends InputBase

# id inputs
onready var value_input = $GridContainer/value_input

func get_data():
	# get the IDs
	var value = int(value_input.get_value())
		
	return {
		"value": value
	};
	
func load_data(page_data):
	value_input.value = int(page_data.value);



func _on_value_input_value_changed(value):
	update();
