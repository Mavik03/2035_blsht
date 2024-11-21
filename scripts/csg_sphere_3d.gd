extends CSGSphere3D

func _ready() -> void:
	#добавляем безтеневой светящийся материал как у цилиндров в пути
	var glowing_material = StandardMaterial3D.new()
	glowing_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glowing_material.emission_enabled = true
	glowing_material.emission = Color(0.0, 0.0, 1.0) 
	glowing_material.emission_energy = 4 
	self.material = glowing_material
	self.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
