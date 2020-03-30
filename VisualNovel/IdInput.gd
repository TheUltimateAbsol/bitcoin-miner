extends PanelContainer

# id inputs
onready var id_input = $GridContainer/id_input
onready var next_id_input = $GridContainer/next_id_input


func get_data():
		# get the IDs
	var id = id_input.get_text()
	var next_id = next_id_input.get_text()
	
	if id != null and id.is_valid_integer():
		id = int(id)
	else:
		id = 0
	
	if next_id != null and next_id.is_valid_integer():
		next_id = int(next_id)
	else:
		next_id = 1
		
	return {
		"id": id,
		"next_id": next_id
	};
	
func load_data(id, next_id):
	id_input.text = str(id);
	next_id_input.text = str(next_id);
