extends Node2D

onready var textlabel = get_node("Control/Panel/TextLabel");
onready var letter_timer = $LetterTimer;

var CHAR_WAIT = 1.0/10

func _ready():
	var page : ContentPage
	var id = 1
	var next_id =2
	var string1 = Sentence.new("AAAAAAAAAAAAAAAA. \n");
	var string2 = Sentence.new("BBBBBBBBBBBBBBBBBB");
	var content = [string1, string2];
	
	page = ContentPage.new();
	page._init2(id, next_id, content);
	
	display_page(page);
	
func display_page(page : Page):
	textlabel.text = ""
	for sentence in page.content:
		yield(write_sentence(sentence), "completed");
		
func write_sentence (sentence):
	for c in sentence.content:
		textlabel.text += str(c)
		letter_timer.wait_time = CHAR_WAIT*sentence.speed;
		letter_timer.start();
		yield(letter_timer, "timeout");
	
	
