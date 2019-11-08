extends Control

onready var game = $PanelContainer/Panel/Node2D
onready var game_container = $PanelContainer

enum {VN, GAME, BOTH}
var state = VN;

func _ready():
	to_Game();
	pass
#	update_size();

func update_size():
	var margin_size = 40;
	print(game);
	print(game_container);
	var scale = int(($Game/PanelContainer.rect_size.y - margin_size)/144);
	$Game/PanelContainer/Panel/Node2D.stretch_shrink = scale;
	#$PanelContainer/Panel/Node2D.rect_min_size = scale*Vector2(160, 144);
	$Game/PanelContainer/Panel/Node2D.rect_size = scale*Vector2(160, 144);
	
func to_VN():
	if state == BOTH:
		$AnimationPlayer.play("Both to VN");
	if state == GAME:
		$AnimationPlayer.play_backwards("VN to Game");
	state = VN;
		
func to_Game():
	if state == BOTH:
		$AnimationPlayer.play("Both to Game");
	if state == VN:
		$AnimationPlayer.play("VN to Game");
	state = GAME
	
func to_Both():
	if state == VN:
		$AnimationPlayer.play_backwards("Both to VN");
	if state == GAME:
		$AnimationPlayer.play_backwards("Both to Game");
	state = BOTH
	
	
