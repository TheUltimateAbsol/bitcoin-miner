extends Node
	
var left_to_middle 
var right_to_middle
var middle_to_left 
var middle_to_right 
var Miner = preload("res://Classes/miner.tscn");
var Win = preload("res://YOU_WIN.tscn");
var miners = [];
var main_command : Command = Command.new(Global.CommandTypes.IDLE)

var levels = []
var current_level = 0;
var level_scene = null
var next_level_scene = null
var dead = false;

var command_time = 0

var attack_buffers = [false, false, false, false, false];
signal cancel_attack
signal cancel_duck
signal cancel_hang
#This is just an alias
onready var main : KinematicBody2D = $Miner

var totalMinerCost = 0
var minersBought = 0

enum {LEFT, MIDDLE, RIGHT}
var section = LEFT;

signal paused
signal room_cleared

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
		$LevelLoadout/Current.add_child(level_scene);
	else:
		level_scene = next_level_scene;
		level_scene.get_parent().remove_child(level_scene);
		$LevelLoadout/Current.add_child(level_scene);
		next_level_scene = null;
		
	#If there is a next level, load it
	if current_level+1 < levels.size():
		next_level_scene = levels[current_level+1].instance();
		#$LevelLoadout/Next.add_child(next_level_scene);
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

	
func recursive_invisible(node: Node, list):
	for enemy in node.get_children():
		recursive_invisible(enemy, list);
	
	if (node.is_in_group("enemy") and not node.is_in_group("objective")):
		node.visible = false;
		list.push_back(node);
	
#precondition: there is another level to switch to
func switch_level():
	$Miner.visible = false;
	$Miners.visible = false;
	
	#A CHEAP TRICK TO MAKE SURE MINING STATE DOES NOT SAVE ACROSS SCENES
	$Miner.stop_attack()
	
	#Makes next level visible
	$LevelLoadout/Next.call_deferred("add_child", next_level_scene);
	
	#Make all enemies invisible
	var affected = [];
	recursive_invisible(next_level_scene, affected);
	
	$LevelLoadout/AnimationPlayer.pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true;
	
	$LevelLoadout/AnimationPlayer.play("SceneSwitch");
	yield($LevelLoadout/AnimationPlayer, "animation_finished");
	
	#Make them visible again
	#Note: this is here so that the "affected" list is not messed up by load_level's deletions
	for enemy in affected:
		enemy.visible = true;
	
	$LevelLoadout/Current.position = Vector2(0, 8)
	$LevelLoadout/Next.position = Vector2(0,144)
	current_level = current_level + 1;
	load_level();
	spawn();
	
	$LevelLoadout/AnimationPlayer.pause_mode = Node.PAUSE_MODE_INHERIT
	get_tree().paused = false;
	
	$Miner.visible = true;
	$Miners.visible = true
	
	emit_signal("room_cleared");
	
func _ready():
	add_child(main_command) # so its timer works
	get_tree().paused = true;
	
	for i in range (1):
		_on_ui_header_add_miner()

	
func finished_mining_fire():
	emit_signal("cancel_attack");
	
func test():
	print("hello world");
	

func spawn():
	var spawnlocation;
	match level_scene.spawn_location:
		"Left":
			spawnlocation = level_scene.get_node("LeftTarget").position.x;
			section = LEFT;
		"Middle":
			spawnlocation = level_scene.get_node("MiddleTarget").position.x;
			section = MIDDLE;
		"Right":
			spawnlocation = level_scene.get_node("RightTarget").position.x;
			section = RIGHT;
			
	main.position = Vector2 (spawnlocation, -8);

	var i = 1;
	for miner in $Miners.get_children():
		if not miner.frozen:
			miner.reset_input();
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
	$Pause/pause_menu.show()
func _on_pause_menu_unpause():
	print("UNPAUSED")
	get_tree().paused = false
	$Pause/pause_menu.hide()
	
	
func new_command(type, path=[], time=-1):
	var new =  Command.new(type, path)
	add_child(new);
	main_command.link(new);
	main_command.force_end(time);
	main_command = new;
	print("New command ", type)
	
func get_command():
	if dead: return;
	
	var left_input = Input.is_action_pressed("left")
	var right_input = Input.is_action_pressed("right")
	var down_input = Input.is_action_pressed("down")
	var jump_input = Input.is_action_pressed("jump")
	var attack_input = Input.is_action_pressed("attack")
	
	attack_buffers.pop_front();
	attack_buffers.push_back(attack_input);
	
	attack_input = attack_buffers.has(true);
	
	if not attack_input and (left_input or right_input or down_input):
		emit_signal("cancel_attack");
		
	if not down_input and (left_input or right_input or attack_input):
		emit_signal("cancel_duck");
	
	if main.can_attack():
		if (attack_input):
#			main.attack(InputEventHandler, "released_attack");
			main.attack(self, "cancel_attack");

#			InputEventHandler.connect("released_attack", self, "new_command", [Global.CommandTypes.IDLE], CONNECT_ONESHOT);
			connect("cancel_attack", self, "new_command", [Global.CommandTypes.IDLE], CONNECT_ONESHOT);
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
		elif down_input:
			main.duck_action(self, "cancel_duck");
			connect("cancel_duck", self, "new_command", [Global.CommandTypes.IDLE], CONNECT_ONESHOT);
			new_command(Global.CommandTypes.DUCK)
		elif jump_input:
			command_time = OS.get_ticks_msec()
			main.do_jump();
			#Will this cause unnecessary idle commands?
			if not main.is_connected("jump_ended", self, "new_command"):
				main.connect("jump_ended", self, "new_command", [Global.CommandTypes.IDLE], CONNECT_ONESHOT);
			new_command(Global.CommandTypes.JUMP)
#		else:
#			new_command(Global.CommandTypes.IDLE);

	#We have more code than just canceling since we want to act out of hang
	if main.is_hanging():
		if (left_input or jump_input or right_input):
			command_time = OS.get_ticks_msec()
			main.do_fall()
			if not main.is_connected("jump_ended", self, "new_command"):
				main.connect("jump_ended", self, "new_command", [Global.CommandTypes.IDLE], CONNECT_ONESHOT);
			new_command(Global.CommandTypes.FALL)
			emit_signal("cancel_hang");
		if (attack_input):
			main.do_midair_attack()
			if not main.is_connected("midair_attack_ended", self, "new_command"):
				main.connect("midair_attack_ended", self, "new_command", [Global.CommandTypes.IDLE], CONNECT_ONESHOT);
			new_command(Global.CommandTypes.MIDAIR_ATTACK, [])
		if (down_input):
			main.do_ground_pound()
			if not main.is_connected("midair_attack_ended", self, "new_command"):
				main.connect("midair_attack_ended", self, "new_command", [Global.CommandTypes.IDLE], CONNECT_ONESHOT);
			new_command(Global.CommandTypes.GROUND_POUND, [])

	if main.can_midair_attack():
		if attack_input:
			command_time = (OS.get_ticks_msec() - command_time)/1000.0
			main.do_midair_attack()
			if not main.is_connected("midair_attack_ended", self, "new_command"):
				main.connect("midair_attack_ended", self, "new_command", [Global.CommandTypes.IDLE], CONNECT_ONESHOT);
			new_command(Global.CommandTypes.MIDAIR_ATTACK, [], command_time)
		elif down_input:
			command_time = (OS.get_ticks_msec() - command_time)/1000.0
			main.do_ground_pound()
			if not main.is_connected("midair_attack_ended", self, "new_command"):
				main.connect("midair_attack_ended", self, "new_command", [Global.CommandTypes.IDLE], CONNECT_ONESHOT);
			new_command(Global.CommandTypes.GROUND_POUND, [], command_time)
			
	if main.can_super_jump():
		if jump_input:
			emit_signal("cancel_duck");
			command_time = OS.get_ticks_msec()
			main.do_super_jump();
			if not main.is_connected("jump_ended", self, "new_command"):
				main.connect("jump_ended", self, "new_command", [Global.CommandTypes.IDLE], CONNECT_ONESHOT);
			new_command(Global.CommandTypes.SUPER_JUMP)

func _process(delta):
	get_command();

func _on_ui_header_add_miner():
	#This really should be part of a separate function
	$DecoratorAnimations/LevelUp.play("Level_Up");
	
	$Miner.vulnerable = false #This is so we don't have the player die until all are lost
	
	var new_miner = Miner.instance();
	#This is because this will be called only on a collision check frame
	#You can't add more collision frames during a collision check.
	$Miners.call_deferred("add_child", new_miner)
	miners.push_back(new_miner);
	main_command.perform_command(new_miner);
	new_miner.position = main.position + Vector2(0, -32);
	new_miner.connect("died", self, "on_miner_loss");
	
func drop_win():
	var win = Win.instance();
	add_child(win);
	win.position = $LevelComplete/WinDropper.position;
	win.rotation_degrees = int(rand_range(0, 360))
	
func win():
#	$LevelComplete/AnimationPlayer.play("WinSpawner");
#	$LevelComplete/Timer.connect("timeout", self, "drop_win");
	get_node("AudioStreamPlayer").stop();
	
	$LevelLoadout.visible = false;
	$Miners.visible = false;
	$Miner/Node2D.visible = false;
	$Miner/Revive.visible = false;
	$Miner.pause_mode = Node.PAUSE_MODE_PROCESS
	$LevelComplete.pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true;
	$LevelComplete.activate($Miner);
	pass
	
	
func on_miner_loss():
	print("MINER LOST");
		##PAY ATTENTION TO LOCKS HERE
	var num_remaining = Global.numremaining - 1;
	$ui_header.update_data(num_remaining, Global.numtotal, Global.numcoin);
	$ui_header.initiate_countdown();
	if (num_remaining == 1):
		$Miner.vulnerable = true;
	
func release_connections():
	for connection in InputEventHandler.get_signal_connection_list("released_attack"):
		InputEventHandler.disconnect("released_attack", connection["target"], connection["method"]);
	for connection in InputEventHandler.get_signal_connection_list("released_down"):
		InputEventHandler.disconnect("released_down", connection["target"], connection["method"]);
		
func game_over():
	$Miner.vulnerable = false;
	dead = true;
	release_connections();
	$ui_header.update_data(0, Global.numtotal, Global.numcoin);
	$ui_header.stop_countdown();
	$Miner.game_over();
	$GameOver/AnimationPlayer.play("GameOver")
	
	#Hide everything
	$LevelLoadout.visible = false;
	$Miner.pause_mode = Node.PAUSE_MODE_PROCESS
	$GameOver.pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true;

func revive():
	$QuickTimeEvent.pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true;
	Global.minersbought = 0; # Clearing minersbought before going into the quicktime event.
	var result = yield($QuickTimeEvent.activate(), "completed");
	get_tree().paused = false;
	$QuickTimeEvent.pause_mode = Node.PAUSE_MODE_INHERIT
		
	if result:
		$DecoratorAnimations/Revive.play("Success");
		$Miner.vulnerable = false #This is so we don't have the player die until all are lost
		var num_to_add = Global.minersbought;
		print(num_to_add)
		$ui_header.update_data(Global.numtotal, Global.numtotal, Global.numcoin);
		for i in range(num_to_add):
			var new_miner = Miner.instance();
			$Miners.add_child(new_miner);
			miners.push_back(new_miner);
			main_command.perform_command(new_miner);
			new_miner.position = main.position + Vector2(0, -32);
			new_miner.connect("died", self, "on_miner_loss");
	else:
		$ui_header.initiate_countdown();
		$DecoratorAnimations/Revive.play("Fail");
		
		
func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files
	
func load_dir(dir):
	print(dir);
	var level_names = list_files_in_directory(dir);
	
	for name in level_names:
		levels.push_back(load(dir + name));
		
func start():
	$Startup.pause_mode = Node.PAUSE_MODE_PROCESS
	
	load_level()
	spawn();
	#connect to gameover
	$Miner.connect("died", self, "game_over");
	
	main.connect("finished_mining", self, "finished_mining_fire");
	
	get_tree().paused = true;
	yield($Startup/AnimationPlayer, "animation_finished");
	get_tree().paused = false;
	
	$AudioStreamPlayer.play();
	

func _on_Miner_start_hang():
	command_time = (OS.get_ticks_msec() - command_time)/1000.0
	main.hang_action(self, "cancel_hang");
	new_command(Global.CommandTypes.HANG, [], command_time)
