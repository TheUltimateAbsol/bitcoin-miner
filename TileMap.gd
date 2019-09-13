extends TileMap

# You can only create an AStar node from code, not from the Scene tab
onready var astar_node = AStar.new()
onready var point_scene = preload("res://point.tscn");
onready var left_edge_scene = preload("res://left_edge.tscn");
onready var right_edge_scene = preload("res://right_edge.tscn");
onready var solo_scene = preload("res://solo.tscn");
# The Tilemap node doesn't have clear bounds so we're defining the map's limits here
export(Vector2) var map_size = Vector2(20, 17)

# The path start and end variables use setter methods
# You can find them at the bottom of the script
var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

var nav_points = []
var _point_path = []

const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR = Color('#fff')

# get_used_cells_by_id is a method from the TileMap node
# here the id 0 corresponds to the grey tile, the obstacles
onready var obstacles = get_used_cells_by_id(0)
onready var _half_cell_size = cell_size / 2

func _ready():
	nav_points.resize(map_size.x*map_size.y);
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells(walkable_cells_list)
	#display_points(walkable_cells_list)
	
func display_points(walkable_cells_list):
	for point in walkable_cells_list:
		var point_index = calculate_point_index(point)
		var navpoint : NavPoint = nav_points[point_index] 
		var disp_point : Node
		match navpoint.type:
			Global.NavPointTypes.LEFT_EDGE: disp_point = left_edge_scene.instance();
			Global.NavPointTypes.RIGHT_EDGE: disp_point = right_edge_scene.instance();
			Global.NavPointTypes.SOLO: disp_point = solo_scene.instance();
			_: disp_point = point_scene.instance();
		var point_position = Vector2(8*point.x + 4, 8*point.y + 4)
		disp_point.position = point_position
		add_child(disp_point);
		

		if not (navpoint == null or navpoint.type == Global.NavPointTypes.NONE): 
			for link in navpoint.navLinks:
				var relative_point_position = nav_points[link.dest_id].location*8 + Vector2(4,4)
				
				var line = Line2D.new()
				line.add_point(point_position)
				line.add_point(relative_point_position)
				line.z_as_relative = false
				line.z_index = 4095
				line.width = 2
				add_child(line);
		
#		var points_relative = PoolVector2Array([
#			Vector2(point.x + 1, point.y),
#			Vector2(point.x - 1, point.y),
#			Vector2(point.x, point.y + 1),
#			Vector2(point.x, point.y - 1)])
#		for point_relative in points_relative:
#			var point_relative_index = calculate_point_index(point_relative)
#			var point_relative_position = Vector2(8*point_relative.x + 4, 8*point_relative.y + 4)
#			if astar_node.are_points_connected(point_index, point_relative_index):
#				#draw line
#				var line = Line2D.new()
#				line.add_point(point_position)
#				line.add_point(point_relative_position)
#				line.z_as_relative = false
#				line.z_index = 4095
#				line.width = 2
#				add_child(line);
				


# Click and Shift force the start and end position of the path to update
# and the node to redraw everything
#func _input(event):
#	if event.is_action_pressed('click') and Input.is_key_pressed(KEY_SHIFT):
#		# To call the setter method from this script we have to use the explicit self.
#		self.path_start_position = world_to_map(get_global_mouse_position())
#	elif event.is_action_pressed('click'):
#		self.path_end_position = world_to_map(get_global_mouse_position())


# Loops through all cells within the map's bounds and
# adds all points to the astar_node, except the obstacles

#Also creates navpoints
func astar_add_walkable_cells(obstacles = []):
	var actual_platform_index = 0
	var platform_started = false
	var points_array = []
	for y in range(map_size.y):
		platform_started = false
		for x in range(map_size.x):
			var point = Vector2(x, y)
			if point in obstacles:
				continue
			var floor_tile = Vector2(x, y+1)
			if not (floor_tile in obstacles):
				continue
			points_array.append(point)
			# The AStar class references points with indices
			# Using a function to calculate the index from a point's coordinates
			# ensures we always get the same index with the same input point
			var point_index = calculate_point_index(point)
			# AStar works for both 2d and 3d, so we have to convert the point
			# coordinates from and to Vector3s
			astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
			
			#At this point we know that the point is a valid floor tile
			var navpoint = NavPoint.new();
			navpoint.init(point, point_index)
			
			if not platform_started:
				navpoint.set_type(Global.NavPointTypes.LEFT_EDGE, actual_platform_index)
				platform_started = true
				
			if platform_started:
				var lower_right = Vector2(point.x + 1, point.y +1);
				var right = Vector2(point.x + 1, point.y);
				var is_right_free =  true if not (right in obstacles) else false
				var is_lower_right_free = true if not (lower_right in obstacles) else false
				var is_right_valid =  not is_outside_map_bounds(right);
				if (is_right_valid
				and is_right_free and not is_lower_right_free and
				navpoint.type != Global.NavPointTypes.LEFT_EDGE):
					navpoint.set_type(Global.NavPointTypes.PLATFORM, actual_platform_index);
				if (is_lower_right_free or not is_right_free) or not is_right_valid:
					if (navpoint.type == Global.NavPointTypes.LEFT_EDGE):
						navpoint.set_type(Global.NavPointTypes.SOLO, actual_platform_index);
					else:
						navpoint.set_type(Global.NavPointTypes.RIGHT_EDGE, actual_platform_index);
					actual_platform_index += 1
					platform_started = false;
					
			nav_points[point_index] = navpoint;
			
	return points_array


# Once you added all points to the AStar node, you've got to connect them
# The points don't have to be on a grid: you can use this class
# to create walkable graphs however you'd like
# It's a little harder to code at first, but works for 2d, 3d,
# orthogonal grids, hex grids, tower defense games...

#Also connects all non-null navpoints
func astar_connect_walkable_cells(points_array):
	for navpoint in nav_points:
		if navpoint == null or navpoint.type == Global.NavPointTypes.NONE: continue
		if navpoint.location.x >= map_size.x-1 : continue
		var right_location = navpoint.location + Vector2(1,0)
		print(navpoint.location, right_location);
		var right = nav_points[calculate_point_index(right_location)];
		if right == null or right.type == Global.NavPointTypes.NONE: continue
		navpoint.link(right, 10, Global.NavLinkTypes.FLOOR)
		right.link(navpoint, 10, Global.NavLinkTypes.FLOOR)
#	for point in points_array:
#		var point_index = calculate_point_index(point)
#		# For every cell in the map, we check the one to the top, right.
#		# left and bottom of it. If it's in the map and not an obstalce,
#		# We connect the current point with it
#		var points_relative = PoolVector2Array([
#			Vector2(point.x + 1, point.y),
#			Vector2(point.x - 1, point.y),
#			Vector2(point.x, point.y + 1),
#			Vector2(point.x, point.y - 1)])
#		for point_relative in points_relative:
#			var point_relative_index = calculate_point_index(point_relative)
#
#			if is_outside_map_bounds(point_relative):
#				continue
#			if not astar_node.has_point(point_relative_index):
#				continue
#			# Note the 3rd argument. It tells the astar_node that we want the
#			# connection to be bilateral: from point A to B and B to A
#			# If you set this value to false, it becomes a one-way path
#			# As we loop through all points we can set it to false
#			astar_node.connect_points(point_index, point_relative_index, false)


# This is a variation of the method above
# It connects cells horizontally, vertically AND diagonally
func astar_connect_walkable_cells_diagonal(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		for local_y in range(3):
			for local_x in range(3):
				var point_relative = Vector2(point.x + local_x - 1, point.y + local_y - 1)
				var point_relative_index = calculate_point_index(point_relative)

				if point_relative == point or is_outside_map_bounds(point_relative):
					continue
				if not astar_node.has_point(point_relative_index):
					continue
				astar_node.connect_points(point_index, point_relative_index, true)


func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y


func calculate_point_index(point):
	return point.x + map_size.x * point.y


func _get_path(world_start, world_end):
	self.path_start_position = world_to_map(world_start)
	self.path_end_position = world_to_map(world_end)
	_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = map_to_world(Vector2(point.x, point.y)) + _half_cell_size
		path_world.append(point_world)
	return path_world


func _recalculate_path():
	clear_previous_path_drawing()
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	# Redraw the lines and circles from the start to the end point
	update()


func clear_previous_path_drawing():
	if not _point_path:
		return
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]
	set_cell(point_start.x, point_start.y, -1)
	set_cell(point_end.x, point_end.y, -1)


func _draw():
	if not _point_path:
		return
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]

	set_cell(point_start.x, point_start.y, 1)
	set_cell(point_end.x, point_end.y, 2)

	var last_point = map_to_world(Vector2(point_start.x, point_start.y)) + _half_cell_size
	for index in range(1, len(_point_path)):
		var current_point = map_to_world(Vector2(_point_path[index].x, _point_path[index].y)) + _half_cell_size
		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
		last_point = current_point


# Setters for the start and end path values.
func _set_path_start_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

	set_cell(path_start_position.x, path_start_position.y, -1)
	set_cell(value.x, value.y, 1)
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()


func _set_path_end_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

	set_cell(path_start_position.x, path_start_position.y, -1)
	set_cell(value.x, value.y, 2)
	path_end_position = value
	if path_start_position != value:
		_recalculate_path()