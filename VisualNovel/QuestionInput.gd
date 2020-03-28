extends PanelContainer

var answers = [];
#var content = []

var next_id = 0

onready var questionLabel = preload("question_Label.tscn");
onready var question_list = $VBoxContainer/question_list

func _ready():
	pass

# Sentence data
onready var question_txt_input = $VBoxContainer/question_txt/question_input
onready var next_id_input = $VBoxContainer/question_txt/next_id_input
onready var add_question_btn = $VBoxContainer/question_txt/add_question

func add_sentence():
	var question_text = question_txt_input.get_text()
	var next_id_text = next_id_input.value
	
	answers.push_back(Answer.new(question_text, next_id_text).serialize())
	
	sentence_display()
	
	
func sentence_display():
	#Clear up previous stuff
	for child in question_list.get_children():
		child.queue_free()

	#Generate new stuff
	for i in range(answers.size()):
		var prompt = answers[i];
		var new_prompt = questionLabel.instance()
		new_prompt.set_text(prompt.content);
		new_prompt.set_id(prompt.next_id)
		question_list.add_child(new_prompt)
		
		new_prompt.connect("delete", self, "delete_sentence", [i]);

func delete_sentence(index):
	answers.remove(index)
	sentence_display()
	
func get_data():
	return {"answers":answers};
	
func load_data(sentences_input : Array, answers : Array):
	answers = sentences_input;
	sentence_display();
