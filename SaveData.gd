extends Node

var relationships = {}
var flags = {}

func _ready():
	for character in VNGlobal.Characters.values():
		relationships[character] = 0
		
func get_flag_value(key):
	if flags.has(key):
		flags[key] = false;
	return flags[key];

func set_flag(key, value):
	flags[key] = value;

func get_relationship_points(character):
	return relationships[character];

func increment_relationship(character, value=1):
	relationships[character] = relationships[character] + value;
	
func decrement_relationship(character, value=1):
	relationships[character] = relationships[character] - value;
