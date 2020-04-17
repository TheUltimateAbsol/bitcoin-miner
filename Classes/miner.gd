extends AnimatedMiner

class_name Miner

const GRAVITY = 500.0 # pixels/second/second
const WALK_MAX_SPEED = 200
const JUMP_SPEED = 200

#Distance (in pixels) before it supposedly hits it's target when walking
const WALK_TOLERANCE = 2

enum {WAITING, WALKING, JUMPING, FALLING, ATTACKING, DUCKING, DYING, MIDATTACKING, MIDATTACKING2, MIDAIR_ATTACKING, HANGING, GROUND_POUNDING}
enum DeathState {NONE, DEAD, RESPAWN}

var is_facing_right = true;
var state = WAITING;
var death_state = DeathState.NONE

var target = null;
var jump_velocity = Vector2();
var frozen = false;

var velocity = Vector2()
var prev_jump_pressed = false
var prev_jump_momentum_pressed = false

var current_command = null

signal target_reached
signal path_traversed
signal jump_ended
signal midair_attack_ended
signal died
signal start_hang

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
	if not node.is_connected(signal_name, self, "stop_attack"):
		node.connect(signal_name, self, "stop_attack", [], CONNECT_ONESHOT);
	
func do_jump():
	state = JUMPING;
	jump_velocity = Vector2(0, -JUMP_SPEED)
#	disconnect("jump_ended", self, "stop_jump");

#a more boring version of idling
func do_fall():
	state = FALLING;
#	disconnect("jump_ended", self, "stop_jump");
	
func do_super_jump():
	state = JUMPING;
	jump_velocity = Vector2(0, -JUMP_SPEED-JUMP_SPEED)
	
func do_midair_attack():
	state = MIDAIR_ATTACKING;
#	jump_velocity = Vector2(0, -JUMP_SPEED)
	connect("midair_attack_ended", self, "stop_jump", [], CONNECT_ONESHOT);
	
func do_ground_pound():
	state = GROUND_POUNDING;
	jump_velocity = Vector2(0, JUMP_SPEED)
	connect("midair_attack_ended", self, "stop_jump", [], CONNECT_ONESHOT);
	
func stop_jump(time=0):
	state = WAITING;
	
func stop_attack(time=0):
	state = WAITING;

func duck_action(node : Node, signal_name : String):
	state = DUCKING;
	node.connect(signal_name, self, "stop_duck", [], CONNECT_ONESHOT);

func hang_action(node : Node, signal_name : String):
	state = HANGING;
	
func quick_duck():
	state = DUCKING;

	#UNSAFE
	yield(anim, "animation_finished");
	stop_duck();
#	anim.connect("animation_finished", self, "stop_duck", [], CONNECT_ONESHOT);
#	anim.connect("animation_changed", self, "cancel_duck", [], CONNECT_ONESHOT);

func stop_duck(time=0):
	state = WAITING;
	
func follow_path(path):
	for link in path:
		if link.type == Global.NavLinkTypes.FLOOR:
			walk_to(link.dest_location);
		if link.type == Global.NavLinkTypes.JUMP:
			jump_to(link.dest_location, link.init_velocity);
		yield(self, "target_reached");
		
	emit_signal("path_traversed");

func can_damage():
	if state == DUCKING or state == MIDAIR_ATTACKING or state == GROUND_POUNDING:return false;
	if vulnerable == false: return false;
	return true

func damage():
	if not can_damage(): return false;
	
	death_state = DeathState.DEAD
	emit_signal("died");
	return true;

func die():
	reset_input();
	state = DYING;
	die_anim();
	velocity = Vector2(0, -200);
	
	$DeathTimer.start()
	yield($DeathTimer, "timeout")
	queue_free()

func respawn():
	death_state = DeathState.RESPAWN
	emit_signal("died");
	
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
		MIDAIR_ATTACKING:
			air_attack_anim();
		GROUND_POUNDING:
			if not prev_jump_momentum_pressed:
				velocity = jump_velocity;
			ground_pound_anim()
		ATTACKING:
			velocity.x = 0;
			if on_floor: mine_anim();
		MIDATTACKING:
			velocity.x = 0;
			state = WAITING;
		DUCKING:
			velocity.x = 0;
			duck_anim();
		DYING:
			velocity.x = 0;
		HANGING:
			velocity= Vector2()
			hang_anim()
			
#	Purely visual
	if not on_floor and state != MIDAIR_ATTACKING and state != GROUND_POUNDING and state != HANGING:
		if velocity.y < 0:
			jump_anim()
		else:
			fall_anim();
	
#	if (state == JUMPING and not prev_jump_pressed):
#		print(velocity);
#		print(jump_velocity);
	velocity = move_and_slide(velocity, Vector2(0, -1))
			
	# Integrate forces to velocity (gravity)
	velocity += force * delta	
	#NOTE: THIS DELTA ISN'T NEEDED FOR MOVE AND SLIDE?
#	IT'S POSSIBLE THAT THIS DELTA IS SUPERFLUOUS
# 	TODO: FIND FIX

#	This is just to make super sure we aren't pressing jump more than once
	prev_jump_pressed = state == JUMPING
	prev_jump_momentum_pressed = state == GROUND_POUNDING
	
#	See if jump ended
#	If we do this on a targeted jump, it will mess up the correction for undershooting
#	TODO: FIX UNDERSHOT JUMPS
	if state == FALLING and on_floor and target == null:
		stop_jump()
		emit_signal("jump_ended");
		
	
	if (state == MIDAIR_ATTACKING or state == GROUND_POUNDING) and on_floor:
		emit_signal("midair_attack_ended");
		
	#handle hanging
	if state == JUMPING and target == null and is_protagonist and is_on_ceiling():
		stop_jump()
		emit_signal("start_hang");
	
#	Check if we hit our targets
	if target and abs(position.x - target.x) < WALK_TOLERANCE:
		reset_input();
		emit_signal("target_reached")

func is_waiting():
	return (state == WAITING)
	
func is_hanging():
	return (state == HANGING)
	
func can_attack():
	return (state == WAITING || state == MIDATTACKING)
	
func can_midair_attack():
	return (state == JUMPING || state == FALLING) && (target == null)
	
func can_super_jump():
	return (state == DUCKING && is_on_floor())
	
func freeze():
	frozen= true
	velocity = Vector2(0,0);
	$CollisionShape2D.set_deferred("disabled", true)
	
func unfreeze():
	frozen = false
	$CollisionShape2D.set_deferred("disabled", false)
	
