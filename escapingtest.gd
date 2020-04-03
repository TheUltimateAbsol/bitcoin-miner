extends Label

func _ready():
	var file_text = load_text_file("escape_test.txt")
	for c in file_text:
		text+=c
	text = text.c_unescape()
	print(file_text)
	save_text_file("escape_test.txt", file_text)



func load_text_file(path):
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var text = f.get_as_text()
	f.close()
	
	return text
	 
func save_text_file(path, text):
	var new_file = File.new()
	new_file.open(path, 2)
	new_file.store_line(text)
	new_file.close();
