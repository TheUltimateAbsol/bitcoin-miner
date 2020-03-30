extends Node

class_name Sentence

var content : String
var sound
var speed
var delay : float

func _init(xcontent, xdelay=VNGlobal.DEFAULT_SENTENCE_DELAY, xsound= VNGlobal.SoundEffect.NONE, xspeed=1.0):
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
