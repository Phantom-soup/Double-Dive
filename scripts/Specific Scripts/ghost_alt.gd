extends CharacterBody2D

var fall_speed = 1500
var gravity = 2500

var direction = 0
var last_direction = 1
@export var speed = 1500
@export var acceleration = 1500
@export var friction = 4000
@export var turn_acceleration = 8000

enum Act{IDLE, WALK, JUMPING, FALLING}
var current_act: Act = Act.IDLE

func _physics_process(delta: float) -> void:
	grav_down(delta)
	handled_input(delta)
	update_movement(delta)
	update_acts()
	update_animation()
	move_and_slide()

func grav_down(delta: float) -> void:
	velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)

func handled_input(delta: float) -> void:
	direction = Input.get_axis("Left", "Right")
	

func update_acts() -> void:
	match current_act:
		Act.IDLE when velocity.x != 0:
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
	if direction:
		if direction * velocity.x < 0:
			velocity.x = move_toward(velocity.x, direction * speed, turn_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func update_animation() -> void:
	pass
