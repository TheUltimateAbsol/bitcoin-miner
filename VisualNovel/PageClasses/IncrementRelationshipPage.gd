extends MetaPage

class_name IncrementRelationshipPage

var character:String #The page we jump to if the condition is met
var value:int #

func _init(xid=0, xnext_id=0, xcharacter=VNGlobal.Characters.NONE, xvalue=1).(xid, xnext_id):
			
#	THIS DESERIALIZES THE CLASS FROM A JSON TABLE
#	Note: Normally to do this, we would just make a separate
#   static function that acts like a constructor, returning a new instance
#   However, 3.1.2 currently doesn't allow for cyclic dependencies, so this
#   is our next best option :/
	if typeof(xid) == TYPE_DICTIONARY:
		var json_object = xid
		xcharacter = json_object.character
		xvalue = json_object.value
		
	character = xcharacter;
	value = xvalue;
	
func activate():
	SaveData.increment_relationship(character, value);

func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"character":character,
		"value":value,
		"type" : "IncrementRelationshipPage"
	});
