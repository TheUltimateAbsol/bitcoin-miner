extends TextureProgress


onready var health_bar = $HealthBar
# Declare member variables here. Examples:


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_health_updated(health, amount):
	health_bar.value = health
	
func _on_max_health_updated(max_health):
	health_bar.max_value = max_health