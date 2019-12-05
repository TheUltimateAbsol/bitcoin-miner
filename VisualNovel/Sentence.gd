extends Node

class_name Sentence

var content : String
var sound
var speed
var delay : float

func _init(xcontent, xdelay=0, xsound= VNGlobal.SoundEffect.NONE, xspeed=1):
	content = xcontent;
	sound = xsound;
	speed = xspeed;
	delay = xdelay
	
func serialize():
	return {
		"content" : content, 
		"delay": delay, 
		"speed" : speed, 
		"sound" : sound
	};