extends CharacterBody2D

var fall_speed = 1500
var gravity = 2500

var direction = 0
var last_direction = 1
var speed = 900
var acceleration = 1500
var friction = 1500
var turn_acceleration = 5000

var run_speed_break = 1600
var run_speed = 1800
var run_acceleration = 1500
var running = false

var crawl_speed = 500
var crawl_acceleration = 1000
var crouching = false
var sliding_speed = 2000
var sliding = false

var jump_power_initial = 500
var jump_power = 4000
var jump_distance = 16000
var jump_time_max = 0.15
var jump_timer = 0
var has_jumped = false

var wall_hop_power_initial = 500
var wall_hop_power = 4000
var wall_hop_distance = 5000
var wall_hop_pushoff = 900
var wall_sliding_speed = 1000
var sliding_gravity = 1700
var wall_cling = false
var cling_direction = 0
var hop_off = false

var wall_kick_vert_power = 1500
var wall_kick_horzont_power = 1500

var coyote_time = 0.1
var coyote_timer = 0
var late_jump_time = 0.1
var late_jump_timer = 0

enum Act{IDLE, WALK, RUN, JUMPING, FALLING, WALLHUG, CROUCH, SLIDE, SPINATTACK}
var current_act: Act = Act.IDLE
var previous_act: Act = Act.IDLE

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Action"):
		if crouching:
			velocity.x = sliding_speed * last_direction
			sliding = true
		
		if is_on_wall_only():
			velocity.x = wall_kick_horzont_power * -cling_direction

func _physics_process(delta: float) -> void:
	update_movement(delta)
	grav_down(delta)
	jump(delta)
	coyote_timing(delta)
	update_acts(delta)
	update_animation()
	flip_sprite()
	move_and_slide()

func update_acts(delta: float) -> void:
	pass

func grav_down(delta: float) -> void:
	if !wall_cling:
		velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)
	else:
		velocity.y = move_toward(velocity.y, wall_sliding_speed, sliding_gravity * delta)
	if !is_on_floor():
		crouching = false
		has_jumped = false

func update_movement(delta: float) -> void:
	direction = Input.get_axis("Left", "Right")
	
	if Input.is_action_pressed("Down"):
		crouching = true
	else:
		crouching = false
	
	if direction:
		last_direction = direction
		
		if direction * velocity.x < 0: #turning around
			velocity.x = move_toward(velocity.x, direction * speed, turn_acceleration * delta)
		elif crouching: #crawling
			velocity.x = move_toward(velocity.x, direction * crawl_speed, crawl_acceleration * delta)
		elif abs(velocity.x) > run_speed_break: #speed break
			velocity.x = move_toward(velocity.x, direction * run_speed, run_acceleration * delta)
		else: #walking
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		
		if is_on_wall_only():
			wall_cling = true
			cling_direction = last_direction
		else:
			wall_cling = false
	else: #stopping
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func jump(delta: float) -> void:
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor() or coyote_timer > 0:
			velocity.y = -jump_power_initial
			jump_timer = jump_time_max
			
		if wall_cling:
			jump_timer = jump_time_max
			hop_off = true
			velocity.y = -wall_hop_power_initial
			velocity.x = wall_hop_pushoff * -cling_direction
	elif Input.is_action_pressed("Jump") and jump_timer > 0:
		jump_timer -= delta
		
		if !hop_off:
			velocity.y = move_toward(velocity.y, -jump_distance, jump_power * delta)
		else:
			velocity.y = move_toward(velocity.y, -wall_hop_distance, wall_hop_power * delta)
	else:
		jump_timer = -1

func coyote_timing(delta: float) -> void:
	if is_on_floor() or is_on_wall_only():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

func update_animation() -> void:
	pass

func flip_sprite() -> void:
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
