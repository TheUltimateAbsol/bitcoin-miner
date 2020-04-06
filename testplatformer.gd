extends Node

onready var main = $Miner


# This demo shows how to build a kinematic controller.

# Member variables
const GRAVITY = 500.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300
const JUMP_SPEED = 200
const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

var velocity = Vector2()
var on_air_time = 100
var jumping = false

var prev_jump_pressed = false


func _physics_process(delta):
	# Create forces
	var force = Vector2(0, GRAVITY)
	if main.is_on_floor():
		force = Vector2(0,0)
	
	var walk_left = Input.is_action_pressed("left")
	var walk_right = Input.is_action_pressed("right")
	var jump = Input.is_action_pressed("jump")
	var attack = Input.is_action_pressed("attack")
	
	var stop = true
	
	if attack:
		stop = true
	elif walk_left:
#		if velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED:
#			force.x -= WALK_FORCE
		velocity.x = -(WALK_MAX_SPEED/2)
		stop = false
		main.flip(false)
		main.walk()
	elif walk_right:
#		if velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED:
#			force.x += WALK_FORCE
		velocity.x = (WALK_MAX_SPEED/2)
		stop = false
		main.flip(true)
		main.walk()
	if stop:
#		var vsign = sign(velocity.x)
#		var vlen = abs(velocity.x)
#
#		vlen -= STOP_FORCE * delta
#		if vlen < 0:
#			vlen = 0
#
#		velocity.x = vlen * vsign
		velocity.x = 0
		if main.is_on_floor() and not jumping:
			velocity.y = 0;
		if attack: 
			main.mine();
		else: 
			main.idle(); 

	
	# Integrate forces to velocity
	velocity += force * delta	
	# Integrate velocity into motion and move
	if jumping or stop:
			velocity = main.move_and_slide_with_snap(velocity, Vector2(), Vector2(0, -1), false, 4, 0.9)
	else:
		print(velocity)
		velocity = main.move_and_slide_with_snap(velocity, Vector2(0, 15), Vector2(0, -1), false, 4, 0.9)
	
	if main.is_on_floor():
		on_air_time = 0
		
	if jumping and velocity.y > 0:
		# If falling, no longer jumping
		jumping = false
#		note, this leaves a bug where if you initiate a jump and walk up a platform, you will remain jumping
	
	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping:
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		velocity.y = -JUMP_SPEED
		print("JUMPING")
		jumping = true
	
	on_air_time += delta
	prev_jump_pressed = jump
	
func _on_pause_button_pressed():
	print("PAUSED")
	get_tree().paused = true
	$pause_menu.show()
	
	
