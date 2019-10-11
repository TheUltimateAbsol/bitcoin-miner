extends KinematicBody2D


#Load the sprites that we can alternate between
var idleSprite = preload("res://PlayerSprites/Miner Compress.png")


const GRAVITY = 500.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const WALK_MAX_SPEED = 200
const JUMP_SPEED = 200
const JUMP_MAX_AIRBORNE_TIME = 0.2
#
const WALK_TOLERANCE = 1

enum {WAITING, WALKING, JUMPING, ATTACKING, DUCKING}

var walk_left = false
var walk_right = false
var down = false
var jump_input = false
var attack = false
var target = null;
var jump_velocity = null;
var state = WAITING;


var velocity = Vector2()
var on_air_time = 100
var jumping = false #This will be set to true the frame after we process a jump input
var prev_jump_pressed = false
var ducking = false

signal target_reached
signal path_traversed


#Alias that we can refer to to save code
onready var sprite = $Sprite
onready var anim = $AnimationPlayer

#Dictates player animation states
enum {ANIM_WALKING, ANIM_IDLE, ANIM_MINING, ANIM_JUMPING, ANIM_FALLING, ANIM_DUCKING}
var anim_state = ANIM_IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	idle(true);

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
	$MiningHitbox/CollisionShape2D.disabled = true;
	#print("reset");
	
#Player action that makes the miner stand in place
#input force_reset = function runs regardless of state
#If player is already in this state, nothing happens
func idle(force_reset=false):
	if anim_state == ANIM_IDLE and not force_reset: return
	anim_state = ANIM_IDLE
	_reset()
	set_offset(Vector2(0,0))
	sprite.texture = idleSprite
	sprite.frame = 0;
	#print("idle")
	
func getUp():
	if anim_state != ANIM_IDLE:
		anim_state = ANIM_IDLE
		_reset()
		#print("getup")
		set_offset(Vector2(1,0))
		anim.play("GetUp")

#Player action that makes the miner continuously duck
#If player is already in this state, nothing happens
func duck():
	if anim_state != ANIM_DUCKING:
		anim_state = ANIM_DUCKING
		_reset()
		sprite.frame = 0;
		#print("duck")
		set_offset(Vector2(1,0))
		anim.play("Duck")

#Player action that makes the miner continuously walk
#If player is already in this state, nothing happens
func walk():
	if anim_state != ANIM_WALKING:
		anim_state = ANIM_WALKING
		_reset()
		set_offset(Vector2(0,0))
		#print("walk")
		anim.play("Walk");

#Player action that makes the miner continuously mine in place
#If player is already in this state, nothing happens
func mine():
	if anim_state != ANIM_MINING:
		anim_state = ANIM_MINING
		_reset()
		sprite.frame = 0;
		set_offset(Vector2(2, -1));
		#print("mine");
		anim.play("Mine");
		
#Player action that starts a jump motion (only rises up)
#If player is already in this state, nothing happens
func jump():
	if anim_state != ANIM_JUMPING:
		anim_state = ANIM_JUMPING
		_reset()
		set_offset(Vector2(0,0));
		#print("jump")
		anim.play("Jump");
		
#Player action that starts a falling motion
#If player is already in this state, nothing happens
func fall():
	if anim_state != ANIM_FALLING:
		anim_state = ANIM_FALLING
		_reset()
		sprite.frame = 0;
		set_offset(Vector2(0,0));
		#print("fall");
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
	var right = true;
	if position.x - end.x > 0: right = false;
	if right: walk_right = true;
	else:
		walk_left = true;
	target = end;
	state = WALKING;	

func jump_to(end, velocity):
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
	down = true;
	state = DUCKING;
	anim.connect("animation_finished", self, "stop_duck", [], CONNECT_ONESHOT);
	
func stop_duck():
	down = false;
	state = WAITING;
	print("FSDA")
	
func follow_path(path):
	for link in path:
		if link.type == Global.NavLinkTypes.FLOOR:
			walk_to(link.dest_location);
		if link.type == Global.NavLinkTypes.JUMP:
			jump_to(link.dest_location, link.init_velocity);
		yield(self, "target_reached");
		
	emit_signal("path_traversed");

func _physics_process(delta):
	
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
	if stop and state != JUMPING:
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
				else: idle(); 

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
	if not is_on_floor():
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

func is_waiting():
	return (state == WAITING)
	
##May also correspond to an upwards jump
func can_attack():
	return (state == WAITING)