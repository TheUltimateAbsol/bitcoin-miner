extends Node2D



func _ready():
	# Define any shape
	var check_shape = RectangleShape2D.new()
	check_shape.set_extents(Vector2(5,5));
	
	# Get space and state of the subject body
	var space_state = get_world_2d().direct_space_state
#	var space = Physics2DServer.body_get_space(body.get_rid())
#	var state = Physics2DServer.space_get_direct_state(space)
	
	# Setup shape query parameters
	var params = Physics2DShapeQueryParameters.new()
	params.set_shape_rid(check_shape.get_rid())
	# Set other parameters if needed
	# params.set_object_type_mask(Physics2DDirectSpaceState.TYPE_MASK_COLLISION)
	params.set_transform(global_transform)
	
	var result = space_state.intersect_shape(params)
	
	print(result)