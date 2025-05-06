class_name Player
extends CharacterBody2D

@onready var animations = $Animations
@onready var state_manager = $"State Manager"

func _ready() -> void:
	# Initialize the state manager, passing a reference of the player to the states,
	# that way they can move and react acordingly
	state_manager.init(self)

func _unhandled_input(_event: InputEvent) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

func _process(_delta: float) -> void:
	pass
