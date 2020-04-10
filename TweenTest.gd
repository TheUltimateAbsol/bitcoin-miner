extends TextureRect

func _ready():
	print("hi");
	$Tween.interpolate_property(self, "rect_position", Vector2(0,0), Vector2(500,500), 2, Tween.TRANS_LINEAR, Tween.EASE_IN);
	$Tween.start();
