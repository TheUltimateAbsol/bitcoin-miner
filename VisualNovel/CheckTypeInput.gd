extends InputBase

onready var check_type_list = $VBoxContainer2/check_type_input

func _ready():
	for i in range (VNGlobal.CheckTypeSymbols.values().size()):
		check_type_list.add_item(VNGlobal.CheckTypeSymbols.values()[i], i);

func _string_select(option_button, key):
	for i in range(option_button.get_item_count()):
		if option_button.get_item_text(i) == key:
			option_button.select(i);

func convert_symbol(symbol):
	var check_type = "";
	for key in VNGlobal.CheckTypeSymbols.keys():
		if VNGlobal.CheckTypeSymbols[key] == symbol:
			return VNGlobal.CheckTypes[key];
	
	push_error("Invalid Checktype symbol");
	return null;

func get_data():
	var check_type = convert_symbol(check_type_list.get_item_text(check_type_list.get_selected_id()))
	
	return {
		"check_type": check_type
	};
	
func load_data(page_data):
	_string_select(check_type_list, VNGlobal.CheckTypeSymbols[page_data.check_type]);


func _on_check_type_input_item_selected(id):
	update()
