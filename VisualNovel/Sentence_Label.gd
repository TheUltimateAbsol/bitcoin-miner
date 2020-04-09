extends Control

onready var speed_input = $HBoxContainer/HBoxContainer/speed
onready var delay_input = $HBoxContainer/HBoxContainer/delay
onready var effect_input = $HBoxContainer/HBoxContainer/effect

var data:Dictionary

signal delete
signal updated

func _ready():
	for i in range (VNGlobal.SentenceSpeeds.keys().size()):
		speed_input.add_item(VNGlobal.SentenceSpeeds.keys()[i], i);
	for i in range (VNGlobal.DelayLengths.keys().size()):
		delay_input.add_item(VNGlobal.DelayLengths.keys()[i], i);
	for i in range (VNGlobal.Effects.keys().size()):
		effect_input.add_item(VNGlobal.Effects.keys()[i], i);

func set_data(xdata:Dictionary):
	data = xdata
	_load_data();
	
func _load_data():
	$HBoxContainer/Label.text = data.content;
	_string_select(speed_input, data.speed);
	_string_select(delay_input, data.delay);
	_string_select(effect_input, data.effect);

func _string_select(option_button, key):
	for i in range(option_button.get_item_count()):
		if option_button.get_item_text(i) == key:
			option_button.select(i);

func delete():
	emit_signal("delete");

func update():
	data.speed = speed_input.get_item_text(speed_input.get_selected_id())
	data.delay = delay_input.get_item_text(delay_input.get_selected_id())
	data.effect = effect_input.get_item_text(effect_input.get_selected_id())
	
	emit_signal("updated");


func _on_speed_item_selected(id):
	update()


func _on_delay_item_selected(id):
	update()


func _on_effect_item_selected(id):
	update()
