extends CharacterBody3D
@onready var MainCamera = get_node("Camera3D")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var interaction_raycast = %raycast3d #Make sure the node reference is set correctly
@onready var interaction_label = %Label
@onready var grabpoint = %grabpointer
var interaction_is_reset : bool = true
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var CameraRotation = Vector2(0,0)
var MouseSensitivity = 0.001

var inventoryState = 0
var inventory = []
var inventoryItemNumber = 0
@onready var inventoryList = %Items

signal item_spawned(id)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
var holding_object = false
var object_held
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		var MouseEvent = event.relative * MouseSensitivity
		CameraLook(MouseEvent)
	if event.is_action_pressed("ui_interact") and holding_object == false: #Adjust to match your InputMap
		if interaction_raycast.is_colliding():
			var interactable = interaction_raycast.get_collider()
			if interactable.has_method("interact"):
				interactable.interact(self) # Calls the interact func
				holding_object = true
				object_held = interactable
			elif interactable.has_method("yoink"):
				print(interactable.id)
				inventoryItemNumber += 1
				inventory.append(interactable.id)
				inventoryList.add_item(str(interactable.id[0]), null, true)
				interactable.yoink(self)
				interactable.hide()
	elif event.is_action_pressed("ui_interact") and holding_object == true:
		object_held.interact(self)
		holding_object = false
		object_held = null
		
	if event.is_action_pressed("ui_inventory"):
		if inventoryState == 0:
			%Inventory.show()
			inventoryState = 1
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			%Inventory.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			inventoryState = 0
				
		
func CameraLook(Movement: Vector2):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		CameraRotation += Movement
		CameraRotation.y = clamp(CameraRotation.y, -1.5,1.2)
		
		
		transform.basis = Basis()
		MainCamera.transform.basis = Basis()
		
		rotate_object_local(Vector3(0,1,0), -CameraRotation.x) # first rotate y
		MainCamera.rotate_object_local(Vector3(1,0,0), -CameraRotation.y) #then rotate x

func _process(_delta):
	if interaction_raycast.is_colliding():
		var interactable = interaction_raycast.get_collider()
		interaction_is_reset = false
		if interactable != null and interactable.has_method("interact"):
			interaction_label.text = "E to interact"
		if interactable != null and interactable.has_method("yoink"):
			interaction_label.text = "E to yoink"

	else:
		if !interaction_is_reset:
			interaction_label.text = ""
			interaction_is_reset = true
	


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
		if Input.is_action_pressed("ui_up"):
			velocity.x += 0.0001

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_items_item_activated(index: int) -> void:
	print(inventory[index])
	if inventory[index][1] == 1:
		item_spawned.emit(inventory[index][0])
	inventoryList.remove_item(index)
	
