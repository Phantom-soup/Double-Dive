class_name State
extends Node

@export var animation_name : String

var fall_speed = 1500
var gravity = 2500

var direction = 0
var last_direction = 1
var speed = 1500
var acceleration = 1500
var friction = 4000
var turn_acceleration = 8000

var edge_threshold: float = 18

var stomp = false

var jump_power_initial = -300
var jump_power = 3000
var jump_distance = -1000
var jump_time_max = 0.1
var jump_timer = 0
var coyote_time = 0.1
var coyote_timer = 0
var has_jumped = false
var can_doublejump = false

var slide = false
var slide_speed = 1000
var slide_friction = 500

var bounce = false
var bounce_power = -1200
var bounced = false

var spinkick = false
var spinkick_time = 0.333333333333
var bayblade = false

var airdash = false
var airdashed = false
var airdash_speed = 2000
var airdash_time = 0.2

var boost = false
var boost_speed = 3000
var boostjumped = false
var wallran = false
var air_boost_power = -500
var antigravity = 1250

var dropdash = false
var dropdashed = false
var spindash_charge_time = 0.0
var spindash_power = lerp(1500, 3000, spindash_charge_time)
var spincharge = false
var spinload = false
var spinball = false
var hedgehog_speed = 300

var lock_mvt = false
var lock_stomp = false
var lock_jump = false
var lock_slide = false
var lock_bounce = false
var lock_spinkick = false
var lock_airdash = false
var lock_boost = false
var lock_dropdash = false

var played_land = false
var played_jumpball = false
var played_boost = false

## Hold a reference to the parent so that it can be controlled by the state
var parent: Player

func enter() -> void:
	parent.animations.play(animation_name)

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null
