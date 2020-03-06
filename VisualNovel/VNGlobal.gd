extends Node

#enum Characters {NONE, BOY, GIRL}
#enum Transitions{NONE, FLASH, FADE, SLIDE_RIGHT, SLIDE_LEFT} #character
#enum Expressions{DEFAULT, HAPPY, SAD}
#enum Music{SAME, NONE, SIMPLE, SAD}
#enum Backgrounds{SAME, NONE, CLASSROOM}
#enum SoundEffect{NONE, DING, THWACK, WHACK} # when the text appears on the screen (sentence per sentence basis)

const Characters = {"NONE":"NONE", "SIMON":"SIMON", "ANNA":"ANNA"} 
const CharacterNames = {"NONE":"NONE", "SIMON":"Simon", "ANNA":"Anna", "TEACHER":"Teacher", "BELL":"Bell"} 
const Transitions = {"NONE":"NONE", "FLASH":"FLASH", "FADE":"FADE", "SLIDE_RIGHT":"SLIDE_RIGHT", "SLIDE_LEFT":"SLIDE_LEFT"} #character
const Expressions = {"DEFAULT":"DEFAULT", "HAPPY":"HAPPY", "SAD":"SAD"}
const Music = {"SAME":"SAME", "NONE":"NONE", "SIMPLE":"SIMPLE", "SAD":"SAD"}
const Backgrounds = {"SAME":"SAME", "NONE":"NONE", "CLASSROOM":"CLASSROOM"}
const Background_transitiosn = {"NONE":"NONE", "FADE":"FADE", "BLACK":"BLACK"}
# when the text appears on the screen (sentence per sentence basis)
const SoundEffect = {"NONE":"NONE", "DING":"DING", "THWACK":"THWACK", "WHACK":"WHACK"}
#const PageTypes = {"ContentPage":"ContentPage", "GameStartPage":"GameStartPage", "GameEndPage":"GameEndPage",  "EndPage":"EndPage"}

const CLASS_DIRECTORY = "res://VisualNovel/PageClasses/"

signal user_input

const DEFAULT_SENTENCE_DELAY = 0.5;

func _ready():
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
		