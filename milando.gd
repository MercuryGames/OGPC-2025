extends Node3D

@onready var player = %Player


signal message_zone_entered(message_text: String)

func _on_message_1_zone_body_entered(body: Node3D) -> void:
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
