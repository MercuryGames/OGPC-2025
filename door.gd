extends StaticBody3D

@onready var player = get_tree().get_root().get_node("/root/TestRoom/Player")
@onready var id = [0, 0, 0, 0, "unusable", false, false]
func _ready() -> void:
	self.set_collision_layer_value(1, true)
	self.set_collision_layer_value(2, true)
	self.set_collision_mask_value(1, true)
	self.set_collision_mask_value(2, true)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.id[0] == 200:
		player.object_held.grab(self)
		player.holding_object = false
		player.object_held = null
		body.is_grabbed = false
		body.queue_free()
		self.queue_free()
	
