extends StaticBody3D

@onready var id = [0, 0, 0, 0, "unusable", false, false]

func ready():
	self.set_collision_layer_value(1, true)
	self.set_collision_layer_value(2, true)
	self.set_collision_mask_value(1, true)
	self.set_collision_mask_value(2, true)
