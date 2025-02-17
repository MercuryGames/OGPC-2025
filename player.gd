extends CharacterBody3D
@onready var MainCamera = get_node("Camera3D")

@export_category("Movement")
@export var run_multiplier: float
@export var base_speed = 5.0
@export var JUMP_VELOCITY = 4.5
@onready var SPEED = base_speed

@onready var interaction_raycast = %raycast3d #Make sure the node reference is set correctly
@onready var interaction_label = %Label
@onready var grabpoint = %grabpointer
var interaction_is_reset : bool = true
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var CameraRotation = Vector2(0,0)
var MouseSensitivity = 0.001

var inventoryState = false #whether the inventory menu is open or closed
var inventory = [] #the inventory array
#var inventoryItemNumber = 0 #number of items in the inventory array
@onready var inventoryList = %Items
var menu_state = false #whether the pause menu is open or closed
@onready var pause_menu = %"Pause Menu"
@onready var inventory_ui = %Inventory

var health = 100
var hunger = 100
var hydration = 100 
@onready var health_bar = %Meter_Health
@onready var food_bar = %Meter_Food
@onready var hydration_bar = %Meter_Hydration
@export_category("Hunger and Hydration Stats")
@export var food_drain_passive: float
@export var food_drain_buff_walking: float
@export var food_drain_buff_running: float
@export var hydration_drain_passive: float
@export var hydration_drain_buff_walking: float
@export var hydration_drain_buff_running: float
@export var starvation_damage: float
@export var dehydration_damage: float

signal item_spawned(id)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pause_menu.hide()
	inventory_ui.hide()
	
var holding_object = false
var object_held

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		menu_controller(0)
	if event is InputEventMouseMotion:
		var MouseEvent = event.relative * MouseSensitivity
		CameraLook(MouseEvent)
	if event.is_action_pressed("ui_interact") and holding_object == false: #Adjust to match your InputMap
		if interaction_raycast.is_colliding():
			var interactable = interaction_raycast.get_collider()
			print(interactable.id)
			if interactable.id[6] == true:
				print(interactable.id)
				#inventoryItemNumber += 1
				inventory.append(interactable.id)
				inventoryList.add_item(str(interactable.id[0],",",interactable.id[4]), null, true)
				interactable.yoink(self)
				interactable.hide()
	elif event.is_action_pressed("ui_grab") and holding_object == false:
		if interaction_raycast.is_colliding():
			var interactable = interaction_raycast.get_collider()
			print(interactable.id)
			if interactable.id[5]==true:
				interactable.grab(self) # Calls the grab function
				holding_object = true
				object_held = interactable
	elif event.is_action_pressed("ui_grab") and holding_object == true:
		object_held.grab(self)
		holding_object = false
		object_held = null
		
	if event.is_action_pressed("ui_inventory"):
		menu_controller(1)

func menu_controller(type):
	if type == 0:
		if menu_state == false:
			get_tree().paused = true
			pause_menu.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			menu_state = true
		elif menu_state == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			pause_menu.hide()
			get_tree().paused = false
			menu_state = false
	elif type == 1:
		if inventoryState == false:
			inventory_ui.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			inventoryState = true
		else:
			inventory_ui.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			inventoryState = false
			

func CameraLook(Movement: Vector2):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		CameraRotation += Movement
		CameraRotation.y = clamp(CameraRotation.y, -1.5,1.2)
		
		
		transform.basis = Basis()
		MainCamera.transform.basis = Basis()
		
		rotate_object_local(Vector3(0,1,0), -CameraRotation.x) # first rotate y
		MainCamera.rotate_object_local(Vector3(1,0,0), -CameraRotation.y) #then rotate x

func _process(delta):
	if Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") and Input.is_action_pressed("run"):
		hunger -= (food_drain_buff_running + food_drain_passive)*delta
		hydration -= (hydration_drain_buff_running+hydration_drain_passive)*delta
	elif Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down"):
		hunger -= (food_drain_buff_walking+food_drain_passive)*delta
		hydration -= (hydration_drain_buff_walking+hydration_drain_passive)*delta
	else:
		hunger -= food_drain_passive*delta
		hydration -= hydration_drain_passive*delta
	hunger = clamp(hunger,0,100)
	hydration = clamp(hydration,0,100)
	if hunger == 0:
		health -= starvation_damage*delta
	if hydration == 0:
		health -= dehydration_damage*delta
	
	if interaction_raycast.is_colliding():
		var interactable = interaction_raycast.get_collider()
		interaction_is_reset = false
		if interactable != null and interactable.id[5] and interactable.id[6]:
			interaction_label.text = "Q to grab|E to yoink"
		if interactable != null and interactable.id[5]:
			interaction_label.text = "Q to grab"
		if interactable != null and interactable.id[6]:
			interaction_label.text = "E to yoink"

	else:
		if !interaction_is_reset:
			interaction_label.text = ""
			interaction_is_reset = true
			
	health_bar.value = health
	food_bar.value = hunger
	hydration_bar.value = hydration
	


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
	if Input.is_action_pressed("run"):
		SPEED = base_speed*run_multiplier
	else:
		SPEED = base_speed
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func use_item(index: int):
	print(inventory[index])
	if inventory[index][1] == 0:
		item_spawned.emit(inventory[index])
		inventoryList.remove_item(index)
		inventory.pop(index)
	elif inventory[index][1] == 1:
		if inventory[index][2] == 0:
			item_spawned.emit(inventory[index])
			inventoryList.remove_item(index)
			inventory.remove_at(index)
		elif inventory[index][2] == 1:
			health += inventory[index][3]
			inventoryList.remove_item(index)
			inventory.remove_at(index)
		elif inventory[index][2] == 2:
			hunger += inventory[index][3]
			inventoryList.remove_item(index)
			inventory.remove_at(index)
		elif inventory[index][2] == 3:
			hydration += inventory[index][3]
			inventoryList.remove_item(index)
			inventory.remove_at(index)

func _on_items_item_activated(index: int) -> void:
	use_item(index)
		

func _on_button_return_game_pressed() -> void:
	menu_controller(0)
