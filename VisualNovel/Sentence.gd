extends Node

class_name Sentence

var content : String
var sound : int
var speed : float
var delay : float

func _init(xcontent, xsound=Global.SoundEffect.NONE, xspeed=1, xdelay=0):
	content = xcontent;
	sound = xsound;
	speed = xspeed;
	delay = xdelay