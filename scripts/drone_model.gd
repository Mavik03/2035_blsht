extends MeshInstance3D

#переменные для скорости дрона
@onready var base_speed = Global.base_speed
@onready var max_speed = Global.max_speed
@export var slow_down_distance: float = 50
#инициализируем глобальный массив позиций пути
@onready var positions_history := Global.positions_history
#счетчик текущей точки-таргета
var current_target_index: int = 0



func _on_reset_pressed() -> void:
	#обработка set
	#сбрасываем полет и позицию дрона к певой точке пути
	Global.is_flying = false
	current_target_index = 0
	if(Global.positions_history.size() > 0):
		global_transform.origin = Global.positions_history[0]
		global_rotation = Vector3(0,0,0)
	else:
		global_transform.origin = Vector3(0, 25, 0)
		global_rotation = Vector3(0,0,0)

#интерполяция дрона между точками
func _process(delta: float) -> void:
	Global.pos_rot_data[0] = self.global_transform.origin.x
	Global.pos_rot_data[1] = self.global_transform.origin.z
	Global.pos_rot_data[2] = self.global_transform.origin.y
	Global.pos_rot_data[3] = self.rotation_degrees.x
	Global.pos_rot_data[4] = self.rotation_degrees.z
	Global.pos_rot_data[5] = self.rotation_degrees.y
	if(Global.is_flying):
		if current_target_index >= positions_history.size():
			return
		#вычисляем переменные для нахождения скорости и направления дальше
		var target_pos: Vector3 = positions_history[current_target_index]
		var direction: Vector3 = (target_pos - global_transform.origin).normalized()
		var distance_to_target = global_transform.origin.distance_to(target_pos)
		#большая диста от отправки чтобы не была меньше дисты замедления до второй точки
		var distance_from_depart = 100000
		var prev_target_pos: Vector3 = target_pos
		if current_target_index > 2:
			prev_target_pos = positions_history[current_target_index-1]
			distance_from_depart = global_transform.origin.distance_to(prev_target_pos)
		
		#считаем скорость, замедляемся если близко к какой либо точке
		var speed = max_speed
		if distance_to_target < slow_down_distance:
			speed = base_speed * (distance_to_target * 5 / slow_down_distance)
			speed = clamp(speed, base_speed, max_speed)
			
		if distance_from_depart < slow_down_distance:
			speed = base_speed * (distance_from_depart * 5 / slow_down_distance)
			speed = clamp(speed, base_speed, max_speed)
		# Двигаем модельку к цели
		global_transform.origin += direction * speed * delta
		look_at(target_pos, Vector3.UP)

		# Проверяем, если мы достигли цели
		if global_transform.origin.distance_to(target_pos) < 0.7:
			# Переходим к следующей точке
			current_target_index += 1
		#обрабатываем конец пути
		if current_target_index == positions_history.size():
			Global.is_flying = false
			current_target_index = 0
			
