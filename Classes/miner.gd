extends KinematicBody2D

class_name Miner

#Load the sprites that we can alternate between
export (Texture) var idleSprite = preload("res://PlayerSprites/Miner Compress.png")
export (Texture) var jumpingSprite = preload("res://PlayerSprites/jump.png")
export (Texture) var walkingSprite = preload("res://PlayerSprites/Miner Walking Compress.png")
export (Texture) var miningSprite = preload("res://PlayerSprites/Miner Axe.png")
export (Texture) var miningSprite2 = preload("res://PlayerSprites/Miner_Bat.png")
export (Texture) var miningSprite3 = preload("res://PlayerSprites/Miner_Axe_2.png")
export (Texture) var duckingSprite = preload("res://PlayerSprites/Miner_Duck_1.png")
export (Texture) var dyingSprite = preload("res://PlayerSprites/Miner_Hurt.png");
export (Texture) var levelCompleteSprite = preload("res://PlayerSprites/Ending_1.png");

export (Vector2) var idleOffset = Vector2(0,0)
export (Vector2) var jumpingOffset = Vector2(0,0)
export (Vector2) var walkingOffset =  Vector2(0,0)
export (Vector2) var miningOffset = Vector2(2, -1)
export (Vector2) var duckingOffset = Vector2(1,0)
export (Vector2) var dyingOffset = Vector2(0,0)
export (Vector2) var levelCompleteOffset = Vector2(-6,-11)

export (bool) var is_protagonist = false;

const GRAVITY = 500.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const WALK_MAX_SPEED = 200
const JUMP_SPEED = 200
const JUMP_MAX_AIRBORNE_TIME = 0.2
#
const WALK_TOLERANCE = 1

enum {WAITING, WALKING, JUMPING, ATTACKING, DUCKING, DYING, MIDATTACKING, MIDATTACKING2}

var walk_left = false
var walk_right = false
var down = false
var jump_input = false
var attack = false
var target = null;
var jump_velocity = null;
var state = WAITING;
var frozen = false;


var velocity = Vector2()
var on_air_time = 100
var jumping = false #This will be set to true the frame after we process a jump input
var prev_jump_pressed = false
var ducking = false

var vulnerable = true;

signal target_reached
signal path_traversed
signal died
signal finished_mining #PATCH FOR TAP MINING
#Alias that we can refer to to save code
onready var sprite = $Sprite
onready var anim = $AnimationPlayer

#Dictates player animation states
enum {ANIM_WALKING, ANIM_IDLE, ANIM_MINING, ANIM_JUMPING, ANIM_FALLING, ANIM_DUCKING, ANIM_DYING}
var anim_state = ANIM_IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	idle(true);


#PATCH FOR TAP MINING:
func finish_cycle():
	emit_signal("finished_mining");

#Resets the character to a "neutral" state
#The location of the sprite is recentered
func _reset():
	#print(state);
	anim.stop();
	sprite.vframes = 1
	sprite.hframes = 1
	set_offset(Vector2(0,0))
	$CollisionShape2D.shape.extents = Vector2(5, 15);
	$CollisionShape2D.position = Vector2(0, 1);
	$MiningHitbox/CollisionShape2D.set_deferred("disabled", true)
	#print("reset");
	
#Player action that makes the miner stand in place
#input force_reset = function runs regardless of state
#If player is already in this state, nothing happens
func idle(force_reset=false):
	if anim_state == ANIM_IDLE and not force_reset: return
	anim_state = ANIM_IDLE
	_reset()
	set_offset(idleOffset)
	sprite.texture = idleSprite
	sprite.frame = 0;
	#print("idle")
	
func die():
	if anim_state != ANIM_DYING:
		anim_state = ANIM_DYING
		_reset()
		set_offset(dyingOffset)
		#THIS SHOULDN'T NEED TO BE HERE
		sprite.hframes = 2;
		sprite.texture = dyingSprite
		anim.play("Die")
		#yield(anim, "animation_finished");
		#queue_free();
		
func level_complete():
	if anim_state != ANIM_DYING:
		anim_state = ANIM_DYING
		_reset()
		sprite.texture = levelCompleteSprite
		set_offset(levelCompleteOffset)
		anim.play("Level Complete")
		#yield(anim, "animation_finished");
		#queue_free();
		
func getUp():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_IDLE:
		anim_state = ANIM_IDLE
		_reset()
		#print("getup")
		set_offset(duckingOffset)
		sprite.texture = duckingSprite
		anim.play("GetUp")

#Player action that makes the miner continuously duck
#If player is already in this state, nothing happens
func duck():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_DUCKING:
		anim_state = ANIM_DUCKING
		_reset()
		sprite.frame = 0;
		#print("duck")
		set_offset(duckingOffset)
		sprite.texture = duckingSprite
		anim.play("Duck")

#Player action that makes the miner continuously walk
#If player is already in this state, nothing happens
func walk():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_WALKING:
		anim_state = ANIM_WALKING
		_reset()
		set_offset(walkingOffset)
		#print("walk")
		sprite.texture = walkingSprite
		anim.play("Walk");

#Player action that makes the miner continuously mine in place
#If player is already in this state, nothing happens
func mine():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_MINING:
		anim_state = ANIM_MINING
		_reset()
		sprite.frame = 0;
		set_offset(miningOffset);
		#print("mine");
		randomize();
		var choice = randi()%3;
		if is_protagonist: choice = 0;			
		match choice:
			0:
				sprite.texture = miningSprite;
				anim.play("Mine");
			1:
				sprite.texture = miningSprite2;
				anim.play("Mine2");
			2:
				sprite.texture = miningSprite3;
				anim.play("Mine3");
		
#Player action that starts a jump motion (only rises up)
#If player is already in this state, nothing happens
func jump():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_JUMPING:
		anim_state = ANIM_JUMPING
		_reset()
		set_offset(jumpingOffset);
		#print("jump")
		sprite.texture = jumpingSprite
		anim.play("Jump");
		
#Player action that starts a falling motion
#If player is already in this state, nothing happens
func fall():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_FALLING:
		anim_state = ANIM_FALLING
		_reset()
		sprite.frame = 0;
		set_offset(jumpingOffset);
		#print("fall");
		sprite.texture = jumpingSprite
		anim.play("Fall");
	
#Flips the character in the correct direction
#input true = faces right,
#input false = faces left
func flip(right=true):
	if !right:
		if (sprite.flip_h == false):
			sprite.offset = Vector2(-sprite.offset.x, sprite.offset.y)
			$MiningHitbox/CollisionShape2D.position = Vector2(
				-$MiningHitbox/CollisionShape2D.position.x,
				$MiningHitbox/CollisionShape2D.position.y)
		sprite.flip_h = true;

	else:
		if (sprite.flip_h == true):
			sprite.offset = Vector2(-sprite.offset.x, sprite.offset.y)
			$MiningHitbox/CollisionShape2D.position = Vector2(
				-$MiningHitbox/CollisionShape2D.position.x,
				$MiningHitbox/CollisionShape2D.position.y)
		sprite.flip_h = false;
		
#Precondition: Not being modified by a RemoteTransform2D
func flip_towards(target : Vector2):
	if (target.x >= global_position.x):
		flip(true);
	else:
		flip(false);

#Wrapper function for setting the offset to a sprite, as to keep any flipped dimensions
func set_offset(new : Vector2):
	if (sprite.flip_h): #detect if sprite is "flipped"
		sprite.offset = Vector2(-new.x, new.y)
	else:
		sprite.offset = new;

#Function for dealing damage with axe; triggers enemy hurtbox
func _on_MiningHitbox_area_entered(area):
	 if area.is_in_group("enemy_hurtbox"):
        area.take_damage(10)

###################################################################################################


func reset_input():
	walk_left = false
	walk_right = false
	down = false
	jump_input = false
	attack = false
	target = null;
	jump_velocity = null;
	state = WAITING;
	
func walk_to(end):
	reset_input(); #PATCH
	
#	if abs(position.x - end.x) < WALK_TOLERANCE:
#		reset_input();
#		emit_signal("target_reached");
#		return;
	var right = true;
	if position.x - end.x > 0: right = false;
	if right: walk_right = true;
	else:
		walk_left = true;
	target = end;
	state = WALKING;	

func jump_to(end, velocity):
	reset_input(); #PATCH
		
	var right = true;
	if position.x - end.x > 0: right = false;
	flip(right);
	target = end;
	jump_velocity = velocity;
	jump_input = true;
	state = JUMPING;
	
func attack(node : Node, signal_name : String):
	attack = true;
	state = ATTACKING;
	node.connect(signal_name, self, "stop_attack", [], CONNECT_ONESHOT);
	
func stop_attack():
	attack = false;
	state = WAITING;

func duck_action(node : Node, signal_name : String):
	down = true;
	state = DUCKING;
	node.connect(signal_name, self, "stop_duck", [], CONNECT_ONESHOT);
	
func quick_duck():
	print("QUICK DUCK");
	down = true;
	state = DUCKING;

	#UNSAFE
	yield(anim, "animation_finished");
	print ("QUICK DUCK STOP")
	stop_duck();
#	anim.connect("animation_finished", self, "stop_duck", [], CONNECT_ONESHOT);
#	anim.connect("animation_changed", self, "cancel_duck", [], CONNECT_ONESHOT);
	
#func cancel_duck( old_name, new_name ):
#	if (old_name == "Duck"):
#		anim.disconnect("animation_finished", self, "stop_duck");
	
#SO, you are looking at why the "stop_duck" only happens on the bots during the next down_pressed event	
	
	
func stop_duck():
	down = false;
	state = WAITING;
	
func follow_path(path):
#	print("starting walk")
#	walk_to(path[0].src_location);
#	print(position);
#	print(path[0].src_location)
#	yield(self, "target_reached");
#	print("I'm there");
#	print(position);
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
	die();

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
	
	if attack:
		stop = true
		
	#Turn the character in the left direction and set state
	elif walk_left:
		velocity.x = -(WALK_MAX_SPEED/2.0)
		stop = false
		flip(false)
		if on_floor: walk()
		
	#Turn the character in the right direction and set state
	elif walk_right:
		velocity.x = (WALK_MAX_SPEED/2.0)
		stop = false
		flip(true)
		if on_floor: walk()
		
	#Cancel out all X velocity and set state (if mining or idling only)
	if stop and state != JUMPING and state != DYING:
		velocity.x = 0
		if on_floor and not jumping:
			velocity.y = 0;
		if attack: 
			if on_floor: mine();
		else: 
			if on_floor and not down: 
				if ducking: 
					getUp(); 
					ducking = false;
				else: 
					if not state == MIDATTACKING:
						idle(); 

	if on_floor and down:
		velocity.x = 0;
		duck();
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
			fall();
		else:
			jump();
	
	#On the frame after the jump command is issued, we account for the jump state
	#These confusing conditions allow us to jump a little after the character left the floor
	#This makes controls snappy
	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump_input and not prev_jump_pressed and not jumping:
#		velocity.y = -JUMP_SPEED
		velocity = jump_velocity
		jumping = true
		jump();
	
	on_air_time += delta 
	prev_jump_pressed = jump_input
	
	if state == WALKING and abs(position.x - target.x) < WALK_TOLERANCE:
		reset_input();
		emit_signal("target_reached")
		
		
	if state == JUMPING and abs(position.x - target.x) < WALK_TOLERANCE:
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