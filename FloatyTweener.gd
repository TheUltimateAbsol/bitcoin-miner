extends Tween

#NOTE: THIS DOES NOT WORK VERY WELL WITH SCENES NESTED IN CONTROLS
#I HAVE NO IDEA WHY, BUT IT SEEMS LIKE THE POSITIONING IS TOO ABSOLUTE

export (NodePath) var target_node = null
export (int) var max_displacement = 20
export (int) var easing_length = 20
export (float) var duration = 10

var projectResolution= Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height")
)

func _ready():
	$Path2D.global_position = get_node(target_node).global_position
	$Path2D/PathFollow2D/RemoteTransform2D.remote_path = (
		$Path2D/PathFollow2D/RemoteTransform2D.get_path_to(get_node(target_node))
	)
	
	activate()
	
func activate():
#	randomize()
	var rand_generate = RandomNumberGenerator.new()
#	var seed_position = Vector2(int($Path2D.global_position.x)%int(projectResolution.x), int($Path2D.global_position.y)%int(projectResolution.y))
##	var random_seed = float(
##			seed_position.x
##			+ (seed_position.y)*projectResolution.x
##		)/float(projectResolution.x*projectResolution.y)
	rand_generate.randomize()
	var x = rand_generate.randf_range(-max_displacement, max_displacement)
	var y = rand_generate.randf_range(-max_displacement, max_displacement)
	var target = Vector2(x,y)#+ $Path2D.position
	var normal = target.tangent().normalized()*easing_length
	
	
	print(target)
	$Path2D.curve.set_point_position(1, target)
	$Path2D.curve.set_point_in(1, normal)
	$Path2D.curve.set_point_out(1, -normal)
	
	
	interpolate_property($Path2D/PathFollow2D, "unit_offset", 0.0, 1.0, duration*rand_generate.randf_range(.5, 1), Tween.TRANS_LINEAR)
	start()
