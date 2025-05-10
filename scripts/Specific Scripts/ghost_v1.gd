extends CharacterBody2D

#Movement
var direction = 0
var last_direction = 1
var speed = 1500
var acceleration = 1500
var friction = 4000
var turn_acceleration = 8000

#Jump
var jump_power_initial = -300
var jump_power = 3000
var jump_distance = -1000
var jump_time_max = 0.1
var jump_timer = 0
var coyote_timer = 0
var has_jumped = false
var can_doublejump = false

#Gravity
var fallSpeed = 1500
var gravity = 2500

enum State{
	IDLE,
	WALK,
	JUMP
}
#var current_state: State = State.IDLE

func _physics_process(delta: float) -> void:
	flip_sprite()
	_gravity(delta)
	previous_direction()
	_coyote_time(delta)
	
	
	direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	previous_direction()
	
	if direction: # Are we moving?
		if direction * velocity.x < 0: # Are we trying to halt our movement?
			velocity.x = move_toward(velocity.x, direction * speed, turn_acceleration * delta)
		else: # else, run in the correct direction
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else: # else, ease out of inertia
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	move_and_slide()


func flip_sprite():
	if velocity.x > 0:
		$Animations.flip_h = false
	elif velocity.x < 0:
		$Animations.flip_h = true


func _gravity(delta: float) -> void:
	velocity.y = move_toward(velocity.y, fallSpeed, gravity * delta)


func previous_direction():
	if direction: # If running, make last_direction the same as orientation
		last_direction = direction
	else:  # Are we being pushed in a specific direction without input?
		if velocity.x < 0: # Are we moving left?
			last_direction =- 1 
		elif velocity.x > 0: # Are we moving right?
			last_direction = 1


func _jump(delta: float) -> void:
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor() or coyote_timer > 0:
			coyote_timer = -1
			jump_timer = jump_time_max
			velocity.y = jump_power_initial
			print("Jump!")
	else:
		if can_doublejump:
			can_doublejump = false
			jump_timer = jump_time_max
			velocity.y = jump_power_initial
			print("wait...")
		else:
			_gravity(delta)
			print("???")
	print("jump?")


func _coyote_time(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_timer
		can_doublejump = true
	else:
		coyote_timer -= delta
