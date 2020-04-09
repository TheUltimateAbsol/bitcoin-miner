extends Node

const times_to_repeat = 2

func _ready():
	var text = load_file();
	var to_write = ""
	for c in text:
		if c != "\n":
			for i in range(times_to_repeat):
				to_write+=c;
		else:
			to_write+=c;
				
	save_file(to_write);
	
func load_file():
	var new_dict
	
	var file = File.new()
	file.open("to_repeat.txt", 3)
	#converts the json file to a text file
	var text = file.get_as_text()
	file.close()
	
	return text

func save_file(text):
	var file = File.new()
	
	var new_file = File.new()
	new_file.open("edited_characters.txt", 2)
	new_file.store_line(text)
	new_file.close();
