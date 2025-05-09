extends RigidBody3D

@onready var player = get_parent().get_node("%Player")
@onready var mesh = find_children("MeshInstance3D")

var is_grabbed = false
var posDiffpast = Vector3(0,0,0)

@export_category("Object Properties")
@export var obj_id: int # the id of the object
@export var useble: int # whether the object can be used in the inventory 0 = no 1 = yes
@export var effect: int # if the object what does it do: 0 = nothing, 1 = health, 2 = food, 3 = water, 4 = tool
@export var effect_amount: int # how much the effect is: 0 = nothing
@export var obj_name: String
@export var can_grab: bool
@export var can_pickup: bool
@export var can_interact: bool
@export var important_obj: bool


@onready var scene_path = self.scene_file_path
var heldrotation = Vector3(0, 0, 0)

@onready var id = [obj_id, useble, effect, effect_amount, obj_name, can_grab, can_pickup, can_interact, scene_path, important_obj]
var id2 = 0 #for spawning
var spawned = false #for spawning
var r = 5
var t = 0
var u = 0 

var outline_shown = false
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	if spawned:
		id = id2
	print(id[4], id)
	print(player)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in mesh.size():
		if !outline_shown and important_obj:
			mesh[i].showme()

func _physics_process(delta: float):
	# Process for making object move to pointer
	if is_grabbed == true:
		gravity_scale = 0
		
		if u == 0:
			basis.x = Vector3(1, 0, 0) # Vector pointing along the X axis
			basis.y = Vector3(0, 1, 0) # Vector pointing along the Y axis
			basis.z = Vector3(0, 0, 1) # Vector pointing along the Z axis
			#rotate_y(player.CameraRotation.x)
		u = 1
		
		#get Current position
		var cpos = get_global_position()
		#print("cpos",cpos)
		#get position of the player's pointer
		var tpos = player.grabpoint.get_global_position()
		#print("tpos",tpos)
		#find the differance
		var posDiff = tpos - cpos
		#print("posDiff",posDiff)
		var proportional_force = posDiff*1.4 #get the propotional error
		#print("proportional", proportional_force)
		var dirivitive_force = 0.5*((posDiff-posDiffpast)/delta)
		#print("dirivative", dirivitive_force)
		var intergral_force = 1*(posDiff*delta)
		var total_force = (proportional_force+dirivitive_force+intergral_force)*10
		#print("total",total_force)
		posDiffpast = posDiff
		
		#rotation.x = heldrotation.x
		#print(cos(player.CameraRotation.x))
		rotate_x(heldrotation.x*cos(player.CameraRotation.x))
		rotate_z(heldrotation.x*sin(player.CameraRotation.x))
		rotate_z(heldrotation.z*cos(player.CameraRotation.x))
		rotate_x(heldrotation.z*-sin(player.CameraRotation.x))
		rotate_y(heldrotation.y-(player.CameraRotation.x-t))
		transform = transform.orthonormalized()
		heldrotation = Vector3(0, 0, 0)
		apply_central_force(total_force)
		t = player.CameraRotation.x
		
		apply_central_force(total_force)
	elif is_grabbed == false:
		gravity_scale = 1
		heldrotation = Vector3(0, 0, 0)
		u = 0
		t = 0
		lock_rotation = false

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("ui_interact"):
		print(10901010)
		
func _input(event):
	if event.is_action("left_arrow"):
		heldrotation.y -= deg_to_rad(r)
	if event.is_action("right_arrow"):
		heldrotation.y += deg_to_rad(r)
	if event.is_action("up_arrow"):
		heldrotation.x -= deg_to_rad(r)
	if event.is_action("down_arrow"):
		heldrotation.x += deg_to_rad(r)
	if event.is_action("toprotateleft"):
		heldrotation.z += deg_to_rad(r)
	if event.is_action("toprotateright"):
		heldrotation.z -= deg_to_rad(r)
		
func initialize(x,y,z,id1,Player1):
	var cords = Vector3(x,y,z)
	set_global_position(cords)
	id2 = id1
	spawned = true
	print("init",id2,spawned)
	player = Player1

func yoink(event):
	queue_free()
	print(19191)
	
func grab(event):
	if is_grabbed == false:
		is_grabbed = true
	else:
		is_grabbed = false
	print(19191)
	
func define_things():
	#player = %Player
	#print(player)
	pass
