extends InputBase

onready var character_list = $VBoxContainer2/character_input

func _ready():
	for i in range (VNGlobal.Characters.keys().size()):
		character_list.add_item(VNGlobal.Characters.keys()[i], i);

func _string_select(option_button, key):
	for i in range(option_button.get_item_count()):
		if option_button.get_item_text(i) == key:
			option_button.select(i);

func get_data():
	var character = character_list.get_item_text(character_list.get_selected_id())
	
	return {
		"character": character
	};
	
func load_data(page_data):
	_string_select(character_list, page_data.character);


func _on_character_input_item_selected(id):
	update()
