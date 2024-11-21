extends Control

@onready var xpos = $xpos
@onready var ypos = $ypos
@onready var zpos = $zpos
@onready var xrot = $xrot
@onready var yrot = $yrot
@onready var zrot = $zrot


func _process(delta: float) -> void:
	xpos.text = "X: " + str(Global.pos_rot_data[0]).pad_decimals(2)
	ypos.text = "Y: " + str(Global.pos_rot_data[1]).pad_decimals(2)
	zpos.text = "Z: " + str(Global.pos_rot_data[2]).pad_decimals(2)
	xrot.text = "X: " + str(Global.pos_rot_data[3]).pad_decimals(2)
	yrot.text = "Y: " + str(Global.pos_rot_data[4]).pad_decimals(2)
	zrot.text = "Z: " + str(Global.pos_rot_data[5]).pad_decimals(2)
