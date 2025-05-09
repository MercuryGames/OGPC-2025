extends Node3D
@export var ball: PackedScene

@onready var player = %Player

var wind_force = 1
var wind_direction = deg_to_rad(25)
var wind_vector = Vector3(sin(wind_direction)*wind_force,0,cos(wind_direction)*wind_force)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for i in get_children():
	#	if i.has_method("define_things"):
	#		i.define_things()
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#for i in get_children():
		#if i.is_class("RigidBody3D"):
		#	i.apply_force(wind_vector)
	pass
	
func _on_player_item_spawned(id: Variant) -> void:
	print(id)
	var spawnx = player.get_global_position().x + 1 
	var spawny = player.get_global_position().y + 1
	var spawnz = player.get_global_position().z + 1
	print(spawnx,spawny,spawnz)
	
	var node_path = id[8]
	
	if id[0]:
		print(id)
		var node = load(node_path).instantiate()
		
		node.initialize(spawnx,spawny,spawnz,id,%Player)
		
		add_child(node)
		
		node.define_things()
