extends Node

class_name Answer

var content : String
var next_id


func _init(xcontent, xnext_id):
	content = xcontent;
	next_id = xnext_id

# Called when the node enters the scene tree for the first time.
func serialize():
	return {
		"content" : content, 
		"next_id": next_id
	};
