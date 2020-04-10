extends ConditionalBranchPage

class_name RelationshipBranchPage

var character:String
var check_type:String
var value:int #our threshold

func _init(xid=0, xnext_id=0, xtarget_id=0,
	xcharacter=VNGlobal.Characters.NONE,
	xcheck_type=VNGlobal.CheckTypes.EQUAL,
	xvalue=0).(xid, xnext_id, xtarget_id):
			
#	THIS DESERIALIZES THE CLASS FROM A JSON TABLE
#	Note: Normally to do this, we would just make a separate
#   static function that acts like a constructor, returning a new instance
#   However, 3.1.2 currently doesn't allow for cyclic dependencies, so this
#   is our next best option :/
	if typeof(xid) == TYPE_DICTIONARY:
		var json_object = xid
		xcharacter = json_object.character
		xvalue = json_object.value
		xcheck_type = json_object.check_type
		
	character = xcharacter;
	value = xvalue;
	check_type = xcheck_type
	
func should_branch():
	var to_compare = SaveData.relationships[character]
	match(check_type):
		VNGlobal.CheckTypes.EQUAL:
			return to_compare == value;
		VNGlobal.CheckTypes.NOT:
			return to_compare != value;
		VNGlobal.CheckTypes.LESSTHAN:
			return to_compare < value;
		VNGlobal.CheckTypes.LESSTHANEQ:
			return to_compare <= value;
		VNGlobal.CheckTypes.GREATERTHAN:
			return to_compare > value;
		VNGlobal.CheckTypes.GREATERTHANEQ:
			return to_compare >= value;

func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"character":character,
		"value":value,
		"check_type":check_type,
		"type" : "RelationshipBranchPage"
	});
