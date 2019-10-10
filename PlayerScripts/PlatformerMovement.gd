extends Node
	
var left_to_middle 
var right_to_middle
var middle_to_left 
var middle_to_right 
	
#This is just an alias
onready var main : KinematicBody2D = $Miner

var velocity = Vector2()
var on_air_time = 100
var jumping = false #This will be set to true the frame after we process a jump input
var prev_jump_pressed = false
var duck = false

signal paused
	
func _ready():
	var children = get_tree().get_nodes_in_group("enemy")
	for child in children:
		#print(child);
		child.connect("died", self, "death")
		
	#Get main paths
	var left_target = $TileMap/LeftTarget
	var right_target = $TileMap/RightTarget
	var middle_target = $TileMap/MiddleTarget
	
	var left_navpoint = $TileMap.get_closest_valid_navpoint(left_target.position);
	var right_navpoint = $TileMap.get_closest_valid_navpoint(right_target.position);
	var middle_navpoint = $TileMap.get_closest_valid_navpoint(middle_target.position);
	
	if (left_navpoint == null):
		push_error("Left Target is in an invalid location")
	if (right_navpoint == null):
		push_error("Right Target is in an invalid location")
	if (middle_navpoint == null):
		push_error("Middle Target is in an invalid location")
		
	left_to_middle = $TileMap.connect_path(left_navpoint.index, middle_navpoint.index);
	right_to_middle = $TileMap.connect_path(right_navpoint.index, middle_navpoint.index);
	middle_to_left = $TileMap.connect_path(middle_navpoint.index, left_navpoint.index);
	middle_to_right = $TileMap.connect_path(middle_navpoint.index, right_navpoint.index);
	
	if (left_to_middle == null):
		push_error("Left to Middle Path cannot be drawn")
	if (right_to_middle == null):
		push_error("Right to Middle Path cannot be drawn")
	if (middle_to_left == null):
		push_error("Middle to Left Path cannot be drawn")
	if (middle_to_right == null):
		push_error("Middle to Right Path cannot be drawn")

#	$TileMap.display_path(left_to_middle);
#	$TileMap.display_path(right_to_middle);
#	$TileMap.display_path(middle_to_left);
#	$TileMap.display_path(middle_to_right);
	
#	yield($Timer, "timeout");
#	follow_path(left_to_middle);

func death(victim):
	print("OOF")
	#removing node from the scene
	remove_child(victim)
	victim.queue_free()

	
func _on_Pause_pressed():
	print("PAUSED")
	get_tree().paused = true
	$pause_menu.show()
func _on_pause_menu_unpause():
	print("UNPAUSED")
	get_tree().paused = false
	$pause_menu.hide()
	
	
func get_command():
	var left_input = Input.is_action_pressed("left")
	var right_input = Input.is_action_pressed("right")
	var down_input = Input.is_action_pressed("down")
	var jump_input = Input.is_action_pressed("jump")
	var attack_input = Input.is_action_pressed("attack")
	
	if state == WAITING:
		if left_input:
			if  section == MIDDLE:
				follow_path(middle_to_left);
# warning-ignore:return_value_discarded
				connect("path_traversed", self, "update_section", [LEFT], CONNECT_ONESHOT) 
			elif section == RIGHT:
				follow_path(right_to_middle);
# warning-ignore:return_value_discarded
				connect("path_traversed", self, "update_section", [MIDDLE], CONNECT_ONESHOT) 
		elif right_input:
			if section == LEFT:
				follow_path(left_to_middle);
# warning-ignore:return_value_discarded
				connect("path_traversed", self, "update_section", [MIDDLE], CONNECT_ONESHOT) 
			elif section == MIDDLE:
				follow_path(middle_to_right);
# warning-ignore:return_value_discarded
				connect("path_traversed", self, "update_section", [RIGHT], CONNECT_ONESHOT) 
		if attack_input:
			attack = true;
		else:
			attack = false; #Causes an error if two inputs are hit at the same time
