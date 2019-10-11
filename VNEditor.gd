extends Control

#transition check boxes
onready var tansition_none = get_node("Panel/VBoxContainer/Layout/characterInfo/character_layout/transitionLayout/tansition_none")
# id inputs
onready var id_input = get_node("Panel/VBoxContainer/Layout/id_info/GridContainer/id_input")
onready var next_id_input = get_node("Panel/VBoxContainer/Layout/id_info/GridContainer/next_id_input")
# parse buttons
onready var parse_btn = get_node("Panel/VBoxContainer/Layout/parse_btn")

var id : int
var next_id : int
var senence_speed : int
var sentence_delay : int
var sentence_text : String
var character : int
var character_expression : int
var character_transition : int
var music : int
var background : int

var have_ids : bool
# line edit ->select_all()

# Called when the node enters the scene tree for the first time.
func _ready():
	var have_ids = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(parse_btn.is_pressed()):
		print("Parsing...")
		if(not have_ids):
			get_ids()
		
# gets the ids for the page and the id of the page that will follow it
func get_ids():
	var get_id = id_input.get_text()
	var get_next_id = next_id_input.get_text()
	# print(get_id)
	id = int(get_id)
	next_id = int(get_next_id)
	# print("id:", id)
	# print("next id:", next_id)