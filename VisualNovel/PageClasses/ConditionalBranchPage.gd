extends MetaPage

class_name ConditionalBranchPage

var target_id:int #The page we jump to if the condition is met

func _init(xid=0, xnext_id=0, xtarget_id=0).(xid, xnext_id):
			
#	THIS DESERIALIZES THE CLASS FROM A JSON TABLE
#	Note: Normally to do this, we would just make a separate
#   static function that acts like a constructor, returning a new instance
#   However, 3.1.2 currently doesn't allow for cyclic dependencies, so this
#   is our next best option :/
	if typeof(xid) == TYPE_DICTIONARY:
		var json_object = xid
		xtarget_id = xid.target_id
		
	target_id = xtarget_id;
	
# To be implemented by descendants
func should_branch():
	return false;

func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"target_id":target_id,
		"type" : "ConditionalBranchPage"
	});
