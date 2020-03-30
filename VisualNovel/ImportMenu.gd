extends Control

onready var text_edit = $VBoxContainer/MarginContainer/TextEdit
onready var error_messages = $VBoxContainer/ErrorPanel/VBoxContainer/ScrollContainer/PanelContainer/MarginContainer/VBoxContainer
onready var error_panel = $VBoxContainer/ErrorPanel
onready var success_panel = $VBoxContainer/SuccessPanel
onready var submit_button = $VBoxContainer/MarginContainer2/HBoxContainer/Submit
onready var parser = $Parser

onready var ErrorLink = preload("res://VisualNovel/ErrorLink.tscn")

var submitted_once = false

func _ready():
	reset();
	
func reset():
	submit_button.text = "Check!";
	text_edit.text = ""
	error_panel.visible = false
	submitted_once = false
	text_edit.readonly = false
	for child in error_messages.get_children():
		child.queue_free();
	text_edit.highlight_current_line = false;
	success_panel.visible = false
	text_edit.clear_colors();
	text_edit.add_color_region(">>>", "\n", Color.red, true);
	
func import_success():
	print("Import_success")
	
func goto_line(line):
	text_edit.cursor_set_line(line)
	text_edit.highlight_current_line = true;
	
func new_error_message(error):
	var temp = ErrorLink.instance()
	temp.text = String(error.line + 1) + ": " + error.message;
	temp.connect("pressed", self, "goto_line", [error.line ]);
	error_messages.add_child(temp);
	

func _on_Submit_pressed():
	if not submitted_once:
		submitted_once = true;
		parser.parse(text_edit.text);
		
		if parser.errors.size() == 0:
			success_panel.visible = true;
			text_edit.add_color_region("//", "\n", Color.darkgray, true);
			text_edit.add_color_region("@@", "\n", Color.yellow, true);
			submit_button.text = "Proceed!";
		else:
			var lines:PoolStringArray = parser.prepare_text(text_edit.text)
			for error in parser.errors:
				lines[error.line] = ">>>" + lines[error.line]
				new_error_message(error)
			
			text_edit.text = lines.join("\n");
			submit_button.text = "Proceed Anways!";
			error_panel.visible = true;
	else:
		$ConfirmationDialog.popup()


func _on_Cancel_pressed():
	visible = false;

func _on_ConfirmationDialog_confirmed():
	visible = false;
	get_parent().import(parser.pages);
