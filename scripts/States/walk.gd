extends State

@export var idle_state : State
@export var jump_state : State
@export var crouch_state : State
@export var fall_state : State


# Called when the node enters the scene tree for the first time.
func enter() -> void:
	super()
	parent.velocity.x = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process_input(event : InputEvent) -> State:
	if Input.is_action_just_pressed("Jump") and parent.is_on_floor():
		return jump_state
	if Input.is_action_just_pressed("Down") and parent.is_on_floor():
		return crouch_state
	if Input.is_action_just_pressed("Left") or Input.is_action_just_pressed("Right"):
		return walk_state
	return null

func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta
	parent.velocity.x = move_toward(parent.velocity.x, , delta)
	parent.move_and_slide()
	
	if !parent.is_on_floor():
		return fall_state
	return null
