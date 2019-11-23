extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var data_json


# Called when the node enters the scene tree for the first time.
func _ready():
	#load_data("res://VisualNovel/bitcoin-linkbar-test.json")
	var one = VNlinkbarItem.new("message", 1, 2, "Test message 1")
	var two = VNlinkbarItem.new("message", 2, 3, "Test message 2")
	var three = VNlinkbarItem.new("question", 3, 0, "Questions 1")
	var A = VNlinkbarItem.new("", 0, 4, "Choice 1")
	var B = VNlinkbarItem.new("", 0, 5, "Choice 2")
	var four = VNlinkbarItem.new("message", 4, 6, "Result 1")
	var five = VNlinkbarItem.new("message", 5, 6, "Result 2")
	var six = VNlinkbarItem.new("control", 6, 7, "Control")
	var seven = VNlinkbarItem.new("end", 7, -1, "Endpoint")
	#TODO: Get the UI elements working
	
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load_data(file_path):
	#retrieves the json file
	var file = File.new()
	file.open(file_path, 3)
	#converts the json file to a text file
	var text_json = file.get_as_text()
#	print(text_json)
	#parses tect file to dictionary
	data_json = JSON.parse(text_json)
	#checks to make sure it parsed correctly
	if data_json.error == OK:
		print("LINKBAR_All is good")
	else:
		print("LINKBAR_something is wrong")
		print(typeof(data_json.result))
		print(data_json.get_error_line())
	print("LINKBAR_checkpoint 1")
	print(typeof(data_json.result))
	print(data_json)
	file.close()