extends InputBase

var sentences = [];

onready var SentenceLabel = preload("Sentence_Label.tscn");
onready var sentence_list = $VBoxContainer/sentence_list

func _ready():
	for i in range (VNGlobal.DelayLengths.keys().size()):
		sentence_delay_input.add_item(VNGlobal.DelayLengths.keys()[i], i);
	for i in range (VNGlobal.SentenceSpeeds.keys().size()):
		sentence_speed_input.add_item(VNGlobal.SentenceSpeeds.keys()[i], i);
	for i in range (VNGlobal.Effects.keys().size()):
		sound_menu.add_item(VNGlobal.Effects.keys()[i], i);

# Sentence data
onready var sentence_txt_input = $VBoxContainer/sentence_txt/sentence_input
onready var sentence_delay_input = $VBoxContainer/sentence_info2/sent_delay_input
onready var sentence_speed_input = $VBoxContainer/sentence_info2/sent_speed_input
onready var add_sentence_btn = $VBoxContainer/sentence_txt/add_sentence
onready var sound_menu = $VBoxContainer/sentence_info2/sound_menu

func add_sentence():
	var sentence_text = sentence_txt_input.get_text()
	
	var speed = sentence_speed_input.get_item_text(sentence_speed_input.get_selected_id())
	var delay = sentence_delay_input.get_item_text(sentence_delay_input.get_selected_id())
	var sound = sound_menu.get_item_text(sound_menu.get_selected_id())
	
	sentences.push_back(Sentence.new(sentence_text, speed, delay, sound).serialize())
	
	sentence_display()
	update();
	
	
func sentence_display():
	#Clear up previous stuff
	for child in sentence_list.get_children():
		child.queue_free()

	#Generate new stuff
	for i in range(sentences.size()):
		var sentence = sentences[i];
		var new_sentence = SentenceLabel.instance()
		sentence_list.add_child(new_sentence)
		new_sentence.set_data(sentence);
		
		new_sentence.connect("delete", self, "delete_sentence", [i]);
		new_sentence.connect("updated", self, "update_sentence", [i]);

func delete_sentence(index):
	sentences.remove(index)
	sentence_display()
	update();
	
func update_sentence(index):
#	We cheat here since # children = # sentences
	sentences[index] = sentence_list.get_child(index).data;
	sentence_display();
	update();
	
func get_data():
	return {"content":sentences};
	
func load_data(page_data):
	sentences = page_data.content;
	sentence_display();


func _on_sentence_input_text_entered(new_text):
	add_sentence()

