extends Page

class_name ContentPage

var content #array of Sentences
var character : int
var speed : float
var transition : int
var expression : int
var music : int
var background : int
var questions #array of strings + id leadsa	

func _init(xid, xnext_id, xcontent, xcharacter=Global.Characters.NONE, 
	xspeed=1, xtransition=Global.Transitions.NONE, 
	xexpression=Global.Expressions.DEFAULT, 
	xmusic=Global.Music.NONE, xbackground=Global.Background.NONE,
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