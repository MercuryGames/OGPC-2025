extends Node3D
@export var ball: PackedScene
var citytiles: = [load("res://CITYBLOCK1.tscn")]
var cityarray = [
	[0, 0, 0],
	[0, 0, 0],
	[0, 0, 0]
]

@onready var player = %Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for g in cityarray.size():
		for h in cityarray[g].size():
			var block = citytiles[cityarray[g][h]].instantiate()
			block.initialize(36*g, 0, 36*h, player)
			add_child(block)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_item_spawned(id: Variant) -> void:
	print(id)
	var spawnx = player.grabpoint.get_global_position().x
	var spawny = player.grabpoint.get_global_position().y
	var spawnz = player.grabpoint.get_global_position().z
	print(spawnx,spawny,spawnz)
	if id[0] == 100:
		print(id)
		var balll = ball.instantiate()
		
		balll.initialize(spawnx,spawny,spawnz,id,%Player)
		
		add_child(balll)
		
		balll.define_things()
