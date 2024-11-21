extends Button

func _process(delta: float) -> void:
	if(!Global.is_flying):
		self.text = "Start"

func _on_pressed() -> void:
	if(!Global.is_flying and !Global.bad_path):
		Global.is_flying = true
		self.text = "Stop"
	else: if Global.is_flying:
		Global.is_flying = false
		self.text = "Start"
