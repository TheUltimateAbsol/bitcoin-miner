extends InputBase

onready var background_list = $VBoxContainer2/Row/background_input
onready var music_list = $VBoxContainer2/Row2/music_input
onready var transition_type_list = $VBoxContainer2/Row3/transition_input

func _ready():
	for i in range (VNGlobal.Backgrounds.keys().size()):
		background_list.add_item(VNGlobal.Backgrounds.keys()[i], i);
	for i in range (VNGlobal.Music.keys().size()):
		music_list.add_item(VNGlobal.Music.keys()[i], i);
	for i in range (VNGlobal.SceneTransitions.keys().size()):
		transition_type_list.add_item(VNGlobal.SceneTransitions.keys()[i], i);
	
	
func _string_select(option_button, key):
	for i in range(option_button.get_item_count()):
		if option_button.get_item_text(i) == key:
			option_button.select(i);

func get_data():
	var next_background = background_list.get_item_text(background_list.get_selected_id())
	var next_music = music_list.get_item_text(music_list.get_selected_id())
	var transition_type = transition_type_list.get_item_text(transition_type_list.get_selected_id())
		
	return {
		"next_background": next_background,
		"next_music": next_music,
		"transition_type": transition_type
	};
	
func load_data(page_data):
	_string_select(background_list, page_data.next_background);
	_string_select(music_list, page_data.next_music);
	_string_select(transition_type_list, page_data.transition_type);


func _on_background_input_item_selected(id):
	update();


func _on_music_input_item_selected(id):
	update();


func _on_transition_input_item_selected(id):
	update();
