extends Node

const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
const HTerrainTextureSet = preload("res://addons/zylann.hterrain/hterrain_texture_set.gd")
var height_multiplier = 100

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("updateMap") and !Global.is_flying:
		updateMap()

func _on_reset_2_pressed() -> void:
	if !Global.is_flying: 
		updateMap()

func _on_map_height_slider_value_changed(value: float) -> void:
	height_multiplier = value

func updateMap():
	#грузим карту в переменные
	var terrain = $HTerrain
	var terrain_data = terrain.get_data()
	#получаем доступ к текущей загруженной карте высот в карте
	var heightmap: Image = terrain_data.get_image(HTerrainData.CHANNEL_HEIGHT)
	#открываем картинку из файлов проекта
	var image = Image.new()
	var error = image.load("res://images/heightMap.png")
	#простой чек на косяки
	if error != OK:
		return
	#прессуем карту в квадрат если она не подходит под квадрат
	if image.get_size() != heightmap.get_size():
		image.resize(heightmap.get_width(), heightmap.get_height(), Image.INTERPOLATE_LANCZOS)
	#переписываем карту высот попиксельно
	#а потому что годот не хочет по другому картинки свапать или я совсем глупый
	for y in range(heightmap.get_height()):
		for x in range(heightmap.get_width()):
			var orig = image.get_pixel(x, y)
			var h = orig.r * height_multiplier
			heightmap.set_pixel(x, y, Color(h, 0, 0))
	#пингуем объект карты что мы карту переписали, чтобы изменения применились
	var modified_region = Rect2(Vector2(), heightmap.get_size())
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
	terrain.update_collider()
