extends AnimatedMiner

class_name Miner

const GRAVITY = 500.0 # pixels/second/second
const WALK_MAX_SPEED = 200
const JUMP_SPEED = 200
const JUMP_MAX_AIRBORNE_TIME = 0.2

#Distance (in pixels) before it supposedly hits it's target when walking
const WALK_TOLERANCE = 1

enum {WAITING, WALKING, JUMPING, ATTACKING, DUCKING, DYING, MIDATTACKING, MIDATTACKING2}
var is_facing_right = true;
var state = WAITING;

var target = null;
var jump_velocity = Vector2();
var frozen = false;

var velocity = Vector2()
var on_air_time = 100
var jumping = false #This will be set to true the frame after we process a jump input
var prev_jump_pressed = false
var ducking = false

signal target_reached
signal path_traversed
signal jump_ended
signal died

func reset_input():
	target = null;
#	jump_velocity = Vector2();
	state = WAITING;
	
func walk_to(end):
	reset_input(); #PATCH
#	if abs(position.x - end.x) < WALK_TOLERANCE:
#		reset_input();
#		emit_signal("target_reached");
#		return;
	is_facing_right = end.x - position.x > 0;
	target = end;
	state = WALKING;	

func jump_to(end, velocity):
	reset_input(); #PATCH
		
	is_facing_right = end.x - position.x > 0
	flip(is_facing_right);
	target = end;
	jump_velocity = velocity;
	
	state = JUMPING;
	
func attack(node : Node, signal_name : String):
	state = ATTACKING;
	node.connect(signal_name, self, "stop_attack", [], CONNECT_ONESHOT);
	
func do_jump():
	state = JUMPING;
	jump_velocity = Vector2(0, -JUMP_SPEED)
	yield(anim, "animation_finished")
	emit_signal("jump_ended");
	
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
	if ducking == true: return false;
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
	if is_on_floor():
		force = Vector2(0,0)
	var stop = true #This will be changed if we find out that we are moving
	var on_floor = is_on_floor(); #This is so we don't call is_on_floor too many times
	
	#Turn the character in the left direction and set state
	if state == WALKING:
		velocity.x = (1 if is_facing_right else -1)*(WALK_MAX_SPEED/2.0)
		stop = false
		flip(is_facing_right)
		if on_floor: walk_anim()
		
	#Cancel out all X velocity and set state (if mining or idling only)
	if stop and state != JUMPING and state != DYING:
		velocity.x = 0
		if on_floor and not jumping:
			velocity.y = 0;
		if state == ATTACKING: 
			if on_floor: mine_anim();
		else: 
			if on_floor and not state == DUCKING: 
				if ducking: 
					getUp_anim(); 
					ducking = false;
				else: 
					if not state == MIDATTACKING:
						idle_anim(); 

	if on_floor and state == DUCKING:
		velocity.x = 0;
		duck_anim();
		ducking = true;
	
	# Integrate velocity into motion and move
	#Move_and_slide_with snap acts wierd when not on the ground, so we adjust for it
	if jumping or stop:
			velocity = move_and_slide_with_snap(velocity, Vector2(), Vector2(0, -1), false, 4, 0.9)
	else:
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 5), Vector2(0, -1), false, 4, 0.9)
	
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
	if not is_on_floor() and state != DYING:
		ducking = false;
		if velocity.y > 0:
			fall_anim();
		else:
			jump_anim();
	
	#On the frame after the jump command is issued, we account for the jump state
	#These confusing conditions allow us to jump a little after the character left the floor
	#This makes controls snappy
	if on_air_time < JUMP_MAX_AIRBORNE_TIME and state == JUMPING and not prev_jump_pressed and not jumping:
#		velocity.y = -JUMP_SPEED
		velocity = jump_velocity
		jumping = true
		jump_anim();
	
	on_air_time += delta 
	prev_jump_pressed = state == JUMPING
	
	if target and (state == WALKING or state == JUMPING) and abs(position.x - target.x) < WALK_TOLERANCE:
		reset_input();
		emit_signal("target_reached")
		
	if state == MIDATTACKING:
		state = WAITING

func is_waiting():
	return (state == WAITING)
	
##May also correspond to an upwards jump
func can_attack():
	return (state == WAITING || state == MIDATTACKING)
	
func freeze():
	frozen= true
	velocity = Vector2(0,0);