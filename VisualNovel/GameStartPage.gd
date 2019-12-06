extends MetaPage

class_name GameStartPage

var game_dir

func _init(xid=0, xnext_id=0, xgame_dir="").(xid, xnext_id):
	game_dir = xgame_dir
	pass;
	
func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"game_dir": game_dir,
		"type" : "GameStartPage"
	});
	
