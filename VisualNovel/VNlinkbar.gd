extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var data_json
var LinkItem = preload("LinkBarItem.tscn");
#Notice how this links to the scene, not the script.

var my_old_data = [
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
func load_data(my_data: Array):
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