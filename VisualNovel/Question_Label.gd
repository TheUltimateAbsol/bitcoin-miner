extends Control

signal delete

func set_text(text):
	$Label.text = text;
	
func set_id(next_id):
	var id_label = $Label2
	id_label.text = str(next_id)

func delete():
	emit_signal("delete");