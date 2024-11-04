class_name CrouchingPlayerState 

extends PlayerMovementState

@export var SPEED : float = 3.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export_range(1, 6, 0.1) var CROUCH_SPEED : float = 4.0

@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D

func enter() -> void:
	ANIMATION.play("Crouching", -1.0, CROUCH_SPEED)

func update(delta):
	PLAYER.UpdateGravity(delta)
	PLAYER.UpdateInput(SPEED, ACCELERATION, DECELERATION)
	PLAYER.UpdateVelocity()
	
	if Input.is_action_just_released("crouch"):
		Uncrouch()
	
	#if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		#transition.emit("JumpingPlayerState")

func Uncrouch():
	if CROUCH_SHAPECAST.is_colliding() == false and Input.is_action_pressed("crouch") == false:
		ANIMATION.play("Crouching", -1.0, -CROUCH_SPEED * 1.5, true)
		if ANIMATION.is_playing():
			await ANIMATION.animation_finished
		transition.emit("IdlePlayerState")
	
	elif CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		Uncrouch()
