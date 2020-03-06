extends PanelContainer

onready var character_list = $character_layout/character_list
onready var expression_list = $character_layout/expression_list
onready var char_transition_list = $character_layout/char_transition_list
onready var name_menu = $character_layout/character_name_list/name_menu

var character_buttons = ButtonGroup.new()
var expression_buttons = ButtonGroup.new()
var char_transition_buttons = ButtonGroup.new()

func _ready():
	var char_transition_keys = VNGlobal.Transitions.keys()
	for key in char_transition_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(char_transition_buttons)
		if new_box.text == "NONE":
			new_box.pressed = true
		char_transition_list.add_child(new_box)
		
	var character_keys = VNGlobal.Characters.keys()
	for key in character_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(character_buttons)
		if new_box.text == "BOY":
			new_box.pressed = true
		character_list.add_child(new_box)
	
	var expression_keys = VNGlobal.Expressions.keys()
	for key in expression_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(expression_buttons)
		if new_box.text == "DEFAULT":
			new_box.pressed = true
		expression_list.add_child(new_box)
		
	var name_keys = VNGlobal.CharacterNames.keys()
	var count = 1
	for key in name_keys:
		name_menu.add_item(key, count)
		count += 1
		
func get_data():
	var character
	var character_expression
	var character_transition
	var character_name 
	
	if char_transition_buttons.get_pressed_button() == null:
		character_transition = VNGlobal.Transitions.NONE
	else:
		character_transition = char_transition_buttons.get_pressed_button().text
		
	if character_buttons.get_pressed_button() == null:
		character = VNGlobal.Characters.BOY
	else:
		character = character_buttons.get_pressed_button().text
	
	
	if expression_buttons.get_pressed_button() == null:
		character_expression = VNGlobal.Expressions.DEFAULT
	else:
		character_expression = expression_buttons.get_pressed_button().text
		
	# GET THE NAME OF THE CHARACTER HERE
	if name_menu.get_selected_id() == null:
		character_name = VNGlobal.CharacterNames[character]
	else:
		var name = name_menu.get_selected_id()
		character_name = VNGlobal.CharacterNames[name_menu.get_item_text(name)]
		
		
	return {
		"character": character,
		"transition": character_transition, 
		"expression": character_expression,
		"character_name": character_name
	};
	
func load_data(character, character_expression, character_transition):
	for button in character_buttons.get_buttons():
		if character == button.text:
			button.set_pressed(true);
	for button in expression_buttons.get_buttons():
		if character_expression == button.text:
			button.set_pressed(true);
	for button in char_transition_buttons.get_buttons():
		if character_transition == button.text:
			button.set_pressed(true);