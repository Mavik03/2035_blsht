extends Control

@onready var avg = $valueAvg
@onready var max = $valueMax

func _on_avg_speed_value_changed(value: float) -> void:
	Global.base_speed = value
	avg.text = str(value)

func _on_max_speed_value_changed(value: float) -> void:
	Global.max_speed = value
	max.text = str(value)
