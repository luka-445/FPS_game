class_name FallingPlayerState 

extends PlayerMovementState

@export var SPEED : float = 5.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25

func enter() -> void:
	ANIMATION.pause()

func update(delta : float) -> void:
	PLAYER.UpdateGravity(delta)
	PLAYER.UpdateInput(SPEED, ACCELERATION, DECELERATION)
	PLAYER.UpdateVelocity()
	
	if PLAYER.is_on_floor():
		ANIMATION.play("JumpEnd")
		transition.emit("IdlePlayerState")
