extends Control

@onready var container = self

var interval_ms = 500 
var time_passed = 0

func _ready() -> void:
	pass

func _process(delta):
	time_passed += delta * 1000
	if time_passed >= interval_ms and !Global.is_flying:
		time_passed = 0  
		update_positions_display() 
	
func update_positions_display():
	# Очистка контейнера перед обновлением
	for child in container.get_children():
		child.queue_free()
		
	var pos_number = 1
	# Проход по списку координат и создание Label и Button для каждой позиции
	for i in range(Global.positions_history.size()):
		var position = Global.positions_history[i]
		
		# Создаем HBoxContainer для строки с лейблом и кнопкой
		var hbox = HBoxContainer.new()
		
		# Создаем Label для отображения координаты
		var label = Label.new()
		label.text = str(pos_number) + ": " + str(position)
		hbox.add_child(label)
		pos_number += 1
		# Создаем кнопку удаления
		var delete_button = Button.new()
		delete_button.text = "X"
		
		# Присоединяем функцию для удаления позиции
		delete_button.pressed.connect(self._on_delete_button_pressed.bind(i))
		hbox.add_child(delete_button)
		
		# Добавляем HBoxContainer в главный контейнер
		container.add_child(hbox)

func _on_delete_button_pressed(index):
	# Удаляем позицию из глобального списка
	if index >= 0 and index < Global.positions_history.size() and !Global.is_flying:
		Global.positions_history.remove_at(index)
		# Обновляем отображение после удаления позиции
#		update_positions_display()
