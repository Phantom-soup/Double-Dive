extends CharacterBody2D

var fall_speed = 1500
var gravity = 2500

var direction = 0
var last_direction = 1
@export var speed = 1500
@export var acceleration = 1500
@export var friction = 4000
@export var turn_acceleration = 8000

var jump_power_initial = -300
var jump_power = 3000
var jump_distance = -1000
var jump_time_max = 0.1
var jump_timer = 0
var coyote_time = 0.1
var coyote_timer = 0
var has_jumped = false
var can_doublejump = false

enum Act{IDLE, WALK, JUMPING, FALLING}
var current_act: Act = Act.IDLE

func _physics_process(delta: float) -> void:
	grav_down(delta)
	update_movement(delta)
	jump(delta)
	update_acts()
	update_animation()
	flip_sprite()
	move_and_slide()

func grav_down(delta: float) -> void:
	velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)

func jump(delta: float) -> void:
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor() or coyote_time > 0:
			velocity.y = jump_power_initial
	elif Input.is_action_pressed("Jump") and jump_timer < 0:
		velocity.y = move_toward(velocity.y, jump_distance, jump_power * delta)
		jump_timer -= delta
	else:
		jump_timer = -1

func update_acts() -> void:
	match current_act:
		Act.IDLE:
			if velocity.x != 0:
				current_act = Act.WALK
		
		Act.WALK:
			if velocity.x == 0:
				current_act = Act.IDLE
			if not is_on_floor() && velocity.y > 0:
				current_act = Act.FALLING
		
		Act.JUMPING when velocity.y > 0:
			current_act = Act.FALLING
		
		Act.FALLING:
			if velocity.x == 0:
				current_act = Act.IDLE
			else:
				current_act = Act.WALK

func update_movement(delta: float) -> void:
	direction = Input.get_axis("Left", "Right")
	
	if direction:
		if direction * velocity.x < 0:
			velocity.x = move_toward(velocity.x, direction * speed, turn_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func flip_sprite() -> void:
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true

func update_animation() -> void:
	pass
