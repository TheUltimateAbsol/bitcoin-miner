extends Node

class_name NavLink

var type : int
var src_id : int
var dest_id : int
var link_score : int
var init_velocity : Vector2

func _init(src : int, dest : int, score : int, typ = Global.NavLinkTypes.NONE, velocity=Vector2(0,0)):
	src_id = src
	dest_id = dest;
	link_score = score
	type = typ
	init_velocity = velocity

