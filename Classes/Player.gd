extends "res://Classes/miner.gd"

export (Texture) var gameoverSprite = preload("res://PlayerSprites/protagonist-death_2.0.png")
export (Vector2) var gameoverOffset = Vector2(0,0)

func _ready():
	._ready();
	
func game_over():
	if anim_state != ANIM_DYING:
		anim_state = ANIM_DYING
		_anim_reset();
		set_offset(gameoverOffset)
		sprite.texture = gameoverSprite
		anim.play("Game Over")

func damage():
	if vulnerable == false: return false;
	reset_input();
	freeze()
	state = DYING;
	emit_signal("died")
	return true;
	
