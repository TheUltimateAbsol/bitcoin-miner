extends Tween

export (NodePath) var target_node = null
export (int) var max_displacement = 20
export (int) var easing_length = 20
export (float) var duration = 5.0

func _ready():
	$Path2D.position = get_node(target_node).position
	$Path2D/PathFollow2D/RemoteTransform2D.remote_path = (
		$Path2D/PathFollow2D/RemoteTransform2D.get_path_to(get_node(target_node))
	)
	
	activate()
	
func activate():
	randomize()
	var x = rand_range(-max_displacement, max_displacement)
	var y = rand_range(-max_displacement, max_displacement)
	var target = Vector2(x,y).clamped(max_displacement) #+ $Path2D.position
	var normal = target.tangent().normalized()*easing_length
	
	$Path2D.curve.set_point_position(1, target)
	$Path2D.curve.set_point_in(1, normal)
	$Path2D.curve.set_point_out(1, -normal)
	
	
	interpolate_property($Path2D/PathFollow2D, "unit_offset", 0.0, 1.0, duration, Tween.TRANS_LINEAR)
	start()

func _on_FloatyTweener_tween_all_completed():
#	activate()
	pass
