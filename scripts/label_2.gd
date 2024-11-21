extends Label

func _ready() -> void:
	self.text = "100"

func _on_map_height_slider_value_changed(value: float) -> void:
	self.text = str(value)
