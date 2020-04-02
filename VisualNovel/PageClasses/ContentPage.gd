extends Page

class_name ContentPage

var content:Array #array of Sentences
var character_image:String
var character_transition:String
var character_expression:String
var speaker_name:String
var is_thought:bool

func _init(xid=0, 
	xnext_id=0, 
	xcontent=[], 
	xcharacter_image=VNGlobal.Characters.NONE, 
	xcharacter_expression=VNGlobal.Expressions.DEFAULT, 
	xcharacter_transition=VNGlobal.CharacterTransitions.NONE,
	xspeaker_name="",
	xis_thought = false).(xid, xnext_id):
		
#	THIS DESERIALIZES THE CLASS FROM A JSON TABLE
#	Note: Normally to do this, we would just make a separate
#   static function that acts like a constructor, returning a new instance
#   However, 3.1.2 currently doesn't allow for cyclic dependencies, so this
#   is our next best option :/
	if typeof(xid) == TYPE_DICTIONARY:
		var json_object = xid
		var sentences = [];
		for sentence in json_object["content"] :
			sentences.push_back(Sentence.new(sentence["content"], sentence["speed"], sentence["delay"], sentence["effect"]));
		
		xcontent = sentences
		xcharacter_image = json_object["character_image"]
		xcharacter_expression = json_object["character_expression"]
		xcharacter_transition = json_object["character_transition"]
		xspeaker_name = json_object["speaker_name"]
		xis_thought = json_object["is_thought"]
		
	content = xcontent;
	character_image = xcharacter_image;
	character_transition = xcharacter_transition
	character_expression = xcharacter_expression
	speaker_name = ""
	is_thought = false
	
func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"content": content,
		"character_image": character_image,
		"character_transition": character_transition,
		"character_expression": character_expression,
		"speaker_name" : speaker_name,
		"is_thought": is_thought,
		"type" : "ContentPage"
	});
