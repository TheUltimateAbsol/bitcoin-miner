extends Node

class_name JumpTrajectory

var initial_velocity : Vector2
var points = [] #SHOULD BE NUM_INTERVALS+1 LONG

#For the sake of efficiency, these really should be globals :(
var NUM_INTERVALS = 11 #NOT NUM_POINTS -- DOES NOT ACCOUNT FOR START
var TRAJECTORY_LENGTH = 1.1; #SECONDS
var delta: float;


func _init(start_point, velocity, gravity):
	
	delta = TRAJECTORY_LENGTH/NUM_INTERVALS
	initial_velocity = velocity;
	points.push_back(start_point);
	
	var cur_pos = start_point
	var cur_vel = velocity
	for i in range(1, NUM_INTERVALS+1):
		cur_pos += cur_vel*delta;
		cur_vel += Vector2(0,gravity)*delta
		points.push_back(cur_pos)
	

