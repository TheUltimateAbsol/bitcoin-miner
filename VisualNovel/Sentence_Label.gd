extends Control

signal delete

func set_text(text):
	$Label.text = text;

func delete():
	emit_signal("delete");