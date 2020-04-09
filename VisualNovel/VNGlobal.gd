extends Node

#enum Characters {NONE, BOY, GIRL}
#enum Transitions{NONE, FLASH, FADE, SLIDE_RIGHT, SLIDE_LEFT} #character
#enum Expressions{DEFAULT, HAPPY, SAD}
#enum Music{SAME, NONE, SIMPLE, SAD}
#enum Backgrounds{SAME, NONE, CLASSROOM}
#enum SoundEffect{NONE, DING, THWACK, WHACK} # when the text appears on the screen (sentence per sentence basis)

const Characters = {"NONE":"NONE", "ANNA":"ANNA", "CLAIRE":"CLAIRE", "JACK":"JACK", "CHAD":"CHAD", "JUNE":"JUNE", "SHAUN":"SHAUN", "ELIZABETH":"ELIZABETH"} 
const CharacterTransitions = {"DEFAULT":"DEFAULT"} #character
const Music = {"SAME":"SAME", "NONE":"NONE", "DEFAULT":"DEFAULT", "SUSPENSE":"SUSPENSE", "DESPAIR":"DESPAIR", "ENGAGING":"ENGAGING", "BOISTEROUS":"BOISTEROUS"}
const Expressions = {"NORMAL":"NORMAL", "ANGRY":"ANGRY", "EMBARASSED":"EMBARASSED", "SAD":"SAD", "HAPPY":"HAPPY", "SHOCKED":"SHOCKED"}
const Backgrounds = {"SAME":"SAME", "NONE":"NONE", "CLASSROOMA":"CLASSROOMA", "CLASSROOMB":"CLASSROOMB", "HALLWAY":"HALLWAY", "GYMlOCKER":"GYMLOCKER", "BUS":"BUS", "BEACH":"BEACH", "CAFETERIA":"CAFETERIA", "BEDROOM":"BEDROOM"}
const SceneTransitions = {"NONE":"NONE", "SCENESWITCH":"SCENESWITCH", "ENTRANCE":"ENTRANCE"}
# when the text appears on the screen (sentence per sentence basis)
const Effects = {"NONE":"NONE"}
const SentenceSpeeds = {"DEFAULT": "DEFAULT", "FAST":"FAST", "SLOW":"SLOW"}
const DelayLengths = {"DEFAULT": "DEFAULT", "NONE":"NONE", "SHORT":"SHORT", "LONG":"LONG"}
const Images = {"LETTER":"LETTER"}

const CLASS_DIRECTORY = "res://VisualNovel/PageClasses/"

signal user_input

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	InputEventHandler.connect("released_attack", self, "fire_user_input");
	
func fire_user_input():
	emit_signal("user_input");

static func merge_dir(target, patch):
	for key in patch:
		if target.has(key):
			var tv = target[key]
			if typeof(tv) == TYPE_DICTIONARY:
				merge_dir(tv, patch[key])
			else:
				target[key] = patch[key]
		else:
			target[key] = patch[key]
	return target;
	
	
static func deserialize(json_object):
	return load(CLASS_DIRECTORY + json_object["type"] + ".gd").new(json_object);
		
