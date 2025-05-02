extends Node3D

@onready var player = %Player


signal message_zone_entered(message_text: String)

func _on_message_1_zone_body_entered(body: Node3D) -> void:
	if body == player:
		message_zone_entered.emit("hemslo")
