extends Node

class_name NavLink

var type : int
var src_id : int
var dest_id : int
var link_score : float
var init_velocity : Vector2
var src_location : Vector2
var dest_location : Vector2

func to_relative(point : Vector2):
	return point*8 + Vector2(4, 4);
func to_global(point: Vector2):
	return to_relative(point) + Vector2(0,8);

func _init(src, dest, score : float, typ = Global.NavLinkTypes.NONE, velocity=Vector2(0,0)):
	src_id = src.index
	dest_id = dest.index;
	link_score = score
	type = typ
	init_velocity = velocity
	src_location = to_global(src.location);
	dest_location = to_global(dest.location);
	

