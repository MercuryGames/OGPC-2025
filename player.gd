extends CharacterBody3D
@onready var MainCamera = get_node("Camera3D")
@onready var MapCamera = get_node("Camera3D2")
@onready var PlayerMarker = get_node("playermarker")
@onready var ObjMark1 = get_parent().get_node("objectiveMarker1")
@onready var MapMarkers = [PlayerMarker, ObjMark1]

@export_category("Movement")
@export var run_multiplier: float
@export var base_speed = 5.0
@export var JUMP_VELOCITY = 4.5
@onready var SPEED = base_speed
@onready var main_menu = load("res://title_level.tscn")

@onready var interaction_raycast = %raycast3d #Make sure the node reference is set correctly
@onready var interaction_label = %Label
@onready var grabpoint = %grabpointer
var interaction_is_reset : bool = true
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var CameraRotation = Vector2(0,0)
var MouseSensitivity = 0.001
var mapmode = false

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


#save related variables
@onready var save_menu = %save_menu
@onready var new_save_menu = %new_save_file_menu
@onready var save_file_list_disp = %exsisting_saves_menu
@onready var new_save_name = %new_file_name
var all_saves_list = []
var save_menu_state = false
var New_Save_File_Name = ""

@onready var saves_menu_166 = %existing_saves_loadmenu



signal item_spawned(id)
signal return_to_main_menu()

func _ready():
	self.set_collision_layer_value(1, false)
	self.set_collision_layer_value(2, true)
	self.set_collision_mask_value(1, false)
	self.set_collision_mask_value(2, true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pause_menu.hide()
	inventory_ui.hide()
	save_menu.hide()
	new_save_menu.hide()
	
	
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
	if event.is_action_pressed("map"):
		if mapmode == false:
			MapCamera.make_current()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mapmode = true
		elif mapmode == true:
			MainCamera.make_current()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mapmode = false
	if event.is_action_pressed("zoom_in") and mapmode == true:
		if (MapCamera.position.y - MapCamera.position.y/10) >= 20:
			MapCamera.position.y -= MapCamera.position.y/10
		else:
			MapCamera.position.y = 20
	if event.is_action_pressed("zoom_out") and mapmode == true:
		if (MapCamera.position.y + MapCamera.position.y/10) <= 500:
			MapCamera.position.y += MapCamera.position.y/10
		else:
			MapCamera.position.y = 500

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
		if interactable != null and interactable.has_method("yoink"):
			if holding_object == false:
				for m in interactable.meshes.size():
					interactable.meshes[m].showme()
			if interactable != null and interactable.id[5] and interactable.id[6]:
				interaction_label.text = "Q to grab|E to yoink"
			elif interactable != null and interactable.id[5]:
				interaction_label.text = "Q to grab"
			elif interactable != null and interactable.id[6]:
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
	var input_dir = Input.get_vector("left", "right", "forwards", "backwards")
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
	if mapmode == false:
		move_and_slide()
		for g in MapMarkers.size():
			MapMarkers[g].hide()
	else:
		for g in MapMarkers.size():
			MapMarkers[g].show()
	MapCamera.set_rotation(Vector3(-rotation.x-deg_to_rad(90), -rotation.y, -rotation.z))
	for g in MapMarkers.size():
		MapMarkers[g].scale.x = MapCamera.position.y/100
		#MapMarkers[g].scale.y = MapCamera.position.y/100
		MapMarkers[g].scale.z = MapCamera.position.y/100

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


func _on_button_quit_to_menu_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu)


func _on_button_save_pressed() -> void:
	if !DirAccess.dir_exists_absolute("user://savegames/"):
		print("making dir")
		DirAccess.open("user://").make_dir("user://savegames/")
	var save_folder = DirAccess.open("user://savegames/")
	if save_folder:
		print("it worked")
		all_saves_list = save_folder.get_files()
	print(all_saves_list)
	save_menu.show()
	save_menu_state = true


func _on_save_menu_cancel_pressed() -> void:
	save_menu.hide()
	save_menu_state = false


func _on_new_save_button_pressed() -> void:
	New_Save_File_Name = ""
	new_save_name.clear()
	new_save_menu.show()


func _on_new_file_name_text_submitted(new_text: String) -> void:
	if new_text != null:
		New_Save_File_Name = new_text

func save_game(file_name):
	var file_sname = str("user://savegames/",file_name,".save")
	print(file_sname)
	var save_file = FileAccess.open(file_sname, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	if save_file == null:
		print("'Something terrible has happened.'")
		print(FileAccess.get_open_error())
	for node in save_nodes:
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		
		var node_data = node.call("save")
		var json_string = JSON.stringify(node_data)
		save_file.store_line(json_string)

func load_game(file_name):
	var file_sname = str("user://savegames",file_name,".save")
	if not FileAccess.file_exists(file_sname):
		print("****")
		return # Error! We don't have a save to load.
	var save_file = FileAccess.open(file_sname, FileAccess.READ)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		if i == %player:
			continue
		i.queue_free()
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data
		
		if node_data["filename"] == "player.gd":
			for k in node_data.keys():
				if k == "filename" or k == "parent":
					continue
				position = Vector3(node_data["pos_x"], node_data["pos_y"], node_data["pos_z"])
				health = node_data["health"]
				hunger = node_data["hunger"]
				hydration = node_data["hydration"]
				inventory = node_data["invetory"]
			pass
		else:
			var new_object = load(node_data["filename"]).instantiate()
			get_node(node_data["parent"]).add_child(new_object)
			new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		# Now we set the remaining variables.
			for i in node_data.keys():
				if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
					continue
				new_object.set(i, node_data[i])
	return
	
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent_node_3d().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"pos_z" : position.z,
		"health" : health,
		"hunger" : hunger,
		"hydration" : hydration,
		"inventory" : inventory
	}
	return save_dict

func _on_new_save_file_confirm_pressed() -> void:
	if New_Save_File_Name != "":
		save_game(New_Save_File_Name)
	elif New_Save_File_Name == "":
		new_save_name.clear()
		new_save_name.placeholder_text = "Bad File Name"
	

func _on_new_save_file_cancel_pressed() -> void:
	new_save_name.clear()
	New_Save_File_Name = ""
	new_save_menu.hide()


func _on_button_load_pressed() -> void:
	if !DirAccess.dir_exists_absolute("user://savegames/"):
		print("making dir")
		DirAccess.open("user://").make_dir("user://savegames/")
	var save_folder = DirAccess.open("user://savegames/")
	if save_folder:
		print("it worked")
		all_saves_list = save_folder.get_files()
	print(all_saves_list)
	%"Load Menu".show()
	for i in all_saves_list:
		if i not in saves_menu_166.get_groups():
			saves_menu_166.add_item(String(i))
	
	
func _on_load_menu_exit_pressed() -> void:
	%"Load Menu".hide()


func _on_existing_saves_loadmenu_item_activated(index: int) -> void:
	print(index)
	load_game(saves_menu_166.get_index(index))
