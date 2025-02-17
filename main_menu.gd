extends Control

@onready var title_menu = %menu_container
@onready var new_game_menu = %new_game_menu

signal start_new_game(map)
signal quit_game()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _on_play_button_pressed() -> void:
	title_menu.hide()
	new_game_menu.show()

func _on_load_button_pressed() -> void:
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	quit_game.emit()


func _on_new_game_start_pressed() -> void:
	start_new_game.emit(0)
