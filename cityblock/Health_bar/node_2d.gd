extends Node2D

const MAX_HYDRATION = 100
const MAX_HUNGER = 100
const MAX_HEALTH = 100

@onready var animations = $"Health Bar Animation"
@onready var hyrdration_bar = $"Water Bottle"
@onready var hunger_bar = $Apple 
@onready var health_bar = $Heart

var hydration = MAX_HYDRATION
var hunger = MAX_HUNGER
var health = MAX_HEALTH

func _ready() -> void:
	hyrdration_bar.max_value = MAX_HYDRATION
	hunger_bar.max_value = MAX_HUNGER
	health_bar.max_value = MAX_HEALTH
	$Slider_water.max_value = MAX_HEALTH
	$Slider_health.max_value = MAX_HYDRATION
	$Slider_hunger.max_value = MAX_HUNGER
	$Slider_water.value = MAX_HYDRATION
	$Slider_hunger.value = MAX_HUNGER
	$Slider_health.value = MAX_HEALTH
	update_status_bars()

func _process(_delta):
	hydration = $Slider_water.value
	hunger = $Slider_hunger.value
	health = $Slider_health.value
	update_status_bars()

func update_status_bars():
	set_status_bar_values()
	heart_animation()

func set_status_bar_values() -> void:
	hyrdration_bar.value = hydration
	hunger_bar.value = hunger
	health_bar.value = health

func heart_animation():
	if health <= MAX_HEALTH * 0.6:
		animations.speed_scale = 5 - health/20
	if 0 < health and health <= MAX_HEALTH * 0.6:
		if not animations.is_playing():
			animations.play("Heart Beat")
	elif animations.current_animation_position <= 0.1:
		animations.stop()
