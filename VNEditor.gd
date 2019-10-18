extends Control

# character inputs
# transition check boxes
onready var transition_box_none = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/transitionLayout/tansition_none")
onready var transition_box_flash = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/transitionLayout/flashBox")
onready var transition_box_fade = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/transitionLayout/fadeBox")
onready var transition_box_right = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/transitionLayout/rightSlideBox")
onready var transition_box_left = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/transitionLayout/leftSlideBox")
# character model
onready var character_box_boy = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/Character/boyBox")
onready var character_box_girl = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/Character/girlBox")
onready var character_box_none = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/Character/noneBox")
# chracacter Expressions
onready var expression_box_default = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/Expressions/default")
onready var expression_box_happy = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/Expressions/happy")
onready var expression_box_sad = get_node("Panel/HBoxContainer/Layout/characterInfo/character_layout/Expressions/sad")

# scene inputs
# music check boxes
onready var music_box_none = get_node("Panel/HBoxContainer/Layout/sceneInfo/GridContainer/musicList/noneBox")
onready var music_box_same = get_node("Panel/HBoxContainer/Layout/sceneInfo/GridContainer/musicList/sameBox")
onready var music_box_simple = get_node("Panel/HBoxContainer/Layout/sceneInfo/GridContainer/musicList/simpleBox")
onready var music_box_sad = get_node("Panel/HBoxContainer/Layout/sceneInfo/GridContainer/musicList/sadBox")

# Scene transition check boxes


# background check boxes
onready var background_box_classroom = get_node("Panel/HBoxContainer/Layout/sceneInfo/GridContainer/background_list/classroom_box")
onready var background_box_same = get_node("Panel/HBoxContainer/Layout/sceneInfo/GridContainer/background_list/same_box")
onready var background_box_none = get_node("Panel/HBoxContainer/Layout/sceneInfo/GridContainer/background_list/none_background_box")

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
var character : int
var character_expression : int
var character_transition : int
var music : int
var background : int

# Called when the node enters the scene tree for the first time.
func _ready():
	var have_ids = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(parse_btn.is_pressed()):
		print("Parsing...")
		get_data()
		print(character)
	
	if preview_btn.is_pressed():
		print("Previewing scene")
# gets the ids for the page and the id of the page that will follow it
func get_data():
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
	if character_box_boy.is_pressed():
		character = Global.Characters.BOY
	elif character_box_girl.is_pressed():
		character = Global.Characters.GIRL
	else:
		character = Global.Characters.NONE
	
	#character_expression
	if expression_box_happy.is_pressed():
		character_expression = Global.Expressions.HAPPY
	elif expression_box_sad.is_pressed():
		character_expression = Global.Expressions.SAD
	else:
		character_expression = Global.Expressions.DEFAULT
		
	#character_transition
	if transition_box_fade.is_pressed():
		character_transition = Global.Transitions.FADE
	elif transition_box_flash.is_pressed():
		character_transition = Global.Transitions.FLASH
	elif transition_box_left.is_pressed():
		character_transition = Global.transition.LEFT
	elif transition_box_right.is_pressed():
		character_transition = Global.Transitions.RIGHT
	else:
		character_transition = Global.Transitions.NONE
		
	#  MUSIC
	if music_box_sad.is_pressed():
		music = Global.Music.SAD
	elif music_box_simple.is_pressed():
		music = Global.Music.SIMPLE
	elif music_box_same.is_pressed():
		music = Global.Music.SAME
	else:
		music = Global.Music.NONE
		
	#  BACKGROUND
	if background_box_classroom.is_pressed():
		background = Global.Backgrounds.CLASSROOM
	elif background_box_same.is_pressed():
		background = Global.Backgrounds.SAME
	else:
		background = Global.Backgrounds.NONE
		
	