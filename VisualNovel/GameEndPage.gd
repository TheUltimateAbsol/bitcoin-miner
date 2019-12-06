extends MetaPage

class_name GameEndPage

func _init(xid=0, xnext_id=0).(xid, xnext_id):
	pass;

func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"type" : "GameEndPage"
	});
	