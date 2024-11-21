extends Label

func _process(delta: float) -> void:
	if Global.bad_path == false:
		self.text = "Ok path"
		self.set("theme_override_colors/font_color", Color(1,1,1))
	else:
		self.text = "Bad path"
		self.set("theme_override_colors/font_color", Color(1,0.1,0.1))
