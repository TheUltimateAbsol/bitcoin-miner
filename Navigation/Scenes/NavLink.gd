extends Node

class_name NavLink

var type : int
var dest_id : int
var link_score : int
var jump_height : int
var jump_speed : int

func init(dest : int, score : int, typ = Global.NavLinkTypes.NONE, jmp = 0, jmpspd = 0):
	dest_id = dest;
	link_score = score
	type = typ
	jump_height = jmp
	jump_speed = jmpspd
	
func set_type(typ = Global.NavLinkTypes.NONE, jmp = 0, jmpspd = 0):
	type = typ
	jump_height = jmp
	jump_speed = jmpspd

