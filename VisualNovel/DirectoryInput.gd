extends PanelContainer

# id inputs
onready var directory_input = $GridContainer/directory_input


func get_data():
		# get the IDs
	var game_dir = directory_input.get_text()
		
	return {
		"game_dir": game_dir
	};
	
func load_data(game_dir):
	directory_input.text = str(game_dir);