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
	SetAnimationSpeed(PLAYER.velocity.length())
		
	if Input.is_action_just_released("sprint"):
		transition.emit("WalkingPlayerState")
	
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")

func physics_update(delta):
	PLAYER.UpdateGravity(delta)
	PLAYER.UpdateInput(SPEED, ACCELERATION, DECELERATION)
	PLAYER.UpdateVelocity()

func SetAnimationSpeed(spd):
	var alpha = remap(spd, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIMATION_SPEED, alpha)
	
