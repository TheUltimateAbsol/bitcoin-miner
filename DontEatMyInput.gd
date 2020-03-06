extends Node

# Note: this doesn't work on children added during runtime :(

func _ready():
	make_inputtable(get_tree().get_root().get_node("Control2"));
	
func make_inputtable(node : Node):
	for N in node.get_children():
		if N is Control:
			N.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if N.get_child_count() > 0:
			make_inputtable(N)
			