extends VSplitContainer

onready var game = $PanelContainer/Panel/Node2D
onready var game_container = $PanelContainer

func _ready():
	pass
#	update_size();

func update_size():
	var margin_size = 40;
	print(game);
	print(game_container);
	var scale = int(($PanelContainer.rect_size.y - margin_size)/144);
	$PanelContainer/Panel/Node2D.stretch_shrink = scale;
	$PanelContainer/Panel/Node2D.rect_min_size = scale*Vector2(160, 144);
	$PanelContainer/Panel/Node2D.rect_size = scale*Vector2(160, 144);