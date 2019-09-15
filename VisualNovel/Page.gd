extends Node

class_name Page

var id : int
var next_id : int

func _init_custom(xid, xnext_id):
	id = xid
	next_id = xnext_id