extends Node2D

onready var textlabel = get_node("Control/Panel/TextLabel")
onready var letter_timer = $LetterTimer;
onready var transition = get_node("Control/NPC/AnimationPlayer")

var CHAR_WAIT = 1.0/10

func _ready():
	var page : ContentPage
	var id = 1 #what number page is this
	var next_id =2 	#id of the next page in the series
	var string1 = Sentence.new("AAAAAAAAAAAAAAAA. \n");
	var string2 = Sentence.new("BBBBBBBBBBBBBBBBBB");
	var content = [string1, string2];

	page = ContentPage.new();
	page._init2(id, next_id, content);
	
	display_page(page);

func display_page(page : Page):
	textlabel.text = ""
	match 2:
		Global.Transitions.NONE:
			pass
		Global.Transitions.FLASH: #think ace attorny
			pass
		Global.Transitions.FADE:
			transition.add_animation("fade in", transition.get_animation("fade in"))
			transition.play("fade in")	
#			yield(transition, "animation_finished")
		Global.Transitions.SLIDE_RIGHT:
			pass
		Global.Transitions.SLIDE_LEFT:
			pass
		
#	transition.play("fade in")	
	yield(transition, "animation_finished")
	
	for sentence in page.content:
		yield(write_sentence(sentence), "completed"); #tells program to wait on everything until this function finishes/this happens
		
func write_sentence (sentence):
	for c in sentence.content:
		textlabel.text += str(c)
		letter_timer.wait_time = CHAR_WAIT*sentence.speed;
		letter_timer.start();
		yield(letter_timer, "timeout");



