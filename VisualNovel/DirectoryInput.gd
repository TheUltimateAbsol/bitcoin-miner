extends InputBase

# id inputs
onready var directory_input = $GridContainer/directory_input


func get_data():
		# get the IDs
	var game_dir = directory_input.get_text()
		
	return {
		"game_dir": game_dir
	};
	
func load_data(page_data):
	directory_input.text = str(page_data.game_dir);


func _on_directory_input_text_changed(new_text):
	update();
