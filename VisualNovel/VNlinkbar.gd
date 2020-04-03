extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var data_json
var LinkItem = preload("LinkBarItem.tscn");

signal selected
#Notice how this links to the scene, not the script.

# Called when the node enters the scene tree for the first time.
func load_data(my_data: Array):
	for child in get_children():
		child.queue_free();
	
	for i in range(my_data.size()):
		var item = my_data[i];
		#Create a message element
		var message = LinkItem.instance()
		add_child(message);
		message.populate(item);
		message.index = i;
		
		#Add question options if they exist.
		if item.get("type") == "QuestionPage":
			for j in range(item["answers"].size()):
				var question = LinkItem.instance()
				add_child(question);
				question.populate(item["answers"][j],j);
				question.index = i;
				
func on_selected(index):
	emit_signal("selected", index);
	
func select(index):
	if index == -1: return;
	
	for item in get_children():
		if item.index == index:
			item.select();
