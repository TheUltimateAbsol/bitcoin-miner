extends Control

onready var health_bar = $HealthBar

func update_health(health):
	health_bar.value = health

func update_max_health(max_health):
	health_bar.max_value =  max_health