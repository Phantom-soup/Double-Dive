extends CharacterBody2D

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

func _gravity(delta: float) -> void:
	if boost or bayblade:
		velocity.y = move_toward(velocity.y, fall_speed, antigravity * delta)
	else:
		if stomp or bounce:
			velocity.y = 3000
		else:
			velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)

func _physics_process(delta: float) -> void:
	sfx()
	hitboxes()
	_coyote_time(delta)
	_spinkick(delta)
	_jump(delta)
	_bounce()
	_stomp()
	_airdash(delta)
	_boost()
	_spindash(delta)
	_slide()

	direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	previous_direction()
	if lock_mvt:
		if spinball:
			if direction:
				if !velocity.x:
					velocity.x = sign(last_direction) * hedgehog_speed
				else:
					velocity.x = move_toward(velocity.x, 0, slide_friction * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, slide_friction * delta)
		else:
			if spincharge or spinload:
				velocity.x = move_toward(velocity.x, 0, friction * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, slide_friction * delta)
	else:
		if spincharge or spinload:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
		else:
			if boost:
				if is_on_wall() and !wallran and !stomp and !bounce:
					if is_on_floor():
						if direction:
							velocity.x = direction
							velocity.y = jump_distance
						else:
							pass
					else:
						velocity.x = direction
						velocity.y = jump_distance
				if is_on_floor():
					if direction:
						if direction * velocity.x < 0:
							velocity.x = move_toward(velocity.x, direction * boost_speed, turn_acceleration * delta)
						else:
							velocity.x = sign(direction) * boost_speed
					else:
						velocity.x = move_toward(velocity.x, 0, friction * delta)
				else:
					if direction * velocity.x < 0:
						velocity.x = move_toward(velocity.x, direction * boost_speed, turn_acceleration * delta)
					else:
						velocity.x = sign(last_direction) * boost_speed
			else:
				if slide:
					if direction:
						if !velocity.x:
							velocity.x = sign(last_direction) * slide_speed
						else:
							velocity.x = move_toward(velocity.x, 0, slide_friction * delta)
					else:
						velocity.x = move_toward(velocity.x, 0, slide_friction * delta)
				else:
					if direction:
						if direction * velocity.x < 0:
							velocity.x = move_toward(velocity.x, direction * speed, turn_acceleration * delta)
						else:
							velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
					else:
						velocity.x = move_toward(velocity.x, 0, friction * delta)
	move_and_slide()
	flip_sprite()
	animations()
	vfx()
	_respawn()

func _stomp():
	if Input.is_action_just_pressed("Down") and !lock_stomp:
		if is_on_floor():
			if spinball:
				spinball = false
			else:
				if velocity.x:
					spinball = true
				else:
					pass
		else:
			bounce = false
			stomp = true
	if stomp:
		velocity.x = 0
		velocity.y = 3000
		lock_mvt = true
		lock_jump = true
		lock_slide = true
		lock_airdash = true
		lock_boost = true
		bounced = false
		airdash = false
		bayblade = false
		boost = false
		if !velocity.y:
			stomp = false
	else:
		velocity.x = velocity.x
		velocity.y = velocity.y
		lock_mvt = false
		lock_jump = false
		lock_slide = false
		lock_airdash = false
		lock_boost = false
		boost = boost

func previous_direction():
	if direction:
		last_direction = direction
	else:
		if velocity.x < 0:
			last_direction = -1
		elif velocity.x > 0:
			last_direction = 1

func flip_sprite():
	if bayblade:
		pass
	else:
		if is_on_wall():
			if last_direction == 1 or velocity.x > 0:
				$AnimatedSprite2D.flip_h = true
				$CollisionShape2D.position = Vector2(1, 18)
				$SpinCollision.position = Vector2(1, 22)
				$SlideCast2D.position = Vector2 (1, 9)
				$RayCast2DLeft.position = Vector2(-1, 31)
				$RayCast2DRight.position = Vector2(2, 31)
			elif last_direction == -1 or velocity.x < 0:
				$AnimatedSprite2D.flip_h = false
				$CollisionShape2D.position = Vector2(-1, 18)
				$SpinCollision.position = Vector2(-1, 22)
				$SlideCast2D.position = Vector2 (-1, 9)
				$RayCast2DLeft.position = Vector2(-2, 31)
				$RayCast2DRight.position = Vector2(1, 31)
		else:
			if spincharge or spinload:
				if last_direction == 1:
					$AnimatedSprite2D.flip_h = true
					$CollisionShape2D.position = Vector2(1, 18)
					$SpinCollision.position = Vector2(1, 22)
					$SlideCast2D.position = Vector2 (1, 9)
					$RayCast2DLeft.position = Vector2(-1, 31)
					$RayCast2DRight.position = Vector2(2, 31)
				elif last_direction == -1:
					$AnimatedSprite2D.flip_h = false
					$CollisionShape2D.position = Vector2(-1, 18)
					$SpinCollision.position = Vector2(-1, 22)
					$SlideCast2D.position = Vector2 (-1, 9)
					$RayCast2DLeft.position = Vector2(-2, 31)
					$RayCast2DRight.position = Vector2(1, 31)
			else:
				if velocity.x > 0:
					$AnimatedSprite2D.flip_h = true
					$CollisionShape2D.position = Vector2(1, 18)
					$SpinCollision.position = Vector2(1, 22)
					$SlideCast2D.position = Vector2 (1, 9)
					$RayCast2DLeft.position = Vector2(-1, 31)
					$RayCast2DRight.position = Vector2(2, 31)
				elif velocity.x < 0:
					$AnimatedSprite2D.flip_h = false
					$CollisionShape2D.position = Vector2(-1, 18)
					$SpinCollision.position = Vector2(-1, 22)
					$SlideCast2D.position = Vector2 (-1, 9)
					$RayCast2DLeft.position = Vector2(-2, 31)
					$RayCast2DRight.position = Vector2(1, 31)

func animations():
	if is_on_floor():
		if spinball:
			if !velocity.x:
				if spincharge:
					if spinload:
						$AnimatedSprite2D.play("spinload")
					else:
						$AnimatedSprite2D.play("spincharge")
				else:
					$AnimatedSprite2D.pause()
			else:
				if abs(velocity.x) < 376:
					$AnimatedSprite2D.play("hedgehog")
				else:
					$AnimatedSprite2D.play("spindash")
		else:
			if spincharge:
				if spinload:
					$AnimatedSprite2D.play("spinload")
				else:
					$AnimatedSprite2D.play("spincharge")
			else:
				if spinkick:
					$AnimatedSprite2D.play("spinkick")
				else:
					if direction * velocity.x < 0:
						if slide:
							$AnimatedSprite2D.play("slide")
						else:
							$AnimatedSprite2D.play("skid")
					else:
						if is_on_wall():
							if slide:
								$AnimatedSprite2D.play("crouch")
							else:
								$AnimatedSprite2D.play("push")
						else:
							if velocity.x == 0:
								if !$RayCast2DRight.is_colliding():
									if last_direction == 1:
										$AnimatedSprite2D.play("balance_front")
									elif last_direction == -1:
										$AnimatedSprite2D.play("balance_back")
								elif !$RayCast2DLeft.is_colliding():
									if last_direction == -1:
										$AnimatedSprite2D.play("balance_front")
									elif last_direction == 1:
										$AnimatedSprite2D.play("balance_back")
								else:
									if boost:
										$AnimatedSprite2D.play("get_set")
									else:
										if slide or Input.is_action_pressed("stomp (down)"):
											$AnimatedSprite2D.play("crouch")
										else:
											$AnimatedSprite2D.play("idle")
							else:
								if slide:
									$AnimatedSprite2D.play("slide")
								elif spinkick:
									$AnimatedSprite2D.play("spinkick")
								else:
									if abs(velocity.x) > 0 and abs(velocity.x) < 375:
										$AnimatedSprite2D.play("mach1")
									elif abs(velocity.x) > 376 and abs(velocity.x) < 750:
										$AnimatedSprite2D.play("mach2")
									elif abs(velocity.x) > 751 and abs(velocity.x) < 1125:
										$AnimatedSprite2D.play("mach3")
									elif abs(velocity.x) > 1126 and abs(velocity.x) < 1498:
										$AnimatedSprite2D.play("mach4")
									elif abs(velocity.x) > 1499 and abs(velocity.x) < 2000:
										$AnimatedSprite2D.play("mach5")
									elif abs(velocity.x) > 2001:
										$AnimatedSprite2D.play("mach6")
	else:
		if dropdash:
			$AnimatedSprite2D.play("spincharge")
		else:
			if spinball:
				$AnimatedSprite2D.play("spindash")
			else:
				if stomp:
					$AnimatedSprite2D.play("stomp")
				elif bounce:
					$AnimatedSprite2D.play("bounce")
				else:
					if bounced:
						$AnimatedSprite2D.play("spindash")
					else:
						if boost:
							if is_on_wall():
								if velocity.y <= 0:
									$AnimatedSprite2D.play("wallrun")
								else:
									$AnimatedSprite2D.play("stomp")
							else:
								if direction * velocity.x < 0:
									$AnimatedSprite2D.play("air_skid")
								else:
									$AnimatedSprite2D.play("air_boost")
						else:
							if bayblade:
								$AnimatedSprite2D.play("bayblading")
							else:
								if airdash:
									$AnimatedSprite2D.play("airdash")
								elif has_jumped:
									if Input.is_action_just_pressed("jump (A)"):
										if can_doublejump:
											if velocity.x == 0:
												$AnimatedSprite2D.play("spring")
											else:
												$AnimatedSprite2D.play("athletic_jump")
										else:
											$AnimatedSprite2D.play("jump")
									elif Input.is_action_pressed("jump (A)"):
										if can_doublejump:
											if jump_timer < jump_time_max and jump_timer > 0.05:
												if velocity.x == 0:
													$AnimatedSprite2D.play("spring")
												else:
													$AnimatedSprite2D.play("athletic_jump")
											elif jump_timer < 0.04:
												$AnimatedSprite2D.play("jump")
										else:
											$AnimatedSprite2D.play("jump")
									elif airdashed:
										$AnimatedSprite2D.play("stomp")
								else:
									$AnimatedSprite2D.play("stomp")

func sfx():
	if is_on_floor():
		$stomp.stop()
		if stomp:
			$stompland.play()
		elif bounce:
			$bounce.play()
		elif dropdash:
			$spinrelease.play()
			$dropdash.stop()
		else:
			if played_land:
				pass
			else:
				$land.play()
				$jumpball.stop()
	if Input.is_action_just_pressed("stomp (down)") or Input.is_action_just_pressed("bounce (B)") and !is_on_floor():
		if stomp or is_on_floor():
			pass
		else:
			$stomp.play()
			$jumpball.stop()
	if Input.is_action_just_pressed("stomp (down)") and is_on_floor() and velocity.x and !spinball and !boost and !stomp and !bounce and !spinkick and !dropdash:
		if velocity.x:
			$roll.play()
		else:
			pass
	if boost or spinkick or bayblade or stomp or bounce or airdash:
		pass
	else:
		if Input.is_action_just_pressed("jump (A)"):
			if is_on_floor() or coyote_timer > 0:
				if Input.is_action_pressed("spindash [LT]"):
					$dropdash.play()
				elif Input.is_action_pressed("boost [RT]"):
					$boostshockwave.play()
					$boost.play()
					$boostair.play()
				else:
					$jump.play()
			else:
				if can_doublejump and !dropdash:
					$jumpball.play()
				else:
					pass
		if Input.is_action_pressed("jump (A)") and !is_on_floor() and !Input.is_action_pressed("spindash [LT]"):
			if jump_timer < jump_time_max and jump_timer > 0.05:
				pass
			elif jump_timer < 0.05:
				if played_jumpball:
					pass
				else:
					$jumpball.play()
					played_jumpball = true
			else:
				pass
		else:
			pass
	if Input.is_action_just_pressed("bounce (B)") and is_on_floor() and !spincharge and !spinball and !spinload:
		if slide:
			pass
		else:
			if is_on_wall():
				$sliding.stop()
			else:
				$sliding.play()
			$boost.stop()
			$boostair.stop()
			played_boost = false
	if Input.is_action_pressed("bounce (B)") and is_on_floor():
		if !velocity.x:
			$sliding.stop()
			if direction or Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") and !spincharge and !spinball and !spinload:
				if is_on_wall():
					$sliding.stop()
				else:
					$sliding.play()
		else:
			pass
	else:
		if $SlideCast2D.is_colliding():
			if spinkick:
				if is_on_wall():
					$sliding.stop()
				else:
					$sliding.play()
			else:
				pass
			if !velocity.x:
				$sliding.stop()
				if direction or Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
					if is_on_wall():
						$sliding.stop()
					else:
						$sliding.play()
			else:
				pass
		else:
			$sliding.stop()
			if Input.is_action_pressed("boost [RT]") and slide:
				$boostshockwave.play()
				$boost.play()
				$boostair.play()
	if Input.is_action_just_pressed("homing attack (X)") and !spincharge and !spinball and !spinload and !slide and !dropdash and !stomp and !bounce:
		if is_on_floor():
			if spinkick:
				pass
			else:
				$spinkick.play()
		else:
			if airdash or airdashed:
				pass
			else:
				$jumpball.stop()
				$airdash.play()
	if Input.is_action_just_pressed("spindash [LT]"):
		$boost.stop()
		$boostair.stop()
		played_boost = false
		if is_on_floor():
			$spincharge.play()
		else:
			if dropdash:
				pass
			else:
				$dropdash.play()
	if Input.is_action_just_released("spindash [LT]") and is_on_floor():
		if Input.is_action_pressed("boost [RT]"):
			$boostshockwave.play()
			$boost.play()
			$boostair.play()
		else:
			if dropdashed:
				pass
			else:
				$spinrelease.play()
				$spincharge.stop()
	if Input.is_action_pressed("boost [RT]") and !Input.is_action_pressed("spindash [LT]") and !stomp and !bounce:
		if direction * velocity.x < 0:
			$boost.stop()
			$boostair.stop()
			played_boost = false
		else:
			if boost:
				if played_boost:
					pass
				else:
					if direction:
						if !velocity.x:
							$boost.stop()
							$boostair.stop()
							played_boost = false
						else:
							$boostshockwave.play()
							$boost.play()
							$boostair.play()
							played_boost = true
					else:
						if !is_on_floor() and !wallran:
							$boostshockwave.play()
							$boost.play()
							$boostair.play()
							played_boost = true
						else:
							$boost.stop()
							$boostair.stop()
							played_boost = false
				if is_on_wall():
					if played_land or is_on_floor():
						pass
					else:
						if velocity.y >= 0:
							$boost.stop()
							$boostair.stop()
							played_boost = false
						else:
							if played_boost:
								pass
							else:
								$boostshockwave.play()
								$boost.play()
								$boostair.play()
								played_boost = true
			else:
				$boost.stop()
				$boostair.stop()
				played_boost = false
	else:
		$boost.stop()
		$boostair.stop()
		played_boost = false

func vfx():
	var vel = velocity
	if vel.length() > 0:
		$Boost.rotation = vel.angle()
	if direction == 1 or velocity.x > 0:
		$WallRunBoost.position = Vector2(-7, 14)
	elif direction == -1 or velocity.x < 0:
		$WallRunBoost.position = Vector2(7, 14)
	if velocity.x > 0:
		$SlideSmoke.flip_h = true
		$SlideSmoke.position = Vector2(8, 20)
	elif velocity.x < 0:
		$SlideSmoke.flip_h = false
		$SlideSmoke.position = Vector2(-8, 20)
	if is_on_wall():
		$Boost.visible = false
		$SlideSmoke.visible = false
		if boost and velocity.y < 0:
			$WallRunBoost.visible = true
		else:
			$WallRunBoost.visible = false
	else:
		$WallRunBoost.visible = false
		if bounce or bounced:
			$SlideSmoke.visible = false
			$Boost.visible = false
			$WallRunBoost.visible = false
		else:
			if spinball or spinload or spincharge or dropdash:
				$SlideSmoke.visible = false
				$Boost.visible = false
				$WallRunBoost.visible = false
				$StompPulse.visible = false
			else:
				if boost:
					$SlideSmoke.visible = false
					if direction:
						if direction * velocity.x < 0:
							$Boost.visible = false
						else:
							$Boost.visible = true
					else:
						if is_on_floor():
							$Boost.visible = false
						else:
							$Boost.visible = true
				else:
					$Boost.visible = false
					if slide:
						if velocity.x:
							$SlideSmoke.visible = true
						else:
							$SlideSmoke.visible = false
					else:
						$SlideSmoke.visible = false
	if stomp:
		$StompPulse.visible = true
	else:
		$StompPulse.visible = false

func _jump(delta: float) -> void:
	if Input.is_action_just_pressed("jump (A)") and !lock_jump:
		has_jumped = true
		bounced = false
		spincharge = false
		spinload = false
		spinball = false
		spindash_charge_time = 0
		if is_on_floor() or coyote_timer > 0:
			spincharge = false
			coyote_timer = -1
			jump_timer = jump_time_max
			velocity.y = jump_power_initial
		else:
			if can_doublejump and !dropdash:
				can_doublejump = false
				jump_timer = jump_time_max
				velocity.y = jump_power_initial
			else:
				_gravity(delta)
	elif Input.is_action_pressed("jump (A)") and jump_timer > 0 and !lock_jump:
		velocity.y = move_toward(velocity.y, jump_distance, jump_power * delta)
		jump_timer -= delta
	else:
		jump_timer = -1
		_gravity(delta)

func _coyote_time(delta: float) -> void:
	if is_on_floor():
		played_land = true
		played_jumpball = false
		has_jumped = false
		coyote_timer = coyote_time
		can_doublejump = true
		airdashed = false
		stomp = false
		boostjumped = false
		wallran = false
		if bounced:
			bounced = false
		else:
			pass
		if spinkick:
			pass
		else:
			bayblade = false
	else:
		played_land = false
		coyote_timer -= delta

func _slide():
	if Input.is_action_pressed("bounce (B)") and is_on_floor() and !lock_slide  and !spincharge and !spinball and !spinload:
		slide = true
		spinball = false
	else:
		if $SlideCast2D.is_colliding():
			if spinkick:
				pass
			else:
				slide = true
		else:
			slide = false
	if slide:
		lock_airdash = true
		lock_boost = true
		lock_spinkick = true
		spinkick = false
		boost = false
	else:
		lock_airdash = false
		lock_boost = false
		lock_spinkick = false

func hitboxes():
	if spinball or spinload or spincharge or dropdash:
		$SpinCollision.disabled = false
		$SlideCollision.disabled = true
		$CollisionShape2D.disabled = true
	else:
		$SpinCollision.disabled = true
		if slide or spinkick:
			$SlideCollision.disabled = false
			$CollisionShape2D.disabled = true
		else:
			$SlideCollision.disabled = true
			$CollisionShape2D.disabled = false

func _bounce():
	if Input.is_action_just_pressed("bounce (B)") and !is_on_floor() and !lock_bounce:
		stomp = false
		airdash = false
		bayblade = false
		bounce = true
	if bounce:
		velocity.y = 3000
		lock_mvt = true
		lock_jump = true
		lock_slide = true
		lock_airdash = true
		lock_boost = true
		airdash = false
		bounced = false
		boost = false
		if is_on_floor():
			velocity.y = bounce_power
			bounce = false
			bounced = true
	else:
		velocity.y = velocity.y
		lock_mvt = false
		lock_jump = false
		lock_slide = false
		lock_airdash = false
		lock_boost = false
		boost = boost

func _spinkick(delta):
	if Input.is_action_just_pressed("homing attack (X)") and is_on_floor() and !spincharge and !spinball and !spinload and !slide:
		if spinkick:
			pass
		else:
			spinkick = true
	if spinkick:
		lock_mvt = true
		lock_stomp = true
		lock_jump = true
		lock_slide = true
		lock_bounce = true
		lock_dropdash = true
		lock_boost = true
		boost = false
		spinkick_time -= delta
		if Input.is_action_just_pressed("jump (A)"):
			bayblade = true
		if spinkick_time <= 0 or !is_on_floor() or spinball or spincharge or spinload or slide:
			spinkick = false
			if bayblade:
				$jump.play()
				velocity.y = jump_distance
			else:
				pass
		else:
			spinkick = true
	else:
		lock_mvt = false
		lock_stomp = false
		lock_jump = false
		lock_slide = false
		lock_bounce = false
		lock_dropdash = false
		lock_boost = false
		spinkick_time = 0.333333333333
	if bayblade:
		lock_jump = true
		lock_dropdash = true
		lock_boost = true
		boost = false
	else:
		lock_jump = false
		lock_dropdash = false
		lock_boost = false

func _airdash(delta):
	if Input.is_action_just_pressed("homing attack (X)") and !is_on_floor() and !lock_airdash:
		if airdash or airdashed or bounce:
			pass
		else:
			airdash = true
	if airdash:
		lock_jump = true
		lock_boost = true
		lock_dropdash = true
		bounced = false
		bayblade = false
		boost = false
		velocity.x = sign(last_direction) * airdash_speed
		velocity.y = 0
		lock_mvt = true
		airdash_time -= delta
		if airdash_time <= 0 or is_on_floor():
			airdash = false
			airdashed = true
			velocity.x = 0
		else:
			airdash = true
			airdashed = false
	else:
		lock_jump = false
		lock_boost = false
		lock_dropdash = false
		velocity.x = velocity.x
		velocity.y = velocity.y
		airdash_time = 0.2

func _boost():
	if Input.is_action_pressed("boost [RT]") and !lock_boost:
		boost = true
		bayblade = false
		bounced = false
		spinball = false
		if !is_on_floor() and !boostjumped and Input.is_action_just_pressed("boost [RT]"):
			boostjumped = true
			velocity.y = air_boost_power
	else:
		boost = false
	if is_on_ceiling():
		wallran = true

func _spindash(delta):
	if Input.is_action_pressed("spindash [LT]") and !lock_dropdash:
		if is_on_floor():
			if dropdash:
				pass
			else:
				if dropdashed:
					pass
				else:
					spincharge = true
		else:
			dropdash = true
	else:
		dropdash = false
		if is_on_floor() and spincharge and !dropdashed:
			spinball = true
			velocity.x = last_direction * spindash_power
		else:
			dropdashed = false
		spindash_charge_time = 0
		spincharge = false
		spinload = false

	if dropdash:
		boost = false
		boostjumped = true
		lock_boost = true
		bounce = false
		bounced = false
		stomp = false
		if is_on_floor():
			velocity.x = last_direction * boost_speed
			dropdash = false
			dropdashed = true
			spinball = true
	else:
		lock_jump = false
		lock_boost = false

	if spincharge:
		slide = false
		spinkick = false
		spinball = false
		boost = false
		lock_slide = true
		lock_spinkick = true
		lock_boost = true
		spindash_charge_time = move_toward(spindash_charge_time, 1.0, delta)
		spindash_power = lerp(1500, 3000, spindash_charge_time)
		if spindash_charge_time == 1:
			spinload = true
		else:
			spinload = false
	else:
		lock_slide = false
		lock_spinkick = false
		lock_boost = false

	if spinball:
		if !velocity.x or Input.is_action_just_pressed("spindash [LT]"):
			if $SlideCast2D.is_colliding():
				spinball = true
			else:
				spinball = false
		else:
			spinball = true
		lock_mvt = true
		lock_spinkick = true
		slide = false
	else:
		lock_mvt = false
		lock_spinkick = false

func _respawn():
	if Input.is_action_just_pressed("respawn"):
		position = Vector2(0, 0)
