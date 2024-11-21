extends Label

func _ready() -> void:
	self.text = "1"

func _on_offset_slider_value_changed(value: float) -> void:
	self.text = str(value)
