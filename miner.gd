extends Node2D

var walkingSprite = preload("res://Miner Walking Compress.png")
var idleSprite = preload("res://Miner Compress.png")
var miningSprite = preload("res://Miner Axe.png")
onready var sprite = $Sprite
onready var anim = $AnimationPlayer

enum {WALKING, IDLE, MINING}
var state = IDLE

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	idle(true);

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _reset():
	anim.stop();
	sprite.vframes = 1
	sprite.hframes = 1
	set_offset(Vector2(0,0))
	sprite.frame = 0;
	$MiningHitbox/CollisionShape2D.disabled = true;
	
func idle(force_reset=false):
	if state == IDLE and not force_reset: return
	state = IDLE
	_reset()
	set_offset(Vector2(0,0))
	sprite.texture = idleSprite
	
func walk():
	if state != WALKING:
		state = WALKING
		_reset()
		set_offset(Vector2(0,0))
		anim.play("Walk");
	
func mine():
	if state != MINING:
		state = MINING
		_reset()
		set_offset(Vector2(2, -1));
		anim.play("Mine");

	
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

		

func set_offset(new : Vector2):
	if (sprite.flip_h):
		sprite.offset = Vector2(-new.x, new.y)
	else:
		sprite.offset = new;

func _on_MiningHitbox_area_entered(area):
	 if area.is_in_group("enemy_hurtbox"):
        area.take_damage(10)
