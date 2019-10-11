extends Node
	
var left_to_middle 
var right_to_middle
var middle_to_left 
var middle_to_right 
var Miner = preload("res://Classes/miner.tscn");
var Win = preload("res://YOU_WIN.tscn");
var miners = [];
var main_command : Command = Command.new(Global.CommandTypes.IDLE)

var level1 = preload("res://Stages/Levels/Level1/1.tscn");
var level2 = preload("res://Stages/Levels/Level1/2.tscn");
var level3 = preload("res://Stages/Levels/Level1/3.tscn");
var levels = []
var current_level = 0;
var level_scene = null
var next_level_scene = null

#This is just an alias
onready var main : KinematicBody2D = $Miner


enum {LEFT, MIDDLE, RIGHT}
var section = MIDDLE;

signal paused

signal released_attack
signal released_down
	
func update_section(section_type):
	section = section_type
	new_command(Global.CommandTypes.IDLE)

#Precondition: current_level is set to the level we intend to load
func load_level():
	#Remove the trash we had before
	if level_scene != null:
		level_scene.queue_free();

	#No next level present, but we are trying to load a next level
	#Precondition: There is a level to load
	if next_level_scene == null:
		level_scene = levels[current_level].instance();
		$Current.add_child(level_scene);
	else:
		level_scene = next_level_scene;
		level_scene.get_parent().remove_child(level_scene);
		$Current.add_child(level_scene);
		next_level_scene = null;
		
	#If there is a next level, load it
	if current_level+1 < levels.size():
		next_level_scene = levels[current_level+1].instance();
		$Next.add_child(next_level_scene);
	else:
		next_level_scene = null;
		
	#Load Path data
	#Get main paths
	var left_target = level_scene.get_node("LeftTarget")
	var right_target = level_scene.get_node("RightTarget")
	var middle_target = level_scene.get_node("MiddleTarget")
	
	var left_navpoint = level_scene.get_closest_valid_navpoint(left_target.position);
	var right_navpoint = level_scene.get_closest_valid_navpoint(right_target.position);
	var middle_navpoint = level_scene.get_closest_valid_navpoint(middle_target.position);
	
	if !(is_instance_valid(left_navpoint)):
		push_error("Left Target is in an invalid location")
	if !(is_instance_valid(right_navpoint)):
		push_error("Right Target is in an invalid location")
	if !(is_instance_valid(middle_navpoint)):
		push_error("Middle Target is in an invalid location")
		
	left_to_middle = level_scene.connect_path(left_navpoint.index, middle_navpoint.index);
	right_to_middle = level_scene.connect_path(right_navpoint.index, middle_navpoint.index);
	middle_to_left = level_scene.connect_path(middle_navpoint.index, left_navpoint.index);
	middle_to_right = level_scene.connect_path(middle_navpoint.index, right_navpoint.index);
	
	if (left_to_middle == null):
		push_error("Left to Middle Path cannot be drawn")
	if (right_to_middle == null):
		push_error("Right to Middle Path cannot be drawn")
	if (middle_to_left == null):
		push_error("Middle to Left Path cannot be drawn")
	if (middle_to_right == null):
		push_error("Middle to Right Path cannot be drawn")
		
	if next_level_scene != null:
		level_scene.connect("room_clear", self, "switch_level", [], CONNECT_ONESHOT);
	else:
		level_scene.connect("room_clear", self, "win", [], CONNECT_ONESHOT);
	
#precondition: there is another level to switch to
func switch_level():
	$Miner.visible = false;
	$Miners.visible = false;
	
	$AnimationPlayer.play("Scene Switch");
	yield($AnimationPlayer, "animation_finished");
	$Current.position = Vector2(0, 8)
	$Next.position = Vector2(0,144)
	current_level = current_level + 1;
	load_level();
	spawn();
	
	$Miner.visible = true;
	$Miners.visible = true
	
	
func _ready():
	levels.push_back(level1);
	levels.push_back(level2);
	levels.push_back(level3);
	
	add_child(main_command) # so its timer works

	load_level()
	spawn();

func spawn():
	var spawnlocation = level_scene.get_node("MiddleTarget").position.x;
	main.position = Vector2 (spawnlocation, 32);
	section = MIDDLE;
	var i = 1;
	for miner in $Miners.get_children():
		miner.position = main.position + Vector2(0, i*(-4))
		i = i+1;

#	$TileMap.display_path(left_to_middle);
#	$TileMap.display_path(right_to_middle);
#	$TileMap.display_path(middle_to_left);
#	$TileMap.display_path(middle_to_right);
	
#	yield($Timer, "timeout");
#	follow_path(left_to_middle);



	
func _on_Pause_pressed():
	print("PAUSED")
	get_tree().paused = true
	$pause_menu.show()
func _on_pause_menu_unpause():
	print("UNPAUSED")
	get_tree().paused = false
	$pause_menu.hide()
	
	
func new_command(type, path=[]):
	var new =  Command.new(type, path)
	add_child(new);
	main_command.link(new);
	main_command.force_end();
	main_command = new;
	
func get_command():
	var left_input = Input.is_action_pressed("left")
	var right_input = Input.is_action_pressed("right")
	var down_input = Input.is_action_pressed("down")
	var jump_input = Input.is_action_pressed("jump")
	var attack_input = Input.is_action_pressed("attack")
	
	if main.can_attack():
		if (attack_input):
			main.attack(self, "released_attack");
			connect("released_attack", self, "new_command", [Global.CommandTypes.IDLE], CONNECT_ONESHOT);
			new_command(Global.CommandTypes.MINE)

		
	if main.is_waiting():
		if left_input:
			if  section == MIDDLE:
				main.follow_path(middle_to_left);
				main.connect("path_traversed", self, "update_section", [LEFT], CONNECT_ONESHOT) 
				new_command(Global.CommandTypes.MOVE, middle_to_left)
			elif section == RIGHT:
				main.follow_path(right_to_middle);
				main.connect("path_traversed", self, "update_section", [MIDDLE], CONNECT_ONESHOT) 
				new_command(Global.CommandTypes.MOVE, right_to_middle)
		elif right_input:
			if section == LEFT:
				main.follow_path(left_to_middle);
				main.connect("path_traversed", self, "update_section", [MIDDLE], CONNECT_ONESHOT) 
				new_command(Global.CommandTypes.MOVE, left_to_middle)
			elif section == MIDDLE:
				main.follow_path(middle_to_right);
				main.connect("path_traversed", self, "update_section", [RIGHT], CONNECT_ONESHOT) 
				new_command(Global.CommandTypes.MOVE, middle_to_right)
#		elif down_input:
#			main.duck_action(self, "released_down");
#			new_command(Global.CommandTypes.DUCK)

func _process(delta):
	if Input.is_action_just_released("attack"): 
		emit_signal("released_attack");
	if Input.is_action_just_released("down"): 
		emit_signal("released_down");
	get_command();

func _on_ui_header_add_miner():
	#This really should be part of a separate function
	$AnimationPlayer2.play("Level_Up");
	
	var new_miner = Miner.instance();
	$Miners.add_child(new_miner);
	miners.push_back(new_miner);
	main_command.perform_command(new_miner);
	new_miner.position = main.position + Vector2(0, -32);
	
func drop_win():
	var win = Win.instance();
	add_child(win);
	win.position = $WinDropper.position;
	win.rotation_degrees = int(rand_range(0, 360))
	
func win():
	$AnimationPlayer.play("Win_spawner");
	$Timer.connect("timeout", self, "drop_win");
	
