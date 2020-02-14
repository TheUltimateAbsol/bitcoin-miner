extends Panel

class_name VNlinkbarItem

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var type
var id
var next
var clicked = false
var index = -1;
#var text

onready var display_id = $HBoxContainer/Id;
onready var display_type = $HBoxContainer/Type;
onready var display_text = $HBoxContainer/Text

onready var defaultStyle = preload("Style/LinkBarDefault.tres");
onready var selectedStyle = preload("Style/LinkBarSelected.tres");
onready var nextStyle = preload("Style/LinkBarNext.tres");
onready var previousStyle = preload("Style/LinkBarPrevious.tres");

# Called when the node enters the scene tree for the first time.
func _init():
#	type = xtype
#	id = xid
#	next = xnext
#	text = xtext
	pass
	
				
#This function actually is only called with a new() call
#The new call only works for hypothetical objects. Not instances.
#Therefore, we have to use the instance() function (Which takes 0 args), then
#populate the data when it's instanced.
#There's probably a better way, but this is the only correct way I know of
	
func populate(data, question_num=0):
	#We do this only for the sake of highlighting later
	next = data.get("next_id"); #The "get" command will return null if it is empty
	#We do this because this information might be important on click
	id = data.get("id");
	
	if data.get("id") or data.get("id") == 0:
		display_id.text = str(data.get("id")).pad_zeros(4) + ":";
	else:
		display_id.text = "     "

	match data.get("type"):
		"Page": display_type.text= " - ";
		"ContentPage": display_type.text= " + ";
		"GameStartPage": display_type.text= " > ";
		"GameEndPage": display_type.text= " # ";
		"questions": display_type.text= " ? ";
		"control": display_type.text= " * ";
		"EndPage": display_type.text= " X ";
#		Match an answer; has no type
		_: display_type.text= " " + char(question_num + 65) + ":";
	
	if data.get("content"):
		display_text.text = "FORMATTING ERROR";
		if typeof(data.get("content")) == TYPE_ARRAY:
			if data.get("content").size() > 0:
				print(data.get("content")[0]);
				display_text.text = str(data.get("content")[0].get("content"))
		#Then some code here to set the text preview
	elif data.get("comment"):
		display_text.text = data.get("comment");
	elif data.get("type") == "GameStartPage":
		display_text.text = "<GAME START>";
	elif data.get("type") == "GameEndPage":
		display_text.text = "<GAME END>";
	elif data.get("type") == "EndPage":
		display_text.text = "<END>";
		
		
#display_text.visible_characters = 20
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Checks when object is clicked
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		print("Left mouse button was pressed!")
		select();

				
func select():
	var children = get_parent().get_children()
	print(theme);
	set_deferred("theme", selectedStyle)
	
	get_parent().on_selected(index);
	
	for item in children:
		if item.id == next:
			item.theme = nextStyle
		elif item.next == id:
			item.theme = previousStyle
		else:
			item.theme = defaultStyle;
