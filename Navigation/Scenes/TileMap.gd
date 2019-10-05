extends TileMap

# You can only create an AStar node from code, not from the Scene tab
onready var astar_node = AStar.new()
onready var point_scene = preload("res://Navigation/Scenes/point.tscn");
onready var left_edge_scene = preload("res://Navigation/Scenes/left_edge.tscn");
onready var right_edge_scene = preload("res://Navigation/Scenes/right_edge.tscn");
onready var solo_scene = preload("res://Navigation/Scenes/solo.tscn");
# The Tilemap node doesn't have clear bounds so we're defining the map's limits here
export(Vector2) var map_size = Vector2(20, 17)

var nav_points = []
var valid_points = []
var _point_path = []

const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR = Color('#fff')
const SPEED_DIVISIONS = 10;
const HEIGHT_DIVISIONS = 10;
const WALK_MAX_SPEED = 100
const JUMP_MAX_SPEED = 200
const GRAVITY = 500.0 # pixels/second/second
const MAX_GROUND_DISTANCE = 4.0
const MINER_COLLISION = Vector2(5,15)

# get_used_cells_by_id is a method from the TileMap node
# here the id 0 corresponds to the grey tile, the obstacles
onready var obstacles = get_used_cells_by_id(0)
onready var _half_cell_size = cell_size / 2

func _ready():
	pass
	nav_points.resize(map_size.x*map_size.y);
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells(walkable_cells_list, obstacles)
#	display_points(walkable_cells_list, false)
	#var path = connect_path(valid_points[1].index, valid_points[valid_points.size()-1].index)
	#display_path(path);

func display_points(walkable_cells_list, display_links=false):
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
		
		if display_links:
			if not (navpoint == null or navpoint.type == Global.NavPointTypes.NONE): 
				for link in navpoint.navLinks:
					var relative_point_position = to_relative(nav_points[link.dest_id].location)
					
					var line = Line2D.new()
					line.add_point(point_position)
					line.add_point(relative_point_position)
					line.z_as_relative = false
					line.z_index = 4094
					line.width = 2
					
					match (link.type):
						Global.NavLinkTypes.FLOOR:
							line.set_default_color(Color.blue)
						Global.NavLinkTypes.FALL:
							line.set_default_color(Color.aquamarine)
						Global.NavLinkTypes.JUMP:
							line.set_default_color(Color.gold)
						
					add_child(line);
	
func display_path(path):
	if path == null: return;
	for link in path:
		var origin_relative_point_position = to_relative(nav_points[link.src_id].location)
		var dest_relative_point_position = to_relative(nav_points[link.dest_id].location)
		#print(origin_relative_point_position, dest_relative_point_position)
		
		var line = Line2D.new()
		line.add_point(origin_relative_point_position)
		line.add_point(dest_relative_point_position)
		line.z_as_relative = false
		line.z_index = 4095
		line.width = 2
		
		line.set_default_color(Color.white)
			
		add_child(line);
		
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
			# The AStar class references points with indices
			# Using a function to calculate the index from a point's coordinates
			# ensures we always get the same index with the same input point
			var point_index = calculate_point_index(point)
			var navpoint = NavPoint.new(point, point_index)
			nav_points[point_index] = navpoint;
			#print(point*8 + Vector2(4,4));
			
			if point in obstacles:
				continue
			var floor_tile = Vector2(x, y+1)
			if not (floor_tile in obstacles):
				continue
				
			points_array.append(point)

#			# AStar works for both 2d and 3d, so we have to convert the point
#			# coordinates from and to Vector3s
#			astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
			
			#At this point we know that the point is a valid floor tile
			
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
			valid_points.push_back(navpoint);
			
	return points_array


# Once you added all points to the AStar node, you've got to connect them
# The points don't have to be on a grid: you can use this class
# to create walkable graphs however you'd like
# It's a little harder to code at first, but works for 2d, 3d,
# orthogonal grids, hex grids, tower defense games...

#Also connects all non-null navpoints
func astar_connect_walkable_cells(points_array, obstacles = []):
	
	var walk_time = 8.0/WALK_MAX_SPEED;
	#print("WALK TIME " + str(walk_time))
	for navpoint in nav_points:
		if navpoint == null or navpoint.type == Global.NavPointTypes.NONE: continue
		#Connect floor links
		if navpoint.location.x >= map_size.x-1 : continue
		var right_location = navpoint.location + Vector2(1,0)
		var right = nav_points[calculate_point_index(right_location)];
		if right == null or right.type == Global.NavPointTypes.NONE: continue
		navpoint.link(right, walk_time, Global.NavLinkTypes.FLOOR)
		right.link(navpoint, walk_time, Global.NavLinkTypes.FLOOR)
		
	#Connect fall links
#	for navpoint in nav_points:
#		if navpoint == null or navpoint.type == Global.NavPointTypes.NONE: continue
#		if (navpoint.type == Global.NavPointTypes.LEFT_EDGE or 
#			navpoint.type == Global.NavPointTypes.RIGHT_EDGE or
#			navpoint.type == Global.NavPointTypes.SOLO):
#			var a=0 #Starting point (0 = left side)
#			var b=1 #Ending point (1 = right side)
#			if (navpoint.type == Global.NavPointTypes.LEFT_EDGE): b = 0;
#			if (navpoint.type == Global.NavPointTypes.RIGHT_EDGE): a = 1;
#
#			for i in range(a, b+1):
#				#determine left or right side target
#				var target_tile = navpoint.location
#				if i == 1:
#					target_tile += Vector2(1,0)
#				else:
#					target_tile += -Vector2(1,0)
#
#				if target_tile in obstacles:
#					continue;
#
#				#Check for any available navpoint below the target
#				target_tile += Vector2(0, 1)
#				while not is_outside_map_bounds(target_tile):
#					var target = nav_points[calculate_point_index(target_tile)];
#					if target != null and target.type != Global.NavPointTypes.NONE:
#						navpoint.link(target, 15, Global.NavLinkTypes.FALL);
#						break;
#					target_tile += Vector2(0, 1)
				
	#Connect jump links
	for navpoint in nav_points:
		if navpoint == null or navpoint.type == Global.NavPointTypes.NONE: continue
		
		#print("FOR NAVPOINT AT" + str(navpoint.location));
		#Create a set of jump trajectories
		var trajectories = [];
		for i in range(0, SPEED_DIVISIONS+1):
			for j in range(0, HEIGHT_DIVISIONS+2):
				var point = to_relative(navpoint.location)
				var walk_speed = WALK_MAX_SPEED/(i+1)
				var jump_speed;
				if j == 0: jump_speed = 0
				else:
					jump_speed = -JUMP_MAX_SPEED/(j)
				var velocity = Vector2(walk_speed, jump_speed)
				trajectories.push_back(JumpTrajectory.new(point, velocity, GRAVITY))
				trajectories.push_back(JumpTrajectory.new(point, Vector2(-velocity.x, velocity.y), GRAVITY))
				
		for trajectory in trajectories:
			var last_point = trajectory.points[0];
			var platforms_reached = []; #This may limit the amount of paths
			#print(trajectory.points);
			for i in range(trajectory.points.size()):
				var point = trajectory.points[i];
				var closest_navpoint = get_closest_navpoint(point);
				if closest_navpoint == null: break;
				
				var close_relative = to_relative(closest_navpoint.location)
				var close_ground = close_relative + Vector2(0, 4);
#
				if (closest_navpoint.type != Global.NavPointTypes.NONE and
					closest_navpoint != navpoint and
					point.y > last_point.y and
					point.y - close_ground.y <= MAX_GROUND_DISTANCE and
					can_stand_at(close_ground) and
					navpoint.platform_index != closest_navpoint.platform_index): #and
					#not (closest_navpoint.platform_index in platforms_reached)): #Unecessary restriction
						
					navpoint.link(closest_navpoint, i*trajectory.delta, Global.NavLinkTypes.JUMP, trajectory.initial_velocity);
					platforms_reached.append(closest_navpoint.platform_index)
					
					#Draw out trajectory path
#					var line = Line2D.new()
#					for point in trajectory.points:
#						line.add_point(point)
#
#					line.z_as_relative = false
#					line.z_index = 4095
#					line.width = 2
#					line.set_default_color(Color.gold)
#
#					add_child(line);
					break;
				elif not can_stand_at(point + Vector2(0,4)):
					break;
				
				last_point = point
		
	for navpoint in nav_points:
		if not (navpoint == null or navpoint.type == Global.NavPointTypes.NONE): 
			for link in navpoint.navLinks:
				var dest = nav_points[link.dest_id];
				var point_position = to_relative(navpoint.location);
				var point_index = navpoint.index
				var dest_relative_position = to_relative(dest.location)
				var dest_point_index = dest.index
				

func get_closest_navpoint(point : Vector2):
	point = to_local(point)
	point = Vector2(int(round(point.x)), int(round(point.y)))
	if is_outside_map_bounds(point): return null;
	var point_index = calculate_point_index(point);
	return nav_points[point_index];
	
#Checks for a close navpoint, and then searches downwards for one
func get_closest_valid_navpoint(point : Vector2):
	point = to_local(point)
	point = Vector2(int(round(point.x)), int(round(point.y)))
	if is_outside_map_bounds(point): return null;
	var point_index = calculate_point_index(point);
	var navpoint = nav_points[point_index];
	if navpoint.type != Global.NavPointTypes.NONE: return navpoint;
	
	#Check all navpoints downwards
	var down_valid = true;
	while down_valid:
		point = point + Vector2(0,1);
		if is_outside_map_bounds(point): down_valid = false;
		else:
			if navpoint.type != Global.NavPointTypes.NONE: return navpoint;
	
	#None found
	return null;
	
#Returns an array of NavLinks as a path
#If no path can be found, returns null
func connect_path(start : int, end: int):
	var start_point = nav_points[start];
	var end_point = nav_points[end];
	var current = start;
	var current_point = start_point;
	
	var point_path = []
	var path = []
	
	var is_visited = [];
	is_visited.resize(nav_points.size());
	var distance = [];
	var through = []
	for i in range(nav_points.size()):
		distance.push_back(99999999)
		through.push_back(start);
		
	is_visited[start] = 0;
	distance[start] = 0;
	
	var can_progress = true;
	while can_progress:
		for link in current_point.navLinks:
			if not (is_visited[link.dest_id]):
				var total = link.link_score + distance[current];
				if total < distance[link.dest_id]:
					distance[link.dest_id] = total;
					through[link.dest_id] = current
		is_visited[current] = true;
		if (current == end):
			can_progress = false;
			break
			#end here;
		var lowest = 99999999;
		var choice_point = null;
		for point in valid_points:
			if not (is_visited[point.index]):
				if distance[point.index] < lowest:
					choice_point = point.index
					lowest = distance[point.index];
		if choice_point == null:
			return null;
		current = choice_point;
		current_point = nav_points[current];
		
	##make path
	current = end
	while (current != start):
		point_path.push_front(current);
		current = through[current];
	point_path.push_front(start);
	
	#connect point path
	for i in range(point_path.size()-1):
		#print(point_path);
		var index = point_path[i]
		var navpoint = nav_points[index]
		for link in navpoint.navLinks:
			if link.dest_id == point_path[i+1]:
				path.append(link)
				break
				
	return path;
		
		

	
func to_relative(point : Vector2):
	return point*8 + Vector2(4, 4);
	
func to_local(point: Vector2):
	return (point - Vector2(4,4))/8.0
	
#Creates a collision box standing at the specified point to see if the miner can stand at the point
func can_stand_at(point : Vector2):
	var check_shape = RectangleShape2D.new();
	check_shape.set_extents(MINER_COLLISION - Vector2(0, 0.01));
	var space_state = get_world_2d().direct_space_state
	var params = Physics2DShapeQueryParameters.new()
	params.set_shape_rid(check_shape.get_rid())
	#print("Transform" + str(Transform2D(0, global_position + point - Vector2(0, MINER_COLLISION.y))))
	params.set_transform(Transform2D(0, global_position + point - Vector2(0, MINER_COLLISION.y)))
	var result = space_state.intersect_shape(params)
	#print(params.get_transform())
	#print(result)
	return result.empty()

func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y


func calculate_point_index(point):
	return point.x + map_size.x * point.y
	
#func calculate_link_index(nav_link: NavLink):
#	var num_ids = (map_size.x-1) + map_size.x*(map_size.y-1) + 1
#	return nav_link.src_id + num_ids*nav_link.dest_id;
