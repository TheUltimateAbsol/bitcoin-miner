extends Control

onready var next_id_input = $HBoxContainer/HBoxContainer/next_id_input

var next_id;

signal delete
signal updated

func set_data(answer_name, xnext_id):
	$HBoxContainer/Label.text = answer_name
	next_id_input.value = xnext_id;
	next_id = xnext_id;

func delete():
	emit_signal("delete");

func update():
	emit_signal("updated");

func _on_next_id_input_value_changed(value):
	next_id = value;
	update();
