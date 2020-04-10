extends MetaPage

class_name SetFlagPage

var flag:String #The page we jump to if the condition is met
var value:bool

func _init(xid=0, xnext_id=0, xflag="FLAG_NAME", xvalue=true).(xid, xnext_id):
			
#	THIS DESERIALIZES THE CLASS FROM A JSON TABLE
#	Note: Normally to do this, we would just make a separate
#   static function that acts like a constructor, returning a new instance
#   However, 3.1.2 currently doesn't allow for cyclic dependencies, so this
#   is our next best option :/
	if typeof(xid) == TYPE_DICTIONARY:
		var json_object = xid
		xflag = json_object.flag
		xvalue = json_object.value
		
	flag = xflag;
	value = xvalue;
	
# To be implemented by descendants
func activate():
	SaveData.set_flag(flag, true);

func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"flag":flag,
		"value":value,
		"type" : "SetFlagPage"
	});
