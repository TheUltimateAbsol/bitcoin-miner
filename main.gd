extends Control

onready var game_logic = $Control/GamePanel/Viewport/Game

enum {VN, GAME, BOTH}
var state = GAME;

func _ready():
	pass
#	to_VN(true);
#	update_size();

func update_size():
	var margin_size = 40;
	var scale = int(($GamePanel.rect_size.x - margin_size)/160);
	$GamePanel.stretch_shrink = scale;
	#$PanelContainer/Panel/Node2D.rect_min_size = scale*Vector2(160, 144);
	$GamePanel.rec_size = scale*Vector2(160, 144);
	pass
	
func to_VN(instant=false):
	$AnimationPlayer.play_backwards("toBoth");
	
func to_Both(instant=false):
	$AnimationPlayer.play("toBoth");
	if instant:
		$AnimationPlayer.seek(0, true);
		$AnimationPlayer.stop();

func _on_VNReader_start_game(dir):
	game_logic.load_dir(dir);
	to_Both();
#	yield($AnimationPlayer, "animation_finished");
	game_logic.start();

func _on_VNReader_end_game():
	to_VN();


func _on_Game_room_cleared():
	$VNReader.next_page();


func _on_Button_pressed():
	print("ASD");
	VNGlobal.fire_user_input();
