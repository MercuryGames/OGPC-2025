extends RigidBody3D

var id = [100,1]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("ui_interact"):
		print(10901010)
		
func initialize(x,y,z):
	var cords = Vector3(x,y,z)
	set_global_position(cords)

func yoink(event):
	queue_free()
	print(19191)
	
