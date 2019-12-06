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

func _init(xid=0, 
	xnext_id=0, 
	xcontent=[], 
	xcharacter=VNGlobal.Characters.NONE, 
	xexpression=VNGlobal.Expressions.DEFAULT, 
	xtransition=VNGlobal.Transitions.NONE, 
	xbackground=VNGlobal.Backgrounds.NONE,
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
	
func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"content": content,
		"character": character,
		"speed": speed,
		"scene_transition": transition,
		"expression": expression,
		"music": music,
		"background": background,
		"questions": questions,
		"type" : "ContentPage"
	});
