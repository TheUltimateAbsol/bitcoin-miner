extends InputBase

onready var flag_input = $VBoxContainer2/sentence_info2/flag_input

func get_data():
	return {
		"flag": flag_input.text

	};
	
func load_data(page_data):
	flag_input.text = page_data.flag;


func _on_flag_input_text_changed(new_text):
	update();
