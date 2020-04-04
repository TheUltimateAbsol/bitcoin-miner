extends Control

# parse buttons
onready var reader = $Panel/HBoxContainer/VNReaderBox/VNReader
onready var insert_btn = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/New

#short reference names
onready var idInput = $Panel/HBoxContainer/Layout/IdInput
onready var sentenceInput = $Panel/HBoxContainer/Layout/SentenceInput
onready var characterInput = $Panel/HBoxContainer/Layout/CharacterInput
onready var directoryInput = $Panel/HBoxContainer/Layout/DirectoryInput
onready var questionInput = $Panel/HBoxContainer/Layout/QuestionInput
onready var speakerInput = $Panel/HBoxContainer/Layout/SpeakerInput
onready var imageInput = $Panel/HBoxContainer/Layout/ImageToggleInput
onready var transitionInput = $Panel/HBoxContainer/Layout/TransitionInput
onready var LinkBar = $Panel/HBoxContainer/VBoxContainer/ScrollContainer/LinkBar

const VNReaderClass = preload("res://VisualNovel/VNReader.tscn");
#Used to identify input types
enum Inputs {ID, SENTENCE, SCENE, CHARACTER, DIRECTORY, QUESTION, SPEAKER, TRANSITION, IMAGE}

var data_json #This is what we read in from a file. Honestly, I'm not sure why it's here
var save_data : Array #Our save data
var current_index = -1; #This says what page is currently selected

# IMPORTANT -- PLEASE READ
# Update this dictionary when you have a new type of page to edit
# Dependencies dictate what inputs will be used and read when the page is edited
# classNode is a link to the actual class (given by classname)
var classes = {
	"ContentPage": {
		"dependencies": [Inputs.ID, Inputs.SENTENCE, Inputs.CHARACTER, Inputs.SPEAKER],
		"classNode": ContentPage,
	},
	"GameStartPage": {
		"dependencies": [Inputs.ID, Inputs.DIRECTORY],
		"classNode": GameStartPage
	},
	"GameEndPage": {
		"dependencies": [Inputs.ID],
		"classNode": GameEndPage
	},
	"EndPage": {
		"dependencies": [Inputs.ID],
		"classNode": EndPage
	},
	"QuestionPage": {
		"dependencies" : [Inputs.ID, Inputs.QUESTION],
		"classNode": QuestionPage
	},
	"TransitionPage": {
		"dependencies" : [Inputs.ID, Inputs.TRANSITION],
		"classNode": TransitionPage
	},
	"ImageTogglePage": {
		"dependencies" : [Inputs.ID, Inputs.IMAGE],
		"classNode": ImageTogglePage
	},
}

func type_to_input(input_type):
	match(input_type):
		Inputs.ID:
			return idInput;
		Inputs.SENTENCE:
			return sentenceInput;
		Inputs.CHARACTER:
			return characterInput
		Inputs.DIRECTORY:
			return directoryInput
		Inputs.QUESTION:
			return questionInput;
		Inputs.SPEAKER:
			return speakerInput;
		Inputs.TRANSITION:
			return transitionInput;
		Inputs.IMAGE:
			return imageInput;
		_:
			push_error("INVALID INPUT " + String(input_type))
			return null;

# Renders the given input into the editor given the page_data
func load_input(input_type, page_data):
	type_to_input(input_type).load_data(page_data)
	type_to_input(input_type).show();
			
# Reads data from the given input, then saves it into page_data
func read_input(input_type, page_data):
	VNGlobal.merge_dir(page_data, type_to_input(input_type).get_data());
			
# This function hides all rendered inputs and displays new ones according to 
# the current index
# Useful for changing the display when a new linkbaritem is selected
func update_options():
	for child in $Panel/HBoxContainer/Layout.get_children():
		child.hide();
		
	if current_index == -1:
		return
	
	#load page content
	var page_data = save_data[current_index];
	var page_class = classes[page_data.type];

	for input in page_class.dependencies:
		load_input(input, page_data);
			

# Called when the node enters the scene tree for the first time.
func _ready():	
#	Populate the "Insert" button with possible insertable items
	for i in range(classes.keys().size()):
		insert_btn.get_popup().add_item(classes.keys()[i], i);
	insert_btn.get_popup().connect("id_pressed", self, "insert");

	load_from_json();
	update_options()
	
#	Connect all changed events from the inputs
	for input in $Panel/HBoxContainer/Layout.get_children():
		input.connect("changed", self, "update_page");

func preview_scene():
	update_page()
#	Note: we delete the reader and re-instance it so that the typing does not go all funky-wunky
	var temp = reader.duplicate();
	reader.queue_free();
	reader = temp
	$Panel/HBoxContainer/VNReaderBox.add_child(reader);
	reader.play_json(save_data[current_index])
		
# Reads data from the currently rendered inputs, and saves it to save_data
# Then refreshes LinkBar to display correctly
func update_page():
	var page_class = classes[save_data[current_index].type];
	var page_data = page_class.classNode.new().serialize();
	
	for input in page_class.dependencies:
		read_input(input, page_data);
		
	save_data[current_index] = page_data;
	
	#Update the navbar in case of "Prev" being changed
	LinkBar.load_data(save_data);
	LinkBar.select(current_index);


# Fetches data from a JSON file
func load_from_json():
	var new_dict
	var dir = Directory.new()
	
	var file = File.new()
	file.open("res://VisualNovel/data.json", 3)
	#converts the json file to a text file
	var text_json = file.get_as_text()
	file.close()
#	print(text_json)
	#parses tect file to dictionary
	data_json = JSON.parse(text_json)
	#checks to make sure it parsed correctly
#	print(data_json)
	if data_json.error == OK:
#		print("All is good")
		pass
	else:
		alert("Error parsing JSON from file");
#		print(typeof(data_json.result))
#		print(data_json.get_error_line())
	if typeof(data_json.result) == TYPE_ARRAY:
#    	print("Array") # prints 'hello'
		pass
	else:
		alert("JSON data is not an array")

	save_data = data_json.result
	LinkBar.load_data(save_data);

# Writes save_data to a json file, and creates a backup too
func save_json():
	var dir = Directory.new()
	var file = File.new()
	
	#Save Backup
	var time = str(file.get_modified_time("res://VisualNovel/data.json"));
	dir.copy("res://VisualNovel/data.json", "res://VisualNovel/Backups/" + time +".json");	
	dir.remove("res://VisualNovel/data.json")
	
	var new_file = File.new()
	new_file.open("res://VisualNovel/data.json", 2)
	new_file.store_line(to_json(save_data))
	new_file.close();
	$SnackBar.activate("Successfully Saved!");

#Exit button
func _on_Button_pressed():
	get_tree().quit()

#Alert a message to the screen
func alert(message):
	$SnackBar.activate(message);

#Called when a new LinkBarItem (page) is clicked
#Updates the display
func on_selected(index):
	if index != current_index:
		current_index = index;
		update_options();
		
#Adds a new Page to the list of pages and updates the screen
func insert(id):
	var last_index = save_data.size();
#	This is a stupid way that allows us to use the Dictionary as if it was an array
#   Finds the class dictated by the order which the items were put in (key array order)
#   Then creates a new item and pushes it back
	save_data.push_back(classes[classes.keys()[id]].classNode.new(last_index, last_index+1).serialize())
			
	LinkBar.load_data(save_data);
	LinkBar.select(current_index);

#Deletes a Page from the list of pages, then updates the screen
func delete():
	if save_data.size() == 0: return;
	if current_index == -1: return;
	
	var old_id = save_data[current_index].id
	var old_next = save_data[current_index].next_id
	
	save_data.remove(current_index);
	current_index = -1;
	
	#TODO: implement switching of question related ids
	
	#Fix the the gap caused by the removed item 
	for item in save_data:
		if item.next_id == old_id:
			item.next_id = old_next;
	
	#Decrease all ids that were higher than the deleted one
	for item in save_data:
		if item.id > old_id:
			item.id-=1
		if item.next_id > old_id:
			item.next_id-=1
		
	#Now do the exact same thing for all answer choices
	for item in save_data:
		if item.get("answers"):
			for answer in item["answers"]:
				if answer.next_id == old_id:
					answer.next_id = old_next;
			for answer in item["answers"]:
				if answer.next_id > old_id:
					answer.next_id-=1
	
	LinkBar.load_data(save_data);
	update_options();
	
#A is before B
#Helper function for the up and down functions
func _adjacent_swap(before, afer):
	#Remove the target
	var temp = save_data[afer];
	save_data.remove(afer);
	save_data.insert(before, temp);
	
	#Save id data
	var actor_id = save_data[before].id;
	var victim_id = save_data[afer].id;
	var new_actor_id = actor_id-1;
	var new_victim_id = victim_id+1;
	
	#Update ids and all depentencies
	save_data[before].id = new_actor_id
	save_data[afer].id = new_victim_id
	
	for item in save_data:
		if item.next_id == actor_id:
			item.next_id = new_actor_id;
		elif item.next_id == victim_id:
			item.next_id = new_victim_id;
			
	# Do the exact same thing for the answers
	for item in save_data:
		if item.get("answers"):
			for answer in item["answers"]:
				if answer.next_id == actor_id:
					answer.next_id = new_actor_id;
				elif answer.next_id == victim_id:
					answer.next_id = new_victim_id;

#Called when up is pressed. Moves current page up
func up():
	if current_index == -1 or current_index == -0 : return;
	
	var target = current_index-1;
	_adjacent_swap(target, current_index);
	
	current_index -=1;
	LinkBar.load_data(save_data);
	LinkBar.select(current_index);
	update_options();

#Called when down is pressed. Moves current page down
func down():
	if current_index == -1 or current_index == save_data.size()-1 : return;
	
	var target = current_index+1;
	_adjacent_swap(current_index, target);
	
	current_index +=1;
	LinkBar.load_data(save_data);
	LinkBar.select(current_index);
	update_options();

func import(pages:Array):
	save_data = pages
	
	current_index = -1;
	LinkBar.load_data(save_data);
	LinkBar.select(current_index);
	update_options()

func _on_Import_pressed():
	$ImportMenu.reset();
	$ImportMenu.visible = true
	
