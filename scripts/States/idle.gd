extends State

@export var walk_state : State
@export var jump_state : State
@export var crouch_state : State


# Called when the node enters the scene tree for the first time.
func enter() -> void:
	super()
	print("work")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
