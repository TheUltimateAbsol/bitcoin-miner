extends Control

onready var game = $PanelContainer/Panel/Node2D
onready var game_container = $PanelContainer

enum {VN, GAME, BOTH}
var state = VN;

func _ready():
#	to_Game(true);
	pass
#	update_size();

func update_size():
	var margin_size = 40;
	print(game);
	print(game_container);
	var scale = int(($Game/PanelContainer.rect_size.x - margin_size)/160);
	$Game/PanelContainer/Panel/Node2D.stretch_shrink = scale;
	#$PanelContainer/Panel/Node2D.rect_min_size = scale*Vector2(160, 144);
	$Game/PanelContainer/Panel/Node2D.rect_size = scale*Vector2(160, 144);
	pass
	
func to_VN(instant=false):
	if state == BOTH:
		$AnimationPlayer.play("Both to VN");
	elif state == GAME:
		$AnimationPlayer.play_backwards("VN to Game");
	else:
		return;
	state = VN;
	if instant:
		$AnimationPlayer.seek(1, true);
		$AnimationPlayer.stop();
		
func to_Game(instant=false):
	if state == BOTH:
		$AnimationPlayer.play("Both to Game");
	elif state == VN:
		$AnimationPlayer.play("VN to Game");
	else:
		return;
	state = GAME
	
	if instant:
		$AnimationPlayer.seek(1, true);
		$AnimationPlayer.stop();
	
func to_Both(instant=false):
	if state == VN:
		$AnimationPlayer.play_backwards("Both to VN");
	elif state == GAME:
		$AnimationPlayer.play_backwards("Both to Game");
	else:
		return;
	state = BOTH
	
	if instant:
		$AnimationPlayer.seek(1, true);
		$AnimationPlayer.stop();
