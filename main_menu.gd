extends Control

@onready var title_menu = %menu_container
@onready var new_game_menu = %new_game_menu
@onready var fullscreen_button = %fullscreen_button
@onready var resolution_button = %Resolution_button
@onready var setting_menu = %settings_menu
@onready var forwards_keybind = %forwards_keybind_button
@onready var backwards_keybind = %backwards_keybind_button
@onready var left_keybind = %left_keybind_button
@onready var right_keybind = %right_keybind_button

signal start_new_game(map)
signal quit_game()

var resolutions = [["1280x720",Vector2(1280,720)], ["1920x1080",Vector2(1920,1080)],["12x12", Vector2(12,12)]]
var setting_keybind = [false,""]
@onready var save_settings_button = %save_setting_button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in resolutions:
		resolution_button.add_item(i[0],resolutions.find(i))
	load_keybind_button_text()
	var file_sname = str("user://random_game_settings_files.save")
	if FileAccess.file_exists(file_sname):
		var save_file = FileAccess.open(file_sname, FileAccess.READ)
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
			for i in node_data.keys():
				print("STSTTT")
				print(i)
				print(node_data[i])
				print(type_convert(node_data[i][0], TYPE_OBJECT))
				if node_data[i] is InputEvent:
					InputMap.action_erase_events(i)
					InputMap.action_add_event(i, type_convert(node_data[i][0], TYPE_OBJECT))
	else:
		print("nope")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_keybind_button_text():
	var forwardsevent = InputMap.action_get_events("forwards")
	var backwardevent = InputMap.action_get_events("backwards")
	var leftevent = InputMap.action_get_events("left")
	var rightevent = InputMap.action_get_events("right")
	print(forwardsevent)
	print(backwardevent)
	print(leftevent)
	print(rightevent)
	forwards_keybind.set_text(forwardsevent[0].as_text_keycode())
	backwards_keybind.set_text(backwardevent[0].as_text_keycode())
	left_keybind.set_text(leftevent[0].as_text_keycode())
	right_keybind.set_text(rightevent[0].as_text_keycode())
	
func _input(_event: InputEvent):
	if _event is InputEventKey:
		if setting_keybind[0] == true:
			if _event.keycode == KEY_ESCAPE:
				return
			else:
				InputMap.action_erase_events(setting_keybind[1])
				InputMap.action_add_event(setting_keybind[1], _event)
				load_keybind_button_text()
				print(_event)
				setting_keybind = [false, ""]
			
		
	
func _on_play_button_pressed() -> void:
	title_menu.hide()
	new_game_menu.show()

func _on_load_button_pressed() -> void:
	pass # Replace with function body.

func _on_settings_button_pressed() -> void:
	title_menu.hide()
	setting_menu.show()


func _on_quit_button_pressed() -> void:
	quit_game.emit()


func _on_new_game_start_pressed() -> void:
	start_new_game.emit(0)
	
func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	print(toggled_on)
	if toggled_on:
		print("fullscreen")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		print("windowed")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_resolution_button_item_selected(index: int) -> void:
	print(resolutions[index])
	DisplayServer.window_set_size(resolutions[index][1])


func _on_button_pressed() -> void:
	setting_menu.hide()
	title_menu.show()
	


func _on_forwards_keybind_button_pressed() -> void:
	forwards_keybind.set_text("press a key")
	setting_keybind = [true, "forwards"]
	
	

func _on_backwards_keybind_button_pressed() -> void:
	backwards_keybind.set_text("press a key")
	setting_keybind = [true, "backwards"]


func _on_left_keybind_button_pressed() -> void:
	left_keybind.set_text("press a key")
	setting_keybind = [true, "left"]


func _on_right_keybind_button_pressed() -> void:
	right_keybind.set_text("press a key")
	setting_keybind = [true, "right"]


func _on_save_setting_button_pressed() -> void:
	var file_sname = str("user://random_game_settings_files.save")
	if file_sname != null:
		save_settings_button.set_text("Saving .")
		var save_file = FileAccess.open(file_sname, FileAccess.WRITE)
		var forwardsevent = InputMap.action_get_events("forwards")
		var backwardevent = InputMap.action_get_events("backwards")
		var leftevent = InputMap.action_get_events("left")
		var rightevent = InputMap.action_get_events("right")
		print(forwardsevent)
		print(backwardevent)
		print(leftevent)
		print(rightevent)
		var save_dictionary = {
			"forwards_keybind" : forwardsevent,
			"backwards_keybind" : backwardevent,
			"left_keybind" : leftevent,
			"right_keybind" : rightevent
		}
		print(save_dictionary)
		save_settings_button.set_text("Saving ..")
		var json_string = JSON.stringify(save_dictionary)
		print(json_string)
		save_settings_button.set_text("Saving ...")
		save_file.store_line(json_string)
	else:
		print("didnt")
	save_settings_button.set_text("Save Settings")
