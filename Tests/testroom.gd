extends Node3D
@export var ball: PackedScene

@onready var player = %Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for i in get_children():
	#	if i.has_method("define_things"):
	#		i.define_things()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_item_spawned(id: Variant) -> void:
	print(id)
	var spawnx = player.get_global_position().x + 1 
	var spawny = player.get_global_position().y + 1
	var spawnz = player.get_global_position().z + 1
	print(spawnx,spawny,spawnz)
	if id[0] == 100:
		print(id)
		var balll = ball.instantiate()
		
		balll.initialize(spawnx,spawny,spawnz,id,%Player)
		
		add_child(balll)
		
		balll.define_things()
