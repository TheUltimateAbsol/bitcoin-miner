extends Node

class_name VNlinkbarItem

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var type
var id
var next
var text
# Called when the node enters the scene tree for the first time.
func _init(xtype, xid, xnext, xtext):
	type = xtype
	id = xid
	next = xnext
	text = xtext

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
