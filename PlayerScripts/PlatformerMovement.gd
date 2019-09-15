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

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

#This is just an alias
onready var main = $Miner

var velocity = Vector2()
var on_air_time = 100
var jumping = false #This will be set to true the frame after we process a jump input
var prev_jump_pressed = false

signal paused

func _ready():
	var children = get_tree().get_nodes_in_group("enemy")
	for child in children:
		print(child);
		child.connect("died", self, "death")
#
#
func death(victim):
	print("OOF")
	#removing node from the scene
	remove_child(victim)
	victim.queue_free()

func _physics_process(delta):
	
	# Create gravity (this will be applied later)
	var force = Vector2(0, GRAVITY)
	if main.is_on_floor():
		force = Vector2(0,0)
	
	#Check input states
	var walk_left = Input.is_action_pressed("left")
	var walk_right = Input.is_action_pressed("right")
	var jump = Input.is_action_pressed("jump")
	var attack = Input.is_action_pressed("attack")
	
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
	if stop:
		velocity.x = 0
		if on_floor and not jumping:
			velocity.y = 0;
		if attack: 
			if on_floor: main.mine();
		else: 
			if on_floor: main.idle(); 

	
	# Integrate forces to velocity (gravity)
	velocity += force * delta	
	
	# Integrate velocity into motion and move
	#Move_and_slide_with snap acts wierd when not on the ground, so we adjust for it
	if jumping or stop:
			velocity = main.move_and_slide_with_snap(velocity, Vector2(), Vector2(0, -1), false, 4, 0.9)
	else:
		velocity = main.move_and_slide_with_snap(velocity, Vector2(0, 15), Vector2(0, -1), false, 4, 0.9)
	
	#reset air-time counter (gives window for jumping when in air)
	if on_floor:
		on_air_time = 0
		
	# If falling, no longer jumping
	if jumping and velocity.y > 0:
		jumping = false
#		note, this leaves a bug where if you initiate a jump and walk up a platform, you will remain jumping
	
	#This gives the falling or jumping animations
	if not main.is_on_floor():
		if velocity.y > 0:
			main.fall();
		else:
			main.jump();
	
	#On the frame after the jump command is issued, we account for the jump state
	#These confusing conditions allow us to jump a little after the character left the floor
	#This makes controls snappy
	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping:
		velocity.y = -JUMP_SPEED
		jumping = true
		main.jump();
	
	on_air_time += delta 
	prev_jump_pressed = jump
	
	
func _on_Pause_pressed():
	print("PAUSED")
	get_tree().paused = true
	$pause_menu.show()


func _on_pause_menu_unpause():
	print("UNPAUSED")
	get_tree().paused = false
	$pause_menu.hide()
