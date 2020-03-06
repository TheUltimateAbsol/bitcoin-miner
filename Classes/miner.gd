extends AnimatedMiner

class_name Miner

const GRAVITY = 500.0 # pixels/second/second
const WALK_MAX_SPEED = 200
const JUMP_SPEED = 200

#Distance (in pixels) before it supposedly hits it's target when walking
const WALK_TOLERANCE = 1

enum {WAITING, WALKING, JUMPING, FALLING, ATTACKING, DUCKING, DYING, MIDATTACKING, MIDATTACKING2}
var is_facing_right = true;
var state = WAITING;

var target = null;
var jump_velocity = Vector2();
var frozen = false;

var velocity = Vector2()
var prev_jump_pressed = false

signal target_reached
signal path_traversed
signal jump_ended
signal died

func reset_input():
	target = null;
#	jump_velocity = Vector2();
	state = WAITING;
	
func walk_to(end):
	reset_input();
	is_facing_right = end.x - position.x > 0;
	target = end;
	state = WALKING;	

func jump_to(end, xvelocity):
	reset_input();
	is_facing_right = end.x - position.x > 0
	flip(is_facing_right);
	target = end;
	jump_velocity = xvelocity;
	
	state = JUMPING;
	
func attack(node : Node, signal_name : String):
	state = ATTACKING;
	node.connect(signal_name, self, "stop_attack", [], CONNECT_ONESHOT);
	
func do_jump():
	state = JUMPING;
	jump_velocity = Vector2(0, -JUMP_SPEED)
	connect("jump_ended", self, "stop_jump", [], CONNECT_ONESHOT);
	
func stop_jump():
	state = WAITING;
	
func stop_attack():
	state = WAITING;

func duck_action(node : Node, signal_name : String):
	state = DUCKING;
	node.connect(signal_name, self, "stop_duck", [], CONNECT_ONESHOT);
	
func quick_duck():
	print("QUICK DUCK");
	state = DUCKING;

	#UNSAFE
	yield(anim, "animation_finished");
	print ("QUICK DUCK STOP")
	stop_duck();
#	anim.connect("animation_finished", self, "stop_duck", [], CONNECT_ONESHOT);
#	anim.connect("animation_changed", self, "cancel_duck", [], CONNECT_ONESHOT);

func stop_duck():
	state = WAITING;
	
func follow_path(path):
	for link in path:
		if link.type == Global.NavLinkTypes.FLOOR:
			walk_to(link.dest_location);
		if link.type == Global.NavLinkTypes.JUMP:
			jump_to(link.dest_location, link.init_velocity);
		yield(self, "target_reached");
		
	emit_signal("path_traversed");

func damage():
	if state == DUCKING: return false;
	if vulnerable == false: return false;
	
	reset_input();
	state = DYING;
	die_anim();

	velocity = Vector2(0, -200);
	emit_signal("died");
	return true;

func _physics_process(delta):
	if frozen: return;
	
	# Create gravity (this will be applied later)
	var force = Vector2(0, GRAVITY)
	var stop = true #This will be changed if we find out that we are moving
	var on_floor = is_on_floor(); #This is so we don't call is_on_floor too many times
	
	match (state):
		WALKING:
			velocity.x = (1 if is_facing_right else -1)*(WALK_MAX_SPEED/2.0)
			stop = false
			flip(is_facing_right)
			if on_floor: walk_anim()
		WAITING:
			if on_floor:
				velocity.x = 0;
				idle_anim(); 
		FALLING:
			pass;
		JUMPING:
			if not prev_jump_pressed:
				velocity = jump_velocity;
			if (not on_floor) and velocity.y > 0:
				state = FALLING
				continue
		ATTACKING:
			velocity.x = 0;
			if on_floor: mine_anim();
		MIDATTACKING:
			velocity.x = 0;
			state = WAITING;
		DUCKING:
			velocity.x = 0;
			duck_anim();
			
#	Purely visual
	if not on_floor:
		if velocity.y < 0:
			jump_anim()
		else:
			fall_anim();
	
	if (state == JUMPING and not prev_jump_pressed):
		print(velocity);
		print(jump_velocity);
	velocity = move_and_slide(velocity, Vector2(0, -1))
			
	# Integrate forces to velocity (gravity)
	velocity += force * delta	

#	This is just to make super sure we aren't pressing jump more than once
	prev_jump_pressed = state == JUMPING
	
#	See if jump ended
#	If we do this on a targeted jump, it will mess up the correction for undershooting
#	TODO: FIX UNDERSHOT JUMPS
	if state == FALLING and on_floor and target == null:
		print("jump ended")
		emit_signal("jump_ended");
	
#	Check if we hit our targets
	if target and abs(position.x - target.x) < WALK_TOLERANCE:
		reset_input();
		emit_signal("target_reached")

func is_waiting():
	return (state == WAITING)
	
##May also correspond to an upwards jump
func can_attack():
	return (state == WAITING || state == MIDATTACKING)
	
func freeze():
	frozen= true
	velocity = Vector2(0,0);