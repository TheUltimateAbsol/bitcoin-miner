extends InputBase

onready var image_list = $VBoxContainer2/HBoxContainer/image_input
onready var show_input = $VBoxContainer2/HBoxContainer/HBoxContainer/show_input

func _ready():
	for i in range (VNGlobal.Images.keys().size()):
		image_list.add_item(VNGlobal.Images.keys()[i], i);

func _string_select(option_button, key):
	for i in range(option_button.get_item_count()):
		if option_button.get_item_text(i) == key:
			option_button.select(i);

func get_data():
	var image = image_list.get_item_text(image_list.get_selected_id())
	var show = show_input.pressed
	
	return {
		"image": image,
		"show": show
	};
	
func load_data(page_data):
	_string_select(image_list, page_data.image);
	show_input.pressed = page_data.show

func _on_show_input_toggled(button_pressed):
	update();

func _on_image_input_item_selected(id):
	update()
