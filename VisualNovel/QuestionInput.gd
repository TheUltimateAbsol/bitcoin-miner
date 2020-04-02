extends InputBase

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
	update();
	
	
func sentence_display():
	#Clear up previous stuff
	for child in question_list.get_children():
		child.queue_free()

	#Generate new stuff
	for i in range(answers.size()):
		var prompt = answers[i];
		var new_prompt = questionLabel.instance()
		question_list.add_child(new_prompt)
		new_prompt.set_data(prompt.content, prompt.next_id);

		new_prompt.connect("delete", self, "delete_answer", [i]);
		new_prompt.connect("updated", self, "update_answer", [i]);

func delete_answer(index):
	answers.remove(index)
	sentence_display()
	update();
	
func update_answer(index):
#	We cheat here since # children = # answers
	answers[index].next_id = question_list.get_child(index).next_id;
	sentence_display();
	update();
	
func get_data():
	return {"answers":answers};
	
func load_data(page_data):
	answers = page_data.answers;
	sentence_display();


func _on_question_input_text_entered(new_text):
	add_sentence();


