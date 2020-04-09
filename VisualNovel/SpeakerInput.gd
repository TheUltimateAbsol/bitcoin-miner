extends InputBase

onready var name_input = $VBoxContainer2/sentence_info2/HBoxContainer/name_input
onready var thought_input = $VBoxContainer2/sentence_info2/HBoxContainer2/thought_input

func get_data():
		
	return {
		"is_thought": thought_input.pressed,
		"speaker_name": name_input.text
	};
	
func load_data(page_data):
	name_input.text = page_data.speaker_name;
	thought_input.pressed = bool(page_data.is_thought)
	name_input.editable = not bool(page_data.is_thought);

func _on_thought_input_toggled(button_pressed):
	name_input.editable = not button_pressed;
	update();

func _on_name_input_text_changed(new_text):
	update();
