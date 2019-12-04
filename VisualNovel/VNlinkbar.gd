extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var data_json
var LinkItem = preload("res://VisualNovel/LinkBarItem.tscn");
#Notice how this links to the scene, not the script.

var my_data = [
    {
        "type" :"message",
        "id" : 1,
        "next" : 2,
        "text" : "Test Message 1"
    },
    {
        "type" :"message",
        "id" : 2,
        "next" : 3,
        "text" : "Test Message 2"
    },
    {
        "type" :"questions",
        "id" : 3,
        "text" : "Questions 1", 
        "questions" : [
            {
                "text" : "Choice 1",
                "next" : 4
            },
            {
                "text" : "Choice 2",
                "next" : 5
            }
        ]
    },
    {
        "type" : "message",
        "id" : 4,
        "next" : 6,
        "text" : "Result 1"
    },
    {
        "type" : "message",
        "id" : 5,
        "next" : 6,
        "text" : "Result 2"
    },
    {
        "type" : "control",
        "id" : 6,
        "next" : 7,
        "comment" : "Control"
    },
    {
        "type" : "end",
        "id" : 7,
        "comment" : "Endpoint"
    }
]


# Called when the node enters the scene tree for the first time.
func _ready():
	#load_data("res://VisualNovel/bitcoin-linkbar-test.json")
#	var one = VNlinkbarItem.new("message", 1, 2, "Test message 1")
#	var two = VNlinkbarItem.new("message", 2, 3, "Test message 2")
#	var three = VNlinkbarItem.new("question", 3, 0, "Questions 1")
#	var A = VNlinkbarItem.new("", 0, 4, "Choice 1")
#	var B = VNlinkbarItem.new("", 0, 5, "Choice 2")
#	var four = VNlinkbarItem.new("message", 4, 6, "Result 1")
#	var five = VNlinkbarItem.new("message", 5, 6, "Result 2")
#	var six = VNlinkbarItem.new("control", 6, 7, "Control")
#	var seven = VNlinkbarItem.new("end", 7, -1, "Endpoint")
	#TODO: Get the UI elements working
	
	for item in my_data:
		#Create a message element
		var message = LinkItem.instance()
		add_child(message);
		message.populate(item);
		
		#Add question options if they exist.
		if item.get("type") == "questions":
			for i in range(item["questions"].size()):
				var question = LinkItem.instance()
				add_child(question);
				question.populate(item["questions"][i],i);
				

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#func load_data(file_path):
#	#retrieves the json file
#	var file = File.new()
#	file.open(file_path, 3)
#	#converts the json file to a text file
#	var text_json = file.get_as_text()
##	print(text_json)
#	#parses tect file to dictionary
#	data_json = JSON.parse(text_json)
#	#checks to make sure it parsed correctly
#	if data_json.error == OK:
#		print("LINKBAR_All is good")
#	else:
#		print("LINKBAR_something is wrong")
#		print(typeof(data_json.result))
#		print(data_json.get_error_line())
#	print("LINKBAR_checkpoint 1")
#	print(typeof(data_json.result))
#	print(data_json)
#	file.close()