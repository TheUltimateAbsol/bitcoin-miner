extends InputBase

onready var character_list = $VBoxContainer2/Row/character_input
onready var expression_list = $VBoxContainer2/Row2/expression_input
onready var char_transition_list = $VBoxContainer2/Row3/transition_input
onready var last_character_input = $VBoxContainer2/Row4/last_character_input

func _ready():
	for i in range (VNGlobal.Characters.keys().size()):
		character_list.add_item(VNGlobal.Characters.keys()[i], i);
	for i in range (VNGlobal.Expressions.keys().size()):
		expression_list.add_item(VNGlobal.Expressions.keys()[i], i);
	for i in range (VNGlobal.CharacterTransitions.keys().size()):
		char_transition_list.add_item(VNGlobal.CharacterTransitions.keys()[i], i);
	
	
func _string_select(option_button, key):
	for i in range(option_button.get_item_count()):
		if option_button.get_item_text(i) == key:
			option_button.select(i);

func get_data():
	var character_image = character_list.get_item_text(character_list.get_selected_id())
	var character_expression = expression_list.get_item_text(expression_list.get_selected_id())
	var character_transition = char_transition_list.get_item_text(char_transition_list.get_selected_id())
	var use_last_character = last_character_input.pressed
	
	return {
		"character_image": character_image,
		"character_expression": character_expression,
		"character_transition": character_transition,
		"use_last_character": use_last_character
	};
	
func load_data(page_data):
	_string_select(character_list, page_data.character_image);
	_string_select(expression_list, page_data.character_expression);
	_string_select(char_transition_list, page_data.character_transition);
	last_character_input.pressed = bool(page_data.use_last_character)


func _on_character_input_item_selected(id):
	update();

func _on_expression_input_item_selected(id):
	update();

func _on_transition_input_item_selected(id):
	update();
	
func _on_last_character_input_toggled(button_pressed):
	character_list.disabled = button_pressed;
	expression_list.disabled = button_pressed;
	char_transition_list.disabled = button_pressed;
	update();
