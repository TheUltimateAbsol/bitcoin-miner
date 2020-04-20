extends Control

onready var flower_particles = $CPUParticles2D;
onready var animations = $AnimationPlayer
onready var angry_vein = $angry_vein
onready var sweat_drop = $Path2D/PathFollow2D
onready var sweat_drop_sprite = $Path2D/PathFollow2D/sweat_drop
onready var music_note = $Path2D2/PathFollow2D

var sweat_drop_start = 0
var sweat_drop_end = 1

var music_note_start = 1;


# Called when the node enters the scene tree for the first time.
func _ready():
	flower_particles.set_emitting(false)
	angry_vein.visible = false
	sweat_drop.visible = false
	music_note.visible = false
#	flower_particles.set_one_shot(true)



func _on_happy_pressed():
	angry_vein.visible = false
	sweat_drop.visible = false
	music_note.visible = false
	flower_particles.set_emitting(true)
	flower_particles.set_one_shot(true)
	flower_particles.restart()



func _on_angry_pressed():
	flower_particles.set_emitting(false)
	sweat_drop.visible = false
	angry_vein.visible = true
	music_note.visible = false
	animations.play("angry2")
	yield(animations, "animation_finished")

func _on_sweat_pressed():
#	sweat_drop_location = 0
	sweat_drop.visible = true
	music_note.visible = false
	sweat_drop.set_unit_offset(sweat_drop_start)
	flower_particles.set_emitting(false)
	angry_vein.visible = false
	animations.play("sweat")
	yield(animations, "animation_finished")
#	sweat_drop.set_unit_offset(sweat_drop_end)
#	sweat_drop.set_unit_offset(sweat_drop_location)
#	sweat_drop_location += drop_speed

func _on_music_note_pressed():
	sweat_drop.visible = false
	flower_particles.set_emitting(false)
	angry_vein.visible = false
	music_note.visible = true
	music_note.set_unit_offset(music_note_start)
	animations.play("music_note")
	yield(animations, "animation_finished")	
