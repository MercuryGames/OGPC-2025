extends VehicleBody3D

@onready var player = get_parent().get_node("%Player")

var is_grabbed = false
var posDiffpast = Vector3(0,0,0)

@export_category("Object Properties")
@export var obj_id: int # the id of the object
@export var useble: int # whether the object can be used in the inventory 0 = no 1 = yes
@export var effect: int # if the object what does it do: 0 = nothing, 1 = health, 2 = food, 3 = water, 4 = tool
@export var effect_amount: int # how much the effect is: 0 = nothing
@export var obj_name: String
@export var can_grab: bool
@export var can_pickup: bool

@onready var id = [obj_id, useble, effect, effect_amount, obj_name, can_grab, can_pickup]

@export var engine_power: float
@export var brake_power: float
@export var steering_limt: float
@export var steer_speed: float
var gears = [0.25,0.5,0.75,1,1.25]
var gear = 0
var steer_target = 0
var gas_pedal_angle = 0
var break_pedal_angle = 0
var is_driven = true

func _physics_process(delta: float) -> void:
	if is_driven:
		steer_target = Input.get_axis("right","left")
		steer_target *= steering_limt
		
		if Input.is_action_pressed("forwards"):
			engine_force = 5000
		else:
			engine_force = 0
		
		steering = move_toward(steering, steer_target, steer_speed * delta)
