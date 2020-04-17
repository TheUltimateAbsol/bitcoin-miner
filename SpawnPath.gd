extends Path2D

var current_bot:Miner

signal path_completed

const width = 100
const height = 25

func load_params(endpos, is_facing_right):
	var dx = curve.get_point_position(2).x - curve.get_point_position(0).x
	var dy = curve.get_point_position(1).y - 0.5*(curve.get_point_position(0).y + curve.get_point_position(2).x)
	var startpos
	if is_facing_right:
		startpos = endpos - Vector2(dx, 0)
	else:
		startpos = endpos + Vector2(dx, 0)
	
	curve.set_point_position(0, startpos)
	curve.set_point_position(2, endpos)
	curve.set_point_position(1, Vector2(startpos.x + (endpos.x - startpos.x)/2, startpos.y + dy))
	
	
	print(curve.get_point_position(0), curve.get_point_position(1), curve.get_point_position(2))
	return self

func play(bot:Miner):
	current_bot = bot
	$PathFollow2D/RemoteTransform2D.remote_path = bot.get_path()
	current_bot.jump_anim()
	$AnimationPlayer.play("Activate")

func at_midpoint():
	current_bot.fall_anim()

func _on_AnimationPlayer_animation_finished(_anim_name):
#	$PathFollow2D/RemoteTransform2D.remote_path = null
	emit_signal("path_completed")
