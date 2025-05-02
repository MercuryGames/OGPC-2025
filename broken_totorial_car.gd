extends StaticBody3D

@onready var id = [7005, 0, 0, 0, "Broken Car", false, false, true, 0]

var parts_needed = ["Battery", "Tire", "Tyre", "Gear"]
var parts_inplace = []
var parts_number = 0


signal car_has_been_fixed()

func interact():
	pass

func _process(delta: float) -> void:
	parts_number = 0
	for i in parts_needed:
		if i in parts_inplace:
			parts_number += 1
			
	if parts_number == len(parts_needed):
		car_has_been_fixed.emit()
