extends Control

# character  transition section
onready var char_transition_list = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/char_transition_list")

# character model
onready var character_list = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/character_list")

# chracacter Expressions
onready var expression_list = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/expression_list")

# music
onready var music_list = get_node("Panel/HBoxContainer/Layout/sceneInfo/GridContainer/musicList")

# Scene transition check boxes go here

# background check boxes
onready var background_list = get_node("Panel/HBoxContainer/Layout/sceneInfo/GridContainer/background_list")

# id inputs
onready var id_input = get_node("Panel/HBoxContainer/Layout/id_info/GridContainer/id_input")
onready var next_id_input = get_node("Panel/HBoxContainer/Layout/id_info/GridContainer/next_id_input")

# Sentence data
onready var sentence_txt_input = get_node("Panel/HBoxContainer/Layout/sentenceInfo/GridContainer/GridContainer/sentence_input")
onready var sentence_delay_input = get_node("Panel/HBoxContainer/Layout/sentenceInfo/GridContainer/GridContainer/sent_delay_input")
onready var sentence_speed_input = get_node("Panel/HBoxContainer/Layout/sentenceInfo/GridContainer/GridContainer/sent_speed_input")
onready var sentence_transition_input = get_node("Panel/HBoxContainer/Layout/sentenceInfo/GridContainer/GridContainer/sent_transition_input")

# parse buttons
onready var parse_btn = get_node("Panel/HBoxContainer/Layout/parse_btn")
onready var preview_btn = get_node("Panel/HBoxContainer/Layout/preview_btn")

var id : int
var next_id : int
var sentence_speed : int
var sentence_delay : int
var sentence_text : String
var sentence_tansition : int
var character
var character_expression
var character_transition 
var music
# sentence sound?
# speed?
var background
var page_data

# button groups for the text boxes
var background_buttons = ButtonGroup.new()
var music_buttons = ButtonGroup.new()
var char_transition_buttons = ButtonGroup.new()
var character_buttons = ButtonGroup.new()
var expression_buttons = ButtonGroup.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var have_ids = false
	
	var background_keys = Global.Backgrounds.keys()
	for key in background_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(background_buttons)
		background_list.add_child(new_box)
		
	var music_keys = Global.Music.keys()
	for key in music_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(music_buttons)
		music_list.add_child(new_box)
		
	var char_transition_keys = Global.Transitions.keys()
	for key in char_transition_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(char_transition_buttons)
		char_transition_list.add_child(new_box)
		
	var character_keys = Global.Characters.keys()
	for key in character_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(character_buttons)
		character_list.add_child(new_box)
	
	var expression_keys = Global.Expressions.keys()
	for key in expression_keys:
		var new_box = CheckBox.new()
		new_box.text = key
		new_box.set_button_group(expression_buttons)
		expression_list.add_child(new_box)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(parse_btn.is_pressed()):
		print("Parsing...")
		get_data()
#		make_dictionary()
#		print(page_data)
		# print(character)
	
	if preview_btn.is_pressed():
		# make_dictionary()
		print("Previewing scene")
		# print(page_data)

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
	
	
	music = music_buttons.get_pressed_button().text
	
	print(background)
	print(music)
		
	# get the IDs
	var get_id = id_input.get_text()
	var get_next_id = next_id_input.get_text()
	id = int(get_id)
	next_id = int(get_next_id)

	# get sentence info
	sentence_text = sentence_txt_input.get_text()
	sentence_delay = int(sentence_delay_input.get_text())
	sentence_speed = int(sentence_speed_input.get_text())
	# sentence_transition

	

	#  get character info
	#  which caracter
#	if character_box_boy.is_pressed():
#		character = Global.Characters.BOY
#	elif character_box_girl.is_pressed():
#		character = Global.Characters.GIRL
#	else:
#		character = Global.Characters.NONE
#
#	#character_expression
#	if expression_box_happy.is_pressed():
#		character_expression = Global.Expressions.HAPPY
#	elif expression_box_sad.is_pressed():
#		character_expression = Global.Expressions.SAD
#	else:
#		character_expression = Global.Expressions.DEFAULT
#
#	#character_transition
#	if transition_box_fade.is_pressed():
#		character_transition = Global.Transitions.FADE
#	elif transition_box_flash.is_pressed():
#		character_transition = Global.Transitions.FLASH
#	elif transition_box_left.is_pressed():
#		character_transition = Global.transition.LEFT
#	elif transition_box_right.is_pressed():
#		character_transition = Global.Transitions.RIGHT
#	else:
#		character_transition = Global.Transitions.NONE
#
#	#  MUSIC
#	if music_box_sad.is_pressed():
#		music = Global.Music.SAD
#	elif music_box_simple.is_pressed():
#		music = Global.Music.SIMPLE
#	elif music_box_same.is_pressed():
#		music = Global.Music.SAME
#	else:
#		music = Global.Music.NONE
#
#	#  BACKGROUND
#	if background_box_classroom.is_pressed():
#		background = Global.Backgrounds.CLASSROOM
#	elif background_box_same.is_pressed():
#		background = Global.Backgrounds.SAME
#	else:
#		background = Global.Backgrounds.NONE

#	var keys = Global.Expressions.keys();
#	for key in keys:
#		var new_box = CheckBox.new();
#		new_box.text = key;
#		target_node.add_child(new_box);
#
#		pass
		#do something with the key
		#key is a string.
		
# MAKE ON CHANGE FUNCION
		
#func make_dictionary():
#	page_data = {
#			str(id) :{
#					"id": id,
#					"next_id": next_id,
#					"content":[
#						{
#							"string": sentence_text,
#							"sound": 0,
#							"sentence_speed": sentence_speed,
#							"delay": sentence_delay
#						},
#					],
#					"Character": character,
#					"speed": 0.0, 
#					"transition": character_transition, 
#					"expresssion": character_expression, 
#					"music": music, 
#					"background":background,
#				}	
#		}