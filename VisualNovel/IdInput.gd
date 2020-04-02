extends InputBase

# id inputs
onready var id_input = $GridContainer/id_input
onready var next_id_input = $GridContainer/next_id_input

func get_data():
	# get the IDs
	var id = id_input.get_text()
	var next_id = int(next_id_input.get_value())
	
	if id != null and id.is_valid_integer():
		id = int(id)
	else:
		id = 0
		
	return {
		"id": id,
		"next_id": next_id
	};
	
func load_data(page_data):
	id_input.text = str(page_data.id);
	next_id_input.value = int(page_data.next_id);

func _on_next_id_input_value_changed(value):
	update()
