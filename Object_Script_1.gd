extends RigidBody3D

@onready var player = get_tree().get_root().get_node("/root/TestRoom/Player")
@onready var meshes = find_children("MeshInstance3D")
@onready var outlineMat = load("res://outlineMaker.gd")

var is_grabbed = false
var posDiffpast = Vector3(0,0,0)
var r = 5
var t = 0
var u = 0 
@export_category("Object Properties")
@export var obj_id: int # the id of the object
@export var useble: int # whether the object can be used in the inventory 0 = no 1 = yes
@export var effect: int # if the object what does it do: 0 = nothing, 1 = health, 2 = food, 3 = water, 4 = tool
@export var effect_amount: int # how much the effect is: 0 = nothing
@export var obj_name: String
@export var can_grab: bool
@export var can_pickup: bool
var heldrotation = Vector3(0, 0, 0)
# Contains the following default values:


@onready var id = [obj_id, useble, effect, effect_amount, obj_name, can_grab, can_pickup]
var id2 = 0 #for spawning
var spawned = false #for spawning
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_collision_layer_value(1, true)
	self.set_collision_layer_value(2, true)
	self.set_collision_mask_value(1, true)
	self.set_collision_mask_value(2, true)
	if spawned:
		id = id2
	print(id[4], id)
	print(player)
	for m in meshes.size():
		print(m)
		meshes[m].set_script(outlineMat)
		meshes[m]._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float):
	# Process for making object move to pointer
	if is_grabbed == true:
		for m in meshes.size():
			meshes[m].hideme()
		self.set_collision_layer_value(2, false)
		self.set_collision_mask_value(2, false)
		lock_rotation = true
		gravity_scale = 0
		if u == 0:
			basis.x = Vector3(1, 0, 0) # Vector pointing along the X axis
			basis.y = Vector3(0, 1, 0) # Vector pointing along the Y axis
			basis.z = Vector3(0, 0, 1) # Vector pointing along the Z axis
			#rotate_y(player.CameraRotation.x)
		u = 1
		#rotation.y -= player.CameraRotation.x
		#basis.x = Vector3(1, 0, 0) # Vector pointing along the X axis
		#basis.y = Vector3(0, 1, 0) # Vector pointing along the Y axis
		#basis.z = Vector3(0, 0, 1) # Vector pointing along the Z axis
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
		print(cos(player.CameraRotation.x))
		rotate_x(heldrotation.x*cos(player.CameraRotation.x))
		rotate_z(heldrotation.x*sin(player.CameraRotation.x))
		rotate_z(heldrotation.z*cos(player.CameraRotation.x))
		rotate_x(heldrotation.z*-sin(player.CameraRotation.x))
		rotate_y(heldrotation.y-(player.CameraRotation.x-t))
		transform = transform.orthonormalized()
		heldrotation = Vector3(0, 0, 0)
		apply_central_force(total_force)
		t = player.CameraRotation.x
	elif is_grabbed == false:
		for m in meshes.size():
			meshes[m].hideme()
		self.set_collision_layer_value(2, true)
		self.set_collision_mask_value(2, true)
		heldrotation = Vector3(0, 0, 0)
		gravity_scale = 1
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


func _on_area_3d_body_entered(body: Node3D) -> void:
	body.freeze = true
	body.is_grabbed = false
