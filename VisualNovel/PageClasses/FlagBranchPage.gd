extends ConditionalBranchPage

class_name FlagBranchPage

var flag:String

func _init(xid=0, xnext_id=0, xtarget_id=0, xflag="FLAG_NAME").(xid, xnext_id, xtarget_id):
			
#	THIS DESERIALIZES THE CLASS FROM A JSON TABLE
#	Note: Normally to do this, we would just make a separate
#   static function that acts like a constructor, returning a new instance
#   However, 3.1.2 currently doesn't allow for cyclic dependencies, so this
#   is our next best option :/
	if typeof(xid) == TYPE_DICTIONARY:
		var json_object = xid
		xflag = json_object.flag
		
	flag = xflag;
	
# To be implemented by descendants
func should_branch():
	return SaveData.get_flag_value(flag);

func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"flag":flag,
		"type":"FlagBranchPage"
	});
