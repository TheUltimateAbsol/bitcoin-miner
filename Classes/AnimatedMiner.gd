extends KinematicBody2D
class_name AnimatedMiner

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
export (Texture) var airAttackSprite = preload("res://PlayerSprites/air_attack_3.0.png");

export (Vector2) var idleOffset = Vector2(0,0)
export (Vector2) var jumpingOffset = Vector2(0,0)
export (Vector2) var walkingOffset =  Vector2(0,0)
export (Vector2) var miningOffset = Vector2(2, -1)
export (Vector2) var duckingOffset = Vector2(1,0)
export (Vector2) var dyingOffset = Vector2(0,0)
export (Vector2) var levelCompleteOffset = Vector2(-6,-11)
export (Vector2) var airAttackOffset = Vector2(0,0)

#Dictates player animation states
enum {ANIM_WALKING, ANIM_IDLE, ANIM_MINING, ANIM_JUMPING, ANIM_FALLING, ANIM_DUCKING, ANIM_DYING, ANIM_AIR_ATTACK}
var anim_state = ANIM_IDLE

onready var sprite = $Sprite
onready var anim = $AnimationPlayer
export (bool) var is_protagonist = false;
var vulnerable = true;

func _ready():
	idle_anim(true);

#Player action that makes the miner stand in place
#input force_reset = function runs regardless of state
#If player is already in this state, nothing happens
func idle_anim(force_reset=false):
	if anim_state == ANIM_IDLE and not force_reset: return
	anim_state = ANIM_IDLE
	_anim_reset()
	set_offset(idleOffset)
	sprite.texture = idleSprite
	sprite.frame = 0;
	#print("idle")
	
func die_anim():
	if anim_state != ANIM_DYING:
		anim_state = ANIM_DYING
		_anim_reset()
		set_offset(dyingOffset)
		#THIS SHOULDN'T NEED TO BE HERE
		sprite.hframes = 2;
		sprite.texture = dyingSprite
		anim.play("Die")
		#yield(anim, "animation_finished");
		#queue_free();
		
func level_complete_anim():
	if anim_state != ANIM_DYING:
		anim_state = ANIM_DYING
		_anim_reset()
		sprite.texture = levelCompleteSprite
		set_offset(levelCompleteOffset)
		anim.play("Level Complete")
		#yield(anim, "animation_finished");
		#queue_free();
		
func getUp_anim():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_IDLE:
		anim_state = ANIM_IDLE
		_anim_reset()
		#print("getup")
		set_offset(duckingOffset)
		sprite.texture = duckingSprite
		anim.play("GetUp")

#Player action that makes the miner continuously duck
#If player is already in this state, nothing happens
func duck_anim():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_DUCKING:
		anim_state = ANIM_DUCKING
		_anim_reset()
		sprite.frame = 0;
		#print("duck")
		set_offset(duckingOffset)
		sprite.texture = duckingSprite
		anim.play("Duck")

#Player action that makes the miner continuously walk
#If player is already in this state, nothing happens
func walk_anim():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_WALKING:
		anim_state = ANIM_WALKING
		_anim_reset()
		set_offset(walkingOffset)
		#print("walk")
		sprite.texture = walkingSprite
		anim.play("Walk");

#Player action that makes the miner continuously mine in place
#If player is already in this state, nothing happens
func mine_anim():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_MINING:
		anim_state = ANIM_MINING
		_anim_reset()
		sprite.frame = 0;
		set_offset(miningOffset);
		#print("mine");
		randomize();
		var choice = randi()%3;
		if is_protagonist: choice = 0;			
		match choice:
			0:
				sprite.texture = miningSprite;
				sprite.hframes = 2
				sprite.vframes = 4
				anim.play("Mine");
			1:
				sprite.texture = miningSprite2;
				sprite.hframes = 3
				sprite.vframes = 3
				anim.play("Mine2");
			2:
				sprite.texture = miningSprite3;
				sprite.hframes = 3
				sprite.vframes = 3
				anim.play("Mine3");
		
#Player action that starts a jump motion (only rises up)
#If player is already in this state, nothing happens
func jump_anim():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_JUMPING:
		anim_state = ANIM_JUMPING
		_anim_reset()
		set_offset(jumpingOffset);
		#print("jump")
		sprite.texture = jumpingSprite
		anim.play("Jump");
		
#Player action that starts a air attack
#If player is already in this state, nothing happens
func air_attack_anim():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_AIR_ATTACK:
		anim_state = ANIM_AIR_ATTACK
		_anim_reset()
		sprite.hframes = 3
		sprite.vframes = 4
		set_offset(airAttackOffset);
		sprite.texture = airAttackSprite
		anim.play("Air Attack");
		
#Player action that starts a falling motion
#If player is already in this state, nothing happens
func fall_anim():
	if anim_state == ANIM_DYING: return
	if anim_state != ANIM_FALLING:
		anim_state = ANIM_FALLING
		_anim_reset()
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

#Resets the character to a "neutral" state
#The location of the sprite is recentered
func _anim_reset():
	#print(state);
	anim.stop();
	sprite.vframes = 1
	sprite.hframes = 1
	set_offset(Vector2(0,0))
#	$CollisionShape2D.shape.extents = Vector2(5, 15);
#	$CollisionShape2D.position = Vector2(0, 1);
	$MiningHitbox/CollisionShape2D.set_deferred("disabled", true)
	$MiningHitbox/AirAttack.set_deferred("disabled", true)
	#print("reset");

#PATCH FOR TAP MINING:
signal finished_mining #PATCH FOR TAP MINING
func finish_cycle():
	emit_signal("finished_mining");	