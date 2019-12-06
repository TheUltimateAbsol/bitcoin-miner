extends PanelContainer

var sentences = [];

onready var SentenceLabel = preload("Sentence_Label.tscn");
onready var sentence_list = $VBoxContainer/sentence_list

func _ready():
	#populate options
	var soundeffect_keys = VNGlobal.SoundEffect.keys()
	var x = 1
	for key in soundeffect_keys:
		sound_menu.add_item(key, x)
		x += 1

# Sentence data
onready var sentence_txt_input = $VBoxContainer/sentence_txt/sentence_input
onready var sentence_delay_input = $VBoxContainer/sentence_info2/sent_delay_input
onready var sentence_speed_input = $VBoxContainer/sentence_info2/sent_speed_input
onready var add_sentence_btn = $VBoxContainer/sentence_txt/add_sentence
onready var sound_menu = $VBoxContainer/sentence_info2/sound_menu

func add_sentence():
	var sentence_text = sentence_txt_input.get_text()
	var delay = sentence_delay_input.get_text()
	var speed = sentence_speed_input.get_text()
	
	if delay != null and delay.is_valid_float():
		delay = int(delay)
	else:
		delay = Global.DEFAULT_SENTENCE_DELAY
	
	if speed != null and speed.is_valid_float():
		speed = int(speed)
	else:
		speed = 1.0
	
	var sound = sound_menu.get_item_text(sound_menu.get_selected_id())
	sentences.push_back(Sentence.new(sentence_text, delay, sound, speed).serialize())
	
	sentence_display()
	
	
func sentence_display():
	#Clear up previous stuff
	for child in sentence_list.get_children():
		child.queue_free()

	#Generate new stuff
	for i in range(sentences.size()):
		var sentence = sentences[i];
		var new_sentence = SentenceLabel.instance()
		new_sentence.set_text(sentence.content);
		sentence_list.add_child(new_sentence)
		
		new_sentence.connect("delete", self, "delete_sentence", [i]);

func delete_sentence(index):
	sentences.remove(index)
	sentence_display()
	
func get_data():
	return {"content":sentences};
	
func load_data(sentences_input : Array):
	sentences = sentences_input;
	sentence_display();
