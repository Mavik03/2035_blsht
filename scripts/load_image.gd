extends Control

@onready var file_dialog = $FileDialog

func _on_load_image_pressed() -> void:
	file_dialog.popup()

func _on_file_dialog_file_selected(path: String) -> void:
	#открываем встроенную функцию диалога файловой системы
	#вытягиваем из нее выбранную картинку по пути и кидаем в нужное место
	var heightMap = Image.new()
	heightMap.load(path)
	var texture = ImageTexture.new()
	texture.create_from_image(heightMap)
	var savePath = "res://images/heightMap.png"
	heightMap.save_png(savePath)
