extends Control

onready var game_logic = $Game/PanelContainer/Panel/Node2D/Viewport/Game

enum {VN, GAME, BOTH}
var state = GAME;

func _ready():
	to_VN(true);
#	update_size();

func update_size():
	var margin_size = 40;
	var scale = int(($Game/PanelContainer.rect_size.x - margin_size)/160);
	$Game/PanelContainer/Panel/Node2D.stretch_shrink = scale;
	#$PanelContainer/Panel/Node2D.rect_min_size = scale*Vector2(160, 144);
	$Game/PanelContainer/Panel/Node2D.rect_size = scale*Vector2(160, 144);
	pass
	
func to_VN(instant=false):
	if state == BOTH:
		$AnimationPlayer.play("Both to VN");
		if instant:
			$AnimationPlayer.seek(1, true);
			$AnimationPlayer.stop();
	elif state == GAME:
		$AnimationPlayer.play_backwards("VN to Game");
		if instant:
			$AnimationPlayer.seek(0, true);
			$AnimationPlayer.stop();
	else:
		return;
	state = VN;

		
func to_Game(instant=false):
	if state == BOTH:
		$AnimationPlayer.play("Both to Game");
		if instant:
			$AnimationPlayer.seek(1, true);
			$AnimationPlayer.stop();
	elif state == VN:
		$AnimationPlayer.play("VN to Game");
		if instant:
			$AnimationPlayer.seek(1, true);
			$AnimationPlayer.stop();
	else:
		return;
	state = GAME
	
func to_Both(instant=false):
	if state == VN:
		$AnimationPlayer.play_backwards("Both to VN");
		if instant:
			$AnimationPlayer.seek(0, true);
			$AnimationPlayer.stop();
	elif state == GAME:
		$AnimationPlayer.play_backwards("Both to Game");
		if instant:
			$AnimationPlayer.seek(0, true);
			$AnimationPlayer.stop();
	else:
		return;
	state = BOTH

func _on_VNReader_start_game(dir):
	game_logic.load_dir(dir);
	to_Both();
	yield($AnimationPlayer, "animation_finished");
	game_logic.start();

func _on_VNReader_end_game():
	to_VN();


func _on_Game_room_cleared():
	$VN/VSplitContainer/VSplitContainer/VNReader.next_page();


func _on_Button_pressed():
	print("ASD");
	VNGlobal.fire_user_input();
