extends Node

class_name Page

var id : int
var next_id : int

func _init(xid=0, xnext_id=0):
	
#	THIS DESERIALIZES THE CLASS FROM A JSON TABLE
#	Note: Normally to do this, we would just make a separate
#   static function that acts like a constructor, returning a new instance
#   However, 3.1.2 currently doesn't allow for cyclic dependencies, so this
#   is our next best option :/
	if typeof(xid) == TYPE_DICTIONARY:
		var json_object = xid
		xid = json_object["id"]
		xnext_id = json_object["next_id"]
		
	id = xid
	next_id = xnext_id
	
func serialize():
	return {
		"id" : id,
		"next_id" : next_id,
		"type" : "Page"
	}