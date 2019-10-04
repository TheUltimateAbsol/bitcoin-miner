extends Node

class_name NavPoint	

var index : int
var platform_index: int
var location : Vector2
var navLinks = [] #NavLink class
var type : int #enum types

func _init(loc:Vector2, ind: int, typ: int = Global.NavPointTypes.NONE, plt_ind : int = -1): 
	location = loc
	index = ind
	platform_index = plt_ind
	type = typ
	
func set_type(typ: int = Global.NavPointTypes.NONE, plt_ind : int = -1):
	platform_index = plt_ind
	type = typ
	
#links a navpoint with another navpoint
#the link is given to the calling navpoint
func link(tar : NavPoint, score : float, typ = Global.NavLinkTypes.NONE, velocity=Vector2(0,0)):
	var my_link : NavLink = NavLink.new(index, tar, score, typ, velocity)
	navLinks.append(my_link);
