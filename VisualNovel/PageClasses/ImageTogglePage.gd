extends Page

class_name ImageTogglePage

var image:String #what image is being shown
var show:bool #whether to show or remove it. You can have multiple images

func _init(xid=0, 
	xnext_id=0, 
	ximage=VNGlobal.Images.LETTER,
	xshow=true).(xid, xnext_id):
		
#	THIS DESERIALIZES THE CLASS FROM A JSON TABLE
#	Note: Normally to do this, we would just make a separate
#   static function that acts like a constructor, returning a new instance
#   However, 3.1.2 currently doesn't allow for cyclic dependencies, so this
#   is our next best option :/
	if typeof(xid) == TYPE_DICTIONARY:
		var json_object = xid
			
		ximage=json_object.image
		xshow = json_object.show
		
	image=ximage
	show=xshow
	
func serialize():
	return VNGlobal.merge_dir(.serialize(), {
		"image": image,
		"show": show,
		"type":"ImageTogglePage"
	});
