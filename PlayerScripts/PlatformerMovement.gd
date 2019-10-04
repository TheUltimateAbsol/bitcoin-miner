extends Node

const GRAVITY = 500.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300
const JUMP_SPEED = 200
const JUMP_MAX_AIRBORNE_TIME = 0.2

const WALK_TOLERANCE = 1
#
enum {WAITING, WALKING, JUMPING}
enum {LEFT, MIDDLE, RIGHT}
var walk_left = false
var walk_right = false
var down = false
var jump = false
var attack = false
var target = null;
var jump_velocity = null;
var state = WAITING;
var section = LEFT;

signal target_reached
signal path_traversed
	
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

func reset_input():
	walk_left = false
	walk_right = false
	down = false
	jump = false
	attack = false
	target = null;
	jump_velocity = null;
	state = WAITING;
	
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

	$TileMap.display_path(left_to_middle);
	$TileMap.display_path(right_to_middle);
	$TileMap.display_path(middle_to_left);
	$TileMap.display_path(middle_to_right);
	
#	yield($Timer, "timeout");
#	follow_path(left_to_middle);



func death(victim):
	print("OOF")
	#removing node from the scene
	remove_child(victim)
	victim.queue_free()

func walk(end):
	var right = true;
	if main.position.x - end.x > 0: right = false;
	if right: walk_right = true;
	else:
		walk_left = true;
	target = end;
	state = WALKING;	

func jump(end, velocity):
	var right = true;
	if main.position.x - end.x > 0: right = false;
	main.flip(right);
	target = end;
	jump_velocity = velocity;
	jump = true;
	state = JUMPING;

func follow_path(path):
	print("Path " + str(path));
	
	for link in path:
		print(link.dest_location);
		if link.type == Global.NavLinkTypes.FLOOR:
			walk(link.dest_location);
		if link.type == Global.NavLinkTypes.JUMP:
			print("Jump");
			jump(link.dest_location, link.init_velocity);
		yield(self, "target_reached");
		print("REACHED " + str(link.dest_location))
		
	emit_signal("path_traversed");
	
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
				connect("path_traversed", self, "update_section", [LEFT], CONNECT_ONESHOT) 
			elif section == RIGHT:
				follow_path(right_to_middle);
				connect("path_traversed", self, "update_section", [MIDDLE], CONNECT_ONESHOT) 
		elif right_input:
			if section == LEFT:
				follow_path(left_to_middle);
				connect("path_traversed", self, "update_section", [MIDDLE], CONNECT_ONESHOT) 
			elif section == MIDDLE:
				follow_path(middle_to_right);
				connect("path_traversed", self, "update_section", [RIGHT], CONNECT_ONESHOT) 
		if attack_input:
			attack = true;
		else:
			attack = false; #Causes an error if two inputs are hit at the same time

func update_section(section_type):
	section = section_type

	
func _physics_process(delta):
	
	# Create gravity (this will be applied later)
	var force = Vector2(0, GRAVITY)
	if main.is_on_floor():
		force = Vector2(0,0)
	
	#Check input states
	get_command();
#	var walk_left = Input.is_action_pressed("left")
#	var walk_right = Input.is_action_pressed("right")
#	var down = Input.is_action_pressed("down")
#	var jump = Input.is_action_pressed("jump")
#	var attack = Input.is_action_pressed("attack")
	
	var stop = true #This will be changed if we find out that we are moving
	var on_floor = main.is_on_floor(); #This is so we don't call is_on_floor too many times
	
	if attack:
		stop = true
		
	#Turn the character in the left direction and set state
	elif walk_left:
		velocity.x = -(WALK_MAX_SPEED/2)
		stop = false
		main.flip(false)
		if on_floor: main.walk()
		
	#Turn the character in the right direction and set state
	elif walk_right:
		velocity.x = (WALK_MAX_SPEED/2)
		stop = false
		main.flip(true)
		if on_floor: main.walk()
		
	#Cancel out all X velocity and set state (if mining or idling only)
	if stop and state != JUMPING:
		velocity.x = 0
		if on_floor and not jumping:
			velocity.y = 0;
		if attack: 
			if on_floor: main.mine();
		else: 
			if on_floor and not down: 
				if duck: 
					main.getUp(); 
					duck = false;
				else: main.idle(); 

	if on_floor and down:
		velocity.x = 0;
		main.duck();
		duck = true;
	
	# Integrate velocity into motion and move
	#Move_and_slide_with snap acts wierd when not on the ground, so we adjust for it
	if jumping or stop:
			velocity = main.move_and_slide_with_snap(velocity, Vector2(), Vector2(0, -1), false, 4, 0.9)
	else:
		velocity = main.move_and_slide_with_snap(velocity, Vector2(0, 5), Vector2(0, -1), false, 4, 0.9)
	
	# Integrate forces to velocity (gravity)
	velocity += force * delta	
	
	#reset air-time counter (gives window for jumping when in air)
	if on_floor:
		on_air_time = 0
		
	# If falling, no longer jumping
	if jumping and velocity.y > 0:
		jumping = false
#		note, this leaves a bug where if you initiate a jump and walk up a platform, you will remain jumping
	
	#This gives the falling or jumping animations
	if not main.is_on_floor():
		duck = false;
		if velocity.y > 0:
			main.fall();
		else:
			main.jump();
	
	#On the frame after the jump command is issued, we account for the jump state
	#These confusing conditions allow us to jump a little after the character left the floor
	#This makes controls snappy
	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping:
#		velocity.y = -JUMP_SPEED
		print(jump_velocity);
		velocity = jump_velocity
		jumping = true
		main.jump();
	
	on_air_time += delta 
	prev_jump_pressed = jump
	
	if state == WALKING and abs(main.position.x - target.x) < WALK_TOLERANCE:
		reset_input();
		emit_signal("target_reached")
		
		
	if state == JUMPING and abs(main.position.x - target.x) < WALK_TOLERANCE:
		reset_input();
		emit_signal("target_reached")

	
func _on_Pause_pressed():
	print("PAUSED")
	get_tree().paused = true
	$pause_menu.show()
func _on_pause_menu_unpause():
	print("UNPAUSED")
	get_tree().paused = false
	$pause_menu.hide()
