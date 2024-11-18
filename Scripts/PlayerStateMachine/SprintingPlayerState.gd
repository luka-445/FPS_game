class_name SprintingPlayerState 

extends PlayerMovementState

@export var SPEED : float = 7.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var TOP_ANIMATION_SPEED : float = 1.6

func enter() -> void:
	if ANIMATION.is_playing() and ANIMATION.current_animation == "JumpEnd":
		await ANIMATION.animation_finished
		ANIMATION.play("Sprinting", 0.5, 1.0)
	else:
		ANIMATION.play("Sprinting", 0.5, 1.0)
	

func exit() -> void:
	ANIMATION.speed_scale = 1.0

func update(delta) -> void:
	PLAYER.UpdateGravity(delta)
	PLAYER.UpdateInput(SPEED, ACCELERATION, DECELERATION)
	PLAYER.UpdateVelocity()
	
	SetAnimationSpeed(PLAYER.velocity.length())
	
	if Input.is_action_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
		
	if Input.is_action_just_released("sprint"):
		transition.emit("WalkingPlayerState")
	
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
	
	if PLAYER.velocity.y > -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")

func SetAnimationSpeed(spd):
	var alpha = remap(spd, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIMATION_SPEED, alpha)
	
