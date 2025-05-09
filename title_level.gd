extends Node3D

@onready var map0 = load("res://Tests/testroom.tscn")
@export var map1: PackedScene
#@onready var title_screen = load("res://title_level_1.tscn")
#@onready var Title_level1 = %Title_Level1
#@onready var main_menu = %"Main Menu"
#@onready var title_screen = %Title_Level1
#@onready var level = %Level
@onready var maps = [map0,map1]

#var level1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#level.hide()
	get_tree().paused = false
	#print(DirAccess.get_files_at("res://"))
	#print(DirAccess.get_files_at("user://"))
	#print(DirAccess.get_directories_at("user://"))
	#var testingfile = FileAccess.open("user://savegames/testing.save", FileAccess.WRITE_READ)
	#testingfile.store_line("Testing Testing")
	#testingfile.close()
	#print(DirAccess.get_files_at("user://"))
	#print(DirAccess.get_directories_at("user://"))
	#print(DirAccess.open("user://").get_drive_name(DirAccess.open("user://").get_current_drive()))
	#print(DirAccess.get_files_at("user://savegames/"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_main_menu_quit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_main_menu_start_new_game(map: Variant) -> void:
	get_tree().change_scene_to_packed(maps[map])
