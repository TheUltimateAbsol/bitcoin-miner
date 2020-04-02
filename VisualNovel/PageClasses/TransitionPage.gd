extends Page

class_name TransitionPage

var next_background:String
var next_music:String
var transition_type:String

func _init(xid=0, 
	xnext_id=0, 
	xnext_background=VNGlobal.Backgrounds.SAME,
	xnext_music=VNGlobal.Music.SAME,
	xtransition_type=VNGlobal.SceneTransitions.NONE).(xid, xnext_id):
		
#	THIS DESERIALIZES THE CLASS FROM A JSON TABLE
#	Note: Normally to do this, we would just make a separate
#   static function that acts like a constructor, returning a new instance
#   However, 3.1.2 currently doesn't allow for cyclic dependencies, so this
#   is our next best option :/
	if typeof(xid) == TYPE_DICTIONARY:
		var json_object = xid
		
		next_background= json_object.next_background
		next_music = json_object.next_music
		transition_type = json_object.transition_type;
		
	next_background=xnext_background
	next_music = xnext_music
	transition_type = xtransition_type;
	
func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"next_background": next_background,
		"next_music": next_music,
		"transition_type": transition_type,
		"type":"TransitionPage"
	});
