extends Node

@export var wind_force: float
@export var wind_direction: float 

signal wind_affect(force: float, direction:float)

func _on_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
