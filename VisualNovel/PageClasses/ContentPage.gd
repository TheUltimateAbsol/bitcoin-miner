extends Page

class_name ContentPage

var content #array of Sentences
var character
var speed 
var transition
var expression
var music
var background
#var questions #array of strings + id leadsa	

func _init(xid=0, 
	xnext_id=0, 
	xcontent=[], 
	xcharacter=VNGlobal.Characters.NONE, 
	xexpression=VNGlobal.Expressions.DEFAULT, 
	xtransition=VNGlobal.Transitions.NONE, 
	xbackground=VNGlobal.Backgrounds.NONE,
	xspeed=1, 
	xmusic=VNGlobal.Music.NONE):
	#xquestions=[]).(xid, xnext_id):
		
#	THIS DESERIALIZES THE CLASS FROM A JSON TABLE
#	Note: Normally to do this, we would just make a separate
#   static function that acts like a constructor, returning a new instance
#   However, 3.1.2 currently doesn't allow for cyclic dependencies, so this
#   is our next best option :/
	if typeof(xid) == TYPE_DICTIONARY:
		var json_object = xid
		var sentences = [];
		for sentence in json_object["content"] :
			sentences.push_back(Sentence.new(sentence["content"], sentence["speed"], sentence["sound"]));
		
		xcontent = sentences
		xcharacter = json_object["character"]
		xexpression = json_object["expression"]
		xtransition = json_object["scene_transition"]
		xbackground = json_object["background"]
		xspeed = json_object["speed"]
#		xmusic = json_object["music"]
#		xquestions = json_object["questions"]
		
	content = xcontent;
	character = xcharacter;
	speed = xspeed;
	transition = xtransition
	expression = xexpression
	music = xmusic
	background = xbackground
	#questions = xquestions
	
func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"content": content,
		"character": character,
		"speed": speed,
		"scene_transition": transition,
		"expression": expression,
		"music": music,
		"background": background,
		#"questions": questions,
		"type" : "ContentPage"
	});
