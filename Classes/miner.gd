extends Node2D

#Load the sprites that we can alternate between
var walkingSprite = preload("res://PlayerSprites/Miner Walking Compress.png")
var idleSprite = preload("res://PlayerSprites/Miner Compress.png")
var miningSprite = preload("res://PlayerSprites/Miner Axe.png")

#Alias that we can refer to to save code
onready var sprite = $Sprite
onready var anim = $AnimationPlayer

#Dictates player states
enum {WALKING, IDLE, MINING, JUMPING, FALLING, DUCKING}
var state = IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	idle(true);

#Resets the character to a "neutral" state
#The location of the sprite is recentered
func _reset():
	print(state);
	anim.stop();
	sprite.vframes = 1
	sprite.hframes = 1
	set_offset(Vector2(0,0))
	$CollisionShape2D.shape.extents = Vector2(5, 15);
	$CollisionShape2D.position = Vector2(0, 1);
	$MiningHitbox/CollisionShape2D.disabled = true;
	print("reset");
	
#Player action that makes the miner stand in place
#input force_reset = function runs regardless of state
#If player is already in this state, nothing happens
func idle(force_reset=false):
	if state == IDLE and not force_reset: return
	state = IDLE
	_reset()
	set_offset(Vector2(0,0))
	sprite.texture = idleSprite
	sprite.frame = 0;
	print("idle")
	
func getUp():
	if state != IDLE:
		state = IDLE
		_reset()
		print("getup")
		set_offset(Vector2(1,0))
		anim.play("GetUp")

#Player action that makes the miner continuously duck
#If player is already in this state, nothing happens
func duck():
	if state != DUCKING:
		state = DUCKING
		_reset()
		sprite.frame = 0;
		print("duck")
		set_offset(Vector2(1,0))
		anim.play("Duck")

#Player action that makes the miner continuously walk
#If player is already in this state, nothing happens
func walk():
	if state != WALKING:
		state = WALKING
		_reset()
		set_offset(Vector2(0,0))
		print("walk")
		anim.play("Walk");

#Player action that makes the miner continuously mine in place
#If player is already in this state, nothing happens
func mine():
	if state != MINING:
		state = MINING
		_reset()
		sprite.frame = 0;
		set_offset(Vector2(2, -1));
		print("mine");
		anim.play("Mine");
		
#Player action that starts a jump motion (only rises up)
#If player is already in this state, nothing happens
func jump():
	if state != JUMPING:
		state = JUMPING
		_reset()
		set_offset(Vector2(0,0));
		print("jump")
		anim.play("Jump");
		
#Player action that starts a falling motion
#If player is already in this state, nothing happens
func fall():
	if state != FALLING:
		state = FALLING
		_reset()
		sprite.frame = 0;
		set_offset(Vector2(0,0));
		print("fall");
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
