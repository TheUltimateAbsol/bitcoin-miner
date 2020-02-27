extends MetaPage

class_name GameStartPage

var game_dir

func _init(xid=0, xnext_id=0, xgame_dir="").(xid, xnext_id):
	
#	THIS DESERIALIZES THE CLASS FROM A JSON TABLE
#	Note: Normally to do this, we would just make a separate
#   static function that acts like a constructor, returning a new instance
#   However, 3.1.2 currently doesn't allow for cyclic dependencies, so this
#   is our next best option :/
	if typeof(xid) == TYPE_DICTIONARY:
		var json_object = xid
		xgame_dir = json_object["game_dir"]
	
	game_dir = xgame_dir
	pass;
	
func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"game_dir": game_dir,
		"type" : "GameStartPage"
	});
	
