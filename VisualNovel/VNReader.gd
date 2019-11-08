extends Control

onready var textlabel = get_node("Control/Panel/MarginContainer/Control/TextLabel")
onready var letter_timer = $LetterTimer;
onready var delay_timer = $DelayTimer;
onready var npc = $Control/NPC
onready var transition = get_node("Control/NPC/AnimationPlayer")

var expressions = {
	Global.Characters.BOY : {
		Global.Expressions.DEFAULT :  load("res://VisualNovel/Characters/BoyeNeutral.png"),
		Global.Expressions.HAPPY : load("res://VisualNovel/Characters/BoyeSmile.png"),
		Global.Expressions.SAD : load("res://VisualNovel/Characters/BoyeFrown.png")
	},
	Global.Characters.GIRL : {
		Global.Expressions.DEFAULT :  load("res://VisualNovel/Characters/verylegit.png")
	}
}

var backgrounds = {
	Global.Backgrounds.CLASSROOM : load("res://VisualNovel/Backgrounds/classroom_angle.png")
}
	

var CHAR_WAIT = 1.0/20
var data_json

func _ready():
	load_data("res://VisualNovel/data.json")
	var id = 1 #what number page is this
	var next_id =2 	#id of the next page in the series
#	var string1 = Sentence.new("This is a really boring game. \n", .5);
#	var string2 = Sentence.new("Don't play it");
#	var string3 = Sentence.new("Wait...", 0.5)
#	var string4 = Sentence.new(" aren't I in this game?");
#	var string5 = Sentence.new("Yes you are you dummy", 0.2);
#	var string6 = Sentence.new("Oh great!", 0.2);
#	var string7 = Sentence.new("This might be really good!", 0.5);
#	var string8 = Sentence.new("Ahahaha");
#	var content1 = [string1, string2];
#	var content2 = [string3, string4];
#	var content3 = [string5];
#	var content4 = [string6, string7];
#	var content5 = [string8];
	var content1 = [];
	for string in data_json.result["01"]["content"]:
		content1.append(Sentence.new(string["string"], string["delay"]))
		
	var content2 = [];
	for string in data_json.result["02"]["content"]:
		content2.append(Sentence.new(string["string"], string["delay"]))
		
	var content3 = [];
	for string in data_json.result["03"]["content"]:
		content3.append(Sentence.new(string["string"], string["delay"]))
		
	var content4 = [];
	for string in data_json.result["04"]["content"]:
		content4.append(Sentence.new(string["string"], string["delay"]))
		
	var content5 = [];
	for string in data_json.result["05"]["content"]:
		content5.append(Sentence.new(string["string"], string["delay"]))
	
	var page1 = ContentPage.new(id, next_id, content1, Global.Characters.BOY, Global.Expressions.SAD, Global.Transitions.FADE, Global.Backgrounds.CLASSROOM);
	var page2 = ContentPage.new(id+1, next_id+1, content2, Global.Characters.BOY);
	var page3 = ContentPage.new(id+2, next_id+2, content3, Global.Characters.GIRL, Global.Expressions.DEFAULT, Global.Transitions.FADE);
	var page4 = ContentPage.new(id+3, next_id+3, content4, Global.Characters.BOY, Global.Expressions.HAPPY, Global.Transitions.FADE);
	var page5 = ContentPage.new(id+4, next_id+4, content5, Global.Characters.BOY, Global.Expressions.HAPPY);
#	page._init2(id, next_id, content);
	
	yield(display_page(page1), "completed");
	yield(display_page(page2), "completed");
	yield(display_page(page3), "completed");
	yield(display_page(page4), "completed");
	yield(display_page(page5), "completed");
 

func play_page(input:Dictionary): # parsed form JSON
	#take data from JSON
	#make content page
	var page = ContentPage.new(input["id"],input["next_id"], input["content"]["string"], input["character"], input["expression"], input["transition"], input["background"], input["music"])
	#display page through VNEditor
	print(page.character)
	yield(display_page(page), "completed")

func display_page(page : Page):
	#textlabel.text = ""
	print(expressions)
	print(expressions[page.character])
	print(expressions[page.character][page.expression])
	print(self.get_path())
#	print("CHARACTER: " + str(page.character));
	#print("RESULT" + str(expressions[page.character][page.expression]));
	npc.texture = expressions[page.character][page.expression]
	
	match page.transition:
		Global.Transitions.NONE:
			pass
		Global.Transitions.FLASH: #think ace attorny
			pass
		Global.Transitions.FADE:
			$Control/NPC.modulate = Color(0,0,0,0); #Prevents flashing of sprite
			#transition.add_animation("fade in", transition.get_animation("fade in")) #wHAT IS THIS LINE?
			transition.play("fade in")	
			yield(transition, "animation_finished")
#			yield(transition, "animation_finished")
		Global.Transitions.SLIDE_RIGHT:
			#transition.add_animation("slide_from_right", transition.get_animation("slide_from_right"))
			transition.play("slide_from_right")
			yield(transition, "animation_finished")
#			pass
		Global.Transitions.SLIDE_LEFT:
			pass
	
	if page.background != Global.Backgrounds.SAME:
		$Control/Background.texture = backgrounds[Global.Backgrounds.CLASSROOM];
		
	
	for sentence in page.content:
		yield(write_sentence(sentence), "completed"); #tells program to wait on everything until this function finishes/this happens
		
func write_sentence (sentence):
	for c in sentence.content:
		textlabel.text += str(c)
		letter_timer.wait_time = CHAR_WAIT*sentence.speed;
		letter_timer.start();
		yield(letter_timer, "timeout");
		
	delay_timer.wait_time = sentence.delay*sentence.speed;
	delay_timer.start();
	yield(delay_timer, "timeout");

func load_data(file_path):
	#retrieves the json file
	var file = File.new()
	file.open(file_path, 3)
	#converts the json file to a text file
	var text_json = file.get_as_text()
#	print(text_json)
	#parses tect file to dictionary
	data_json = JSON.parse(text_json)
	#checks to make sure it parsed correctly
	if data_json.error == OK:
		print("All is good")
	else:
		print("something is wrong")
		print(typeof(data_json.result))
		print(data_json.get_error_line())
	print("checkpoint 1")
	print(typeof(data_json.result))
	print(data_json)
	file.close()
