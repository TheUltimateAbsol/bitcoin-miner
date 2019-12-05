extends Page

class_name ContentPage

var content #array of Sentences
var character
var speed 
var transition
var expression
var music
var background
var questions #array of strings + id leadsa	

func _init(xid, xnext_id, xcontent, xcharacter=VNGlobal.Characters.NONE, 
	xexpression=VNGlobal.Expressions.DEFAULT, xtransition=VNGlobal.Transitions.NONE, xbackground=VNGlobal.Backgrounds.NONE,
	xspeed=1, 
	xmusic=VNGlobal.Music.NONE, 
	xquestions=[]).(xid, xnext_id):
		
#	._init_custom(id, next_id);
	content = xcontent;
	character = xcharacter;
	speed = xspeed;
	transition = xtransition
	expression = xexpression
	music = xmusic
	background = xbackground
	questions = xquestions
	