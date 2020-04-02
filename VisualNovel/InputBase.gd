extends PanelContainer

class_name InputBase

signal changed

#Placeholder template functions
func load_data(page_data):
	pass
func get_data():
	pass

func update():
#	Brandon's #1 cheating method for avoiding double update calls
#	:))))
	if visible == false: return;
	emit_signal("changed");
