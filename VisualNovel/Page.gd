extends Node

class_name Page

var id : int
var next_id : int

func _init(xid=0, xnext_id=0):
	id = xid
	next_id = xnext_id
	
func serialize():
	return {
		"id" : id,
		"next_id" : next_id,
		"type" : "Page"
	}