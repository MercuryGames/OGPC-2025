extends Node3D
@export var ball: PackedScene

@onready var player = %Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_item_spawned(id: Variant) -> void:
	print(id)
	var spawnx = player.get_global_position().x + 1 
	var spawny = player.get_global_position().y + 1
	var spawnz = player.get_global_position().z + 1
	print(spawnx,spawny,spawnz)
	if id == 100:
		print(id)
		var balll = ball.instantiate()
		balll.initialize(spawnx,spawny,spawnz)
		add_child(balll)
		
