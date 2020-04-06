extends Control

onready var background = $TextureRect
onready var arrow_node = $arrow
onready var sceneLabel = $arrow/scene_arrow/Label
onready var sceneLabelTxt = $arrow/scene_arrow/Label
onready var animation = $arrow/scene_arrow/AnimationPlayer

#onready var classroom = $VisualNovel/Backgrounds/classroom_angle
#onready var outside = $VisualNovel/Backgrounds/outside_school

var classroom_image = load("res://VisualNovel/Backgrounds/classroom_front.png")
var outside_image = load("res://VisualNovel/Backgrounds/outside_school.png")

#var classroom = ImageTexture.new().create_from_image(classroom_image)
#var outside = ImageTexture.new().create_from_image(outside_image)
#onready var delay_timer = $Timer;

func _ready():
	arrow_node.hide()

	
	
	background.texture = classroom_image
	
#	sceneLabel.show()
	
	$Tween.interpolate_property($"effect", "cutoff", 0.0, 1.0, 2.0, Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	
	sceneLabelTxt.text = "classroom"
	background.texture = outside_image
	
	arrow_node.show()
#	delay_timer.connect("timeout", self, "queue_free")
#	delay_timer.set_wait_time(5000)
#	delay_timer.start()
	
	animation.play("old label");
	
	yield(animation, "animation_finished")
	
	sceneLabelTxt.text = "outside"

	
	animation.play("new label")
	
	yield(animation, "animation_finished")
	

	$Tween.interpolate_property($"effect", "cutoff", 1.0, 0.0, 2.0, Tween.TRANS_QUINT, Tween.EASE_OUT_IN)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	
	animation.play("fade_away")
	
	yield(animation, "animation_finished")