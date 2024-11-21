class_name FreeLookCamera extends Camera3D

# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

@export_range(0.0, 1.0) var sensitivity = 0.25

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false

#определение дистанций, для снапа без поверхности и для макс длины поиска поверхности
const DEFAULT_DISTANCE := 25.0
const MAX_RAYCAST_DISTANCE := 1000
#включает возможность в инспекторе кидать любой нод в качестве курсора
@export var target_node: Node3D
#пара переменных для снапа и прорисовки пути
var line_instances = []
var path_hidden : bool = false
var z_offset : float = 1.0

func _on_offset_slider_value_changed(value: float) -> void:
	z_offset = value
	
func _on_hide_path_pressed() -> void:
	if path_hidden:
		path_hidden = false
	else:
		path_hidden = true

func snap_to_cursor():
	# Получаем глобальные координаты курсора
	var from = project_ray_origin(get_viewport().get_mouse_position())
	var to = from + project_ray_normal(get_viewport().get_mouse_position()) * MAX_RAYCAST_DISTANCE
	var to_min = from + project_ray_normal(get_viewport().get_mouse_position()) * DEFAULT_DISTANCE

	# Отправляем raycast для поиска поверхности
	var space_state = get_world_3d().direct_space_state
	#формируем query потому что годот 4 не хочет считать intersect_ray по простым векторам
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	#вызываем функцию для нахождения пересечения
	var result = space_state.intersect_ray(query)
	var new_position: Vector3
	#если чет нашли то добавляем сдвиг к результату и готово, если нет то просто ставим 25 метров от нас
	if result.size() > 0:
		new_position = result.position
		new_position.y = new_position.y + z_offset
		target_node.global_transform.origin = new_position
	else:
		new_position = to_min
		target_node.global_transform.origin = to_min
		
	Global.positions_history.append(new_position)
		
	update_lines_and_points()

func update_lines_and_points():
	var space_state = get_world_3d().direct_space_state
	#чистим весь сущуствующий путь
	for instance in line_instances:
		instance.queue_free()
	line_instances.clear()
	#для отметки пути используются вытянутые цилиндры со специальным материалом
	if !path_hidden:
		#перебираем все координаты точек если путь не скрыт
		Global.bad_path = false
		for i in range(1, Global.positions_history.size()):
			
			#берем две точки из маршрута в переменные, создаем протитип цилиндра
			var start_pos = Global.positions_history[i - 1]
			var end_pos = Global.positions_history[i]
			var cylinder = MeshInstance3D.new()
			var cylinder_mesh = CylinderMesh.new()
			
			#проверяем маршрут на правильность
			var distance = (end_pos - start_pos).length()
			var query = PhysicsRayQueryParameters3D.new()
			query.from = start_pos
			query.to = end_pos
			var check_ray = space_state.intersect_ray(query)
			var check_distance = distance
			if check_ray.size() > 0:
				check_distance = (end_pos - check_ray.position).length()
			if distance - check_distance > 0.1:
				Global.bad_path = true
			
			cylinder_mesh.top_radius = 0.1  # Радиус цилиндра (толщина линии)
			cylinder_mesh.bottom_radius = 0.1
			cylinder_mesh.height = (end_pos - start_pos).length()  # Высота цилиндра по расстоянию между точками
			cylinder.mesh = cylinder_mesh
			
			#вырубаем тени
			cylinder.cast_shadow = MeshInstance3D.SHADOW_CASTING_SETTING_OFF
			
			# Создаём светящийся материал
			var glowing_material = StandardMaterial3D.new()
			glowing_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			glowing_material.emission_enabled = true
			glowing_material.emission = Color(0.0, 0.0, 1.0) 
			glowing_material.emission_energy = 4 
			#применяем материал к цилиндру
			cylinder_mesh.material = glowing_material
			#кидаем цилиндр в корень сцены и прибавляем в массив циллиндров 
			get_tree().root.add_child(cylinder)
			line_instances.append(cylinder)

			# Устанавливаем позицию и ориентацию цилиндра
			cylinder.global_transform.origin = (start_pos + end_pos) / 2  # Центр цилиндра между точками
			var direction = (end_pos - start_pos).normalized()
			#поворачиваем цилиндр 
			cylinder.look_at(end_pos, Vector3.UP)
			cylinder.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(90))

func _input(event):
	#тут в основном управление свободной камерой валяется
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	#тут проверяем на клик для добавления точки, вызываем добавление если видим клик
	if Input.is_action_just_pressed("snap position") and !Global.is_flying:
		snap_to_cursor()
	
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			MOUSE_BUTTON_WHEEL_UP: # Increases max velocity
				_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, 20)
			MOUSE_BUTTON_WHEEL_DOWN: # Decereases max velocity
				_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, 20)

	# Receives key input
	if event is InputEventKey:
		match event.keycode:
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
			KEY_Q:
				_q = event.pressed
			KEY_E:
				_e = event.pressed

# Updates mouselook and movement every frame(из аддона для камеры)
func _process(delta):
	#просто вызываем все что должно каждый кадр обновляться
	_update_mouselook()
	_update_movement(delta)
	update_lines_and_points()
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

# Updates camera movement(функция с аддона для камеры)
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3((_d as float) - (_a as float), 
						(_e as float) - (_q as float), 
						(_s as float) - (_w as float))
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 4
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER
	
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
	
		translate(_velocity * delta * speed_multi)

# Updates mouse look (тоже с аддона камеры)
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
	
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))
