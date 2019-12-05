extends Control

# parse buttons
onready var preview_btn = get_node("Panel/HBoxContainer/Layout/preview_btn")

onready var reader = $Panel/HBoxContainer/VNReader

var page_data
var data_json
var save_data : Array

# Called when the node enters the scene tree for the first time.
func _ready():	
	load_from_json();

func preview_scene():
	update_page()
	reader.play_page(page_data)

static func merge_dir(target, patch):
    for key in patch:
        if target.has(key):
            var tv = target[key]
            if typeof(tv) == TYPE_DICTIONARY:
                merge_dir(tv, patch[key])
            else:
                target[key] = patch[key]
        else:
            target[key] = patch[key]
		
# gets the ids for the page and the id of the page that will follow it
func update_page():
	page_data={"speed": 1.0}
	
	merge_dir(page_data, $Panel/HBoxContainer/Layout/IdInput.get_data());
	merge_dir(page_data, $Panel/HBoxContainer/Layout/SentenceInput.get_data());
	merge_dir(page_data, $Panel/HBoxContainer/Layout/SceneInput.get_data());
	merge_dir(page_data, $Panel/HBoxContainer/Layout/CharacterInput.get_data());

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
		print("All is good")
	else:
		print("something is wrong")
		print(typeof(data_json.result))
		print(data_json.get_error_line())
	print("checkpoint 1")
	if typeof(data_json.result) == TYPE_ARRAY:
    	print("Array") # prints 'hello'
	else:
    	print("unexpected results")
	print("checkpoint 2")

	
	$Panel/HBoxContainer/VBoxContainer/LinkBar.load_data(data_json.result);

func save_json():
	var dir = Directory.new()
	var file = File.new()
	
	#Save Backup
	var time = str(file.get_modified_time("res://VisualNovel/data.json"));
	dir.copy("res://VisualNovel/data.json", "res://VisualNovel/Backups/" + time +".json");	
	dir.remove("res://VisualNovel/data.json")
	
	var new_file = File.new()
	new_file.open("res://VisualNovel/data.json", 2)
	new_file.store_line(to_json([page_data]))
	new_file.close();
	$SnackBar.activate("Successfully Saved!");

func _on_Button_pressed():
	get_tree().quit()
