extends Control

onready var SentenceLabel = preload("res://UI/Scenes/Sentence_Label.tscn");

# character  transition section
onready var char_transition_list = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/char_transition_list")

# character model
onready var character_list = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/character_list")

# chracacter Expressions
onready var expression_list = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/expression_list")

# music
onready var music_list = get_node("Panel/HBoxContainer/Layout/sceneInfo/GridContainer/musicList")

# Scene transition check boxes go here
onready var scene_transition_list = get_node("Panel/HBoxContainer/Layout/sceneInfo/GridContainer/transition_list")

# background check boxes
onready var background_list = get_node("Panel/HBoxContainer/Layout/sceneInfo/GridContainer/background_list")

# id inputs
onready var id_input = get_node("Panel/HBoxContainer/Layout/id_info/GridContainer/id_input")
onready var next_id_input = get_node("Panel/HBoxContainer/Layout/id_info/GridContainer/next_id_input")

onready var sentence_list = get_node("Panel/HBoxContainer/Layout/sentenceInfo/VBoxContainer/sentence_list")

# Sentence data
onready var sentence_txt_input = get_node("Panel/HBoxContainer/Layout/sentenceInfo/VBoxContainer/sentence_txt/sentence_input")
onready var sentence_delay_input = get_node("Panel/HBoxContainer/Layout/sentenceInfo/VBoxContainer/sentence_info2/sent_delay_input")
onready var sentence_speed_input = get_node("Panel/HBoxContainer/Layout/sentenceInfo/VBoxContainer/sentence_info2/sent_speed_input")
#onready var sentence_transition_input = get_node("Panel/HBoxContainer/Layout/sentenceInfo/VBoxContainer/sentence_info2/sent_transition_input")
onready var add_sentence_btn = get_node("Panel/HBoxContainer/Layout/sentenceInfo/VBoxContainer/sentence_txt/add_sentence")

# parse buttons
onready var parse_btn = get_node("Panel/HBoxContainer/Layout/parse_btn")
onready var preview_btn = get_node("Panel/HBoxContainer/Layout/preview_btn")

# sound effect menu options
onready var sound_menu = get_node("Panel/HBoxContainer/Layout/sentenceInfo/VBoxContainer/sentence_info2/sound_menu")

onready var reader = $Panel/HBoxContainer/Node2D/VNReader

var id : int
var next_id : int
var sentence_speed : int
var sentence_delay : int
var sentence_text
var scene_transition
var sentences = []# array of sentence objects
var character
var character_expression
var character_transition 
var music
var sentence_sound
# speed?
var background

var page_data
var data_json

# button groups for the text boxes
var background_buttons = ButtonGroup.new()
var music_buttons = ButtonGroup.new()
var char_transition_buttons = ButtonGroup.new()
var character_buttons = ButtonGroup.new()
var expression_buttons = ButtonGroup.new()
var back_transition_buttons = ButtonGroup.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var have_ids = false
	
	var background_keys = Global.Backgrounds.keys()
	for key in background_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(background_buttons)
		if new_box.text == "NONE":
#			new_box.set_modulate(Color( 1, 0, 0, 1 ))
			new_box.pressed = true 
		background_list.add_child(new_box)
		
	var music_keys = Global.Music.keys()
	for key in music_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(music_buttons)
		if new_box.text == "NONE":
			new_box.pressed = true
		music_list.add_child(new_box)
		
	var char_transition_keys = Global.Transitions.keys()
	for key in char_transition_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(char_transition_buttons)
		if new_box.text == "NONE":
			new_box.pressed = true
		char_transition_list.add_child(new_box)
		
	var character_keys = Global.Characters.keys()
	for key in character_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(character_buttons)
		if new_box.text == "BOY":
			new_box.pressed = true
		character_list.add_child(new_box)
	
	var expression_keys = Global.Expressions.keys()
	for key in expression_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(expression_buttons)
		if new_box.text == "DEFAULT":
			new_box.pressed = true
		expression_list.add_child(new_box)

	var soundeffect_keys = Global.SoundEffect.keys()
	var x = 1
	for key in soundeffect_keys:
		sound_menu.add_item(key, x)
		x += 1
		
	var back_tansition_keys = Global.Background_transitiosn.keys()
	for key in back_tansition_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(back_transition_buttons)
		if new_box.text == "NONE":
			new_box.pressed = true
		scene_transition_list.add_child(new_box)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	for sentence in sentences:
#		var new_sentence = Label.new()
#		new_sentence.text = sentence.content
#		sentence_list.add_child(new_sentence)
		
	if(parse_btn.is_pressed()):
		print("Parsing...")
		get_data()
		make_dictionary()
#		print(page_data)
		print(page_data)
		add_to_json()
	

func preview_scene():
	print("PLAYING PAGE")
	get_data()
	make_dictionary()
	print("Previewing scene")
	reader.play_page(page_data)


# gets the ids for the page and the id of the page that will follow it
func get_data():
#	var value
#	for child in background_list.get_children():
#		if child.is_pressed():
#			 value = child.text # what is saved in the JSON (the dictionary for now)

	
	if background_buttons.get_pressed_button() == null:
		background = Global.Backgrounds.NONE
	else:	
		background = background_buttons.get_pressed_button().text
	
	
	if back_transition_buttons.get_pressed_button() == null:
		scene_transition = Global.Background_transitiosn.NONE
	else:
		scene_transition = back_transition_buttons.get_pressed_button().text
	
	
	if music_buttons.get_pressed_button() == null:
		music = Global.Music.NONE
	else:
		music = music_buttons.get_pressed_button().text
	
	
	if char_transition_buttons.get_pressed_button() == null:
		character_transition = Global.Transitions.NONE
	else:
		character_transition = char_transition_buttons.get_pressed_button().text
		
	if character_buttons.get_pressed_button() == null:
		character = Global.Characters.BOY
	else:
		character = character_buttons.get_pressed_button().text
	
	
	if expression_buttons.get_pressed_button() == null:
		character_expression = Global.Expressions.DEFAULT
	else:
		character_expression = expression_buttons.get_pressed_button().text
		
		
	# get the IDs
	var get_id = id_input.get_text()
	var get_next_id = next_id_input.get_text()
	
	if get_id != null and get_id.is_valid_integer():
		id = int(get_id)
	else:
		id = 0
	
	if get_next_id != null and get_next_id.is_valid_integer():
		next_id = int(get_next_id)
	else:
		next_id = 1

	# sound effect

# MAKE ON CHANGE FUNCION
		
func make_dictionary():
	
	page_data = {
				"id": id,
				"next_id": next_id,
				"content": sentences,
#				"content":	{
#						"string": sentence_text,
#						"sound": 0,
#						"sentence_speed": sentence_speed,
#						"delay": sentence_delay
#					},
				"character": character,
				"speed": 0.0, 
				"transition": character_transition, 
				"expression": character_expression, 
				"music": music, 
				"background":background,
		}


func add_to_json():
	var new_dict
	var dir = Directory.new()
	
	var file = File.new()
	file.open("res://VisualNovel/data.json", 3)
	#converts the json file to a text file
	var text_json = file.get_as_text()
#	print(text_json)
	#parses tect file to dictionary
	data_json = JSON.parse(text_json)
	#checks to make sure it parsed correctly
	print(data_json)
	if data_json.error == OK:
		print("All is good")
	else:
		print("something is wrong")
		print(typeof(data_json.result))
		print(data_json.get_error_line())
	print("checkpoint 1")
	#print(typeof(data_json.result))
	#print(data_json.result)
	
	if typeof(data_json.result) == TYPE_ARRAY:
    	print("Array") # prints 'hello'
	else:
    	print("unexpected results")
	
	data_json.result[str(id)] = page_data
	new_dict = data_json.result
	print(new_dict)
	
	file.close()
	
	dir.remove("res://VisualNovel/data.json")
	
	var new_file = File.new()
	new_file.open("res://VisualNovel/data.json", 2)
	new_file.store_line(to_json(new_dict))
	file.close()
	
	
func add_sentence():
	sentence_text = sentence_txt_input.get_text()#.split(".") We need a different way of doing this
	
	var get_delay = sentence_delay_input.get_text()
	var get_speed = sentence_speed_input.get_text()
	
	if get_delay != null and get_delay.is_valid_integer():
		sentence_delay = int(get_delay)
	else:
		sentence_delay = 0
	
	if get_speed != null and get_speed.is_valid_integer():
		sentence_speed = int(get_speed)
	else:
		sentence_speed = 0
		
#	sentence_delay = int(sentence_delay_input.get_text())
#	sentence_speed = int(sentence_speed_input.get_text())
	#sentence_tansition = int(sentence_transition_input.get_text())
	
	sentence_sound = sound_menu.get_item_text(sound_menu.get_selected_id())
	
	sentences.push_back(sentence_to_json(Sentence.new(sentence_text, sentence_delay, sentence_sound, sentence_speed)))
	
	print(sentences)
	
	sentence_display()
#	var new_sentence = Label.new()
#	new_sentence.text = sentences[len(sentences)-1].content
#	sentence_list.add_child(new_sentence)


func sentence_display():
	for child in sentence_list.get_children():
		child.queue_free()

	for i in range(sentences.size()):
		var sentence = sentences[i];
		var new_sentence = SentenceLabel.instance()
		new_sentence.set_text(sentence.content);
		sentence_list.add_child(new_sentence)
		
		new_sentence.connect("delete", self, "delete_sentence", [i]);

func sentence_to_json(sentence : Sentence):
	return {"content" : sentence.content, "delay": sentence.delay, "speed" : sentence.speed, "sound" : sentence.sound}
	
func delete_sentence(index):
	sentences.remove(index)
	sentence_display()