extends Page

class_name QuestionPage


var answers #array of strings + id lead


func _init(xid=0, xnext_id=0, xanswers=[]).(xid, xnext_id):
		
#	THIS DESERIALIZES THE CLASS FROM A JSON TABLE
#	Note: Normally to do this, we would just make a separate
#   static function that acts like a constructor, returning a new instance
#   However, 3.1.2 currently doesn't allow for cyclic dependencies, so this
#   is our next best option :/
	if typeof(xid) == TYPE_DICTIONARY:
		var json_object = xid
		xanswers = json_object["answers"]
		
	answers = xanswers

func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"answers": answers,
		"type" : "QuestionPage"
	});
	
