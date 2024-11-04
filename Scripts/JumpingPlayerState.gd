class_name JumpingPlayerState

extends PlayerMovementState

@export var SPEED : float = 6.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var JUMP_VELOCITY : float = 4.5
@export_range(0.5, 1.0, 0.01) var INPUT_MULTIPLIER : float = 0.85

func enter() -> void:
	PLAYER.velocity.y += JUMP_VELOCITY
	ANIMATION.play("JumpStart")

func update(delta):
	PLAYER.UpdateGravity(delta)
	# Input multiplier allows movement in air. In otherwords it gives the player the ability to control
	# rotation while mid air. This is popular in many FPS games and is known as "Air Strafing"
	PLAYER.UpdateInput(SPEED * INPUT_MULTIPLIER, ACCELERATION, DECELERATION)
	PLAYER.UpdateVelocity()
	
	if PLAYER.is_on_floor():
		ANIMATION.play("JumpEnd")
		transition.emit("IdlePlayerState")
