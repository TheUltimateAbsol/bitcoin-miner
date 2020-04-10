extends InputBase

# id inputs
onready var target_id_input = $GridContainer/target_id_input

func get_data():
	# get the IDs
	var target_id = int(target_id_input.get_value())
		
	return {
		"target_id": target_id
	};
	
func load_data(page_data):
	target_id_input.value = int(page_data.target_id);



func _on_target_id_input_value_changed(value):
	update();
