extends Control

# parse buttons
onready var preview_btn = $Panel/HBoxContainer/Layout/preview_btn
onready var update_btn = $Panel/HBoxContainer/Layout/update_btn
onready var reader = $Panel/HBoxContainer/VNReader
onready var insert_btn = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/New

onready var idInput = $Panel/HBoxContainer/Layout/IdInput
onready var sentenceInput = $Panel/HBoxContainer/Layout/SentenceInput
onready var sceneInput = $Panel/HBoxContainer/Layout/SceneInput
onready var characterInput = $Panel/HBoxContainer/Layout/CharacterInput
onready var directoryInput = $Panel/HBoxContainer/Layout/DirectoryInput

enum {CONTENT_PAGE, GAME_START_PAGE, GAME_END_PAGE, END_PAGE}

var data_json
var save_data : Array
var current_index = -1;

func update_options():
	idInput.hide();
	sentenceInput.hide()
	sceneInput.hide()
	characterInput.hide()
	directoryInput.hide();
	preview_btn.hide();
	update_btn.hide();
		
	if current_index == -1:
		return
	
	#if a content page
	match (save_data[current_index].type):
		"ContentPage":
			idInput.show();
			sentenceInput.show()
			sceneInput.show()
			characterInput.show()
			preview_btn.show();
			
			var page_data = save_data[current_index];
			idInput.load_data(page_data["id"], page_data["next_id"]);
			sentenceInput.load_data(page_data["content"]);
			sceneInput.load_data(page_data["music"], page_data["background"], page_data["scene_transition"]);
			characterInput.load_data(page_data["character"], page_data["background"], page_data["scene_transition"]);
		
		"GameStartPage":
			idInput.show();
			directoryInput.show();
			update_btn.show();
			
			var page_data = save_data[current_index];
			idInput.load_data(page_data["id"], page_data["next_id"]);
			directoryInput.load_data(page_data["game_dir"]);
		
		"GameEndPage":
			idInput.show();
			update_btn.show();
			
			var page_data = save_data[current_index];
			idInput.load_data(page_data["id"], page_data["next_id"]);
		"EndPage":
			var page_data = save_data[current_index];
			idInput.show();
			update_btn.show();
			idInput.load_data(page_data["id"], page_data["next_id"]);
			
			
			

# Called when the node enters the scene tree for the first time.
func _ready():	
	insert_btn.get_popup().add_item("ContentPage", CONTENT_PAGE);
	insert_btn.get_popup().add_item("GameStartPage", GAME_START_PAGE);
	insert_btn.get_popup().add_item("GameEndPage", GAME_END_PAGE);
	insert_btn.get_popup().add_item("EndPage", END_PAGE);
	insert_btn.get_popup().connect("id_pressed", self, "insert");

	load_from_json();
	update_options()

func preview_scene():
	update_page()
	reader.play_json(save_data[current_index])
		
# gets the ids for the page and the id of the page that will follow it
func update_page():
	var page_data={};
	
	match (save_data[current_index].type):
		"ContentPage":
			page_data=ContentPage.new().serialize();
			VNGlobal.merge_dir(page_data, idInput.get_data());
			VNGlobal.merge_dir(page_data, sentenceInput.get_data());
			VNGlobal.merge_dir(page_data, sceneInput.get_data());
			VNGlobal.merge_dir(page_data, characterInput.get_data());
		"GameStartPage":
			page_data=GameStartPage.new().serialize();
			VNGlobal.merge_dir(page_data, idInput.get_data());
			VNGlobal.merge_dir(page_data, directoryInput.get_data());
		"GameEndPage":
			page_data=GameStartPage.new().serialize();
			VNGlobal.merge_dir(page_data, idInput.get_data());
		"GameEndPage":
			page_data=GameStartPage.new().serialize();
			VNGlobal.merge_dir(page_data, idInput.get_data());
			
		
	save_data[current_index] = page_data;
	
	#Update the navbar in case of "Prev" being changed
	$Panel/HBoxContainer/VBoxContainer/LinkBar.load_data(save_data);
	$Panel/HBoxContainer/VBoxContainer/LinkBar.select(current_index);

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
	print(data_json)
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
	$Panel/HBoxContainer/VBoxContainer/LinkBar.load_data(save_data);

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

func _on_Button_pressed():
	get_tree().quit()

func alert(message):
	$SnackBar.activate(message);

func on_selected(index):
	if index != current_index:
		current_index = index;
		update_options();
		
func insert(id):
	var last_index = save_data.size();
				
	match (id):
		CONTENT_PAGE:
			save_data.push_back(ContentPage.new(last_index, last_index+1).serialize());
		GAME_START_PAGE:
			save_data.push_back(GameStartPage.new(last_index, last_index+1).serialize());
		GAME_END_PAGE:
			save_data.push_back(GameEndPage.new(last_index, last_index+1).serialize());
		END_PAGE:
			save_data.push_back(EndPage.new(last_index, last_index+1).serialize());
			
	$Panel/HBoxContainer/VBoxContainer/LinkBar.load_data(save_data);
	$Panel/HBoxContainer/VBoxContainer/LinkBar.select(current_index);

	
func delete():
	if save_data.size() == 0: return;
	if current_index == -1: return;
	
	save_data.remove(current_index);
	current_index = -1;
	
	$Panel/HBoxContainer/VBoxContainer/LinkBar.load_data(save_data);
	update_options();
	
#A is before B
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

func up():
	if current_index == -1 or current_index == -0 : return;
	
	var target = current_index-1;
	_adjacent_swap(target, current_index);
	
	current_index -=1;
	$Panel/HBoxContainer/VBoxContainer/LinkBar.load_data(save_data);
	$Panel/HBoxContainer/VBoxContainer/LinkBar.select(current_index);
	update_options();
	
func down():
	if current_index == -1 or current_index == save_data.size()-1 : return;
	
	var target = current_index+1;
	_adjacent_swap(current_index, target);
	
	current_index +=1;
	$Panel/HBoxContainer/VBoxContainer/LinkBar.load_data(save_data);
	$Panel/HBoxContainer/VBoxContainer/LinkBar.select(current_index);
	update_options();
