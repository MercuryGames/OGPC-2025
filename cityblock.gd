extends Node3D
@onready var player = get_tree().get_root().get_node("/root/TestRoom/Player")
@export var blockid: int

func initialize(x,y,z,Player1):
	var cords = Vector3(x,y,z)
	set_global_position(cords)
	player = Player1
