extends Node

class_name Sentence

var content : String
var effect : String
var speed : String
var delay : String

func _init(xcontent, 
	xspeed=VNGlobal.SentenceSpeeds.DEFAULT,
	xdelay=VNGlobal.DelayLengths.DEFAULT, 
	xeffect= VNGlobal.Effects.NONE):
		
	content = xcontent;
	effect = xeffect;
	speed = xspeed;
	delay = xdelay;
	
func serialize():
	return {
		"content" : content, 
		"delay": delay, 
		"speed" : speed, 
		"effect" : effect
	};
