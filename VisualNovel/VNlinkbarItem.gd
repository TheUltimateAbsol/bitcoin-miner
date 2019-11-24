extends Panel

class_name VNlinkbarItem

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var type
var id
var next
#var text

onready var display_id = $HBoxContainer/Id;
onready var display_type = $HBoxContainer/Type;
onready var display_text = $HBoxContainer/Text

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
	next = data.get("next"); #The "get" command will return null if it is empty
	#We do this because this information might be important on click
	id = data.get("id");
	
	if data.get("id"):
		display_id.text = str(data.get("id")).pad_zeros(4) + ":";
	else:
		display_id.text = "     "

	match data.get("type"):
		"message": display_type.text= " + ";
		"questions": display_type.text= " ? ";
		"control": display_type.text= " * ";
		"end": display_type.text= " X ";
#		Match an answer; has no type
		_: display_type.text= " " + char(question_num + 65) + ":";
	
	if data.get("text"):
		display_text.text = data.get("text");
		#Then some code here to set the text preview
	elif data.get("comment"):
		display_text.text = data.get("comment");
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
