extends CharacterBody3D

@export var SPEED_DEFAULT : float = 5.0
@export var SPEED_CROUCHING : float =  2.0
@export var JUMP_VELOCITY : float = 4.5
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TOGGLE_CROUCH : bool = true
@export_range(5, 10, 0.1) var CROUCH_SPEED : float = 7.0
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATION_PLAYER : AnimationPlayer
@export var CROUCH_SHAPECAST : ShapeCast3D

var mouseInput : bool
var rotationInput : float
var tiltInput : float
var mouseRotation : Vector3
var playerRotation : Vector3
var cameraRotation : Vector3
var speed : float

var isCrouching : bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	# Set mouse input to capture in screen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Add exception to crouch shapecast to exlude CharacterBody3D node.
	CROUCH_SHAPECAST.add_exception($".")
	
	# Set default speed
	speed = SPEED_DEFAULT
	
func _input(event):
	# If Exit key (mapped to escape) is pressed, quit out.
	if event.is_action_pressed("exit"):
		get_tree().quit()
	
	if event.is_action_pressed("crouch") and is_on_floor():
		ToggleCrouch()
	
	if event.is_action_pressed("crouch") and is_on_floor() and isCrouching == false and TOGGLE_CROUCH == false:
		crouching(true)
	
	if event.is_action_released("crouch") and TOGGLE_CROUCH == false:
		if CROUCH_SHAPECAST.is_colliding() == false:
			crouching(false)
		elif CROUCH_SHAPECAST.is_colliding() == true:
			UncrouchCheck()
		

func _unhandled_input(event):
	mouseInput = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if mouseInput:
		rotationInput = -event.relative.x * MOUSE_SENSITIVITY
		tiltInput = -event.relative.y * MOUSE_SENSITIVITY

func UpdateCamera(delta):
	# Get mouse x and y rotation, and clamp x to tilt limits.
	mouseRotation.x += tiltInput * delta
	clamp(mouseRotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	mouseRotation.y += rotationInput * delta
	
	# Isolate x and y rotations of mouse
	playerRotation = Vector3(0.0, mouseRotation.y, 0.0)
	cameraRotation = Vector3(mouseRotation.x, 0.0, 0.0)
	
	# Rotate Camera left and right
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(cameraRotation)
	CAMERA_CONTROLLER.rotation.z = 0
	
	# Tilt Camera up and down.
	global_transform.basis = Basis.from_euler(playerRotation)
	
	tiltInput = 0
	rotationInput = 0
	
func _physics_process(delta):
	
	# Add movement speed to debug panel
	Global.debug.AddProperty("MovementSpeed", speed, 2)
	Global.debug.AddProperty("MouseRotation", mouseRotation, 3)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	UpdateCamera(delta)
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and isCrouching == false:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func ToggleCrouch():
	if isCrouching == true and CROUCH_SHAPECAST.is_colliding() == false:
		crouching(false)
	elif isCrouching == false:
		crouching(true)
	
func crouching(state : bool):
	match state:
		true:
			ANIMATION_PLAYER.play("Crouching", 0, CROUCH_SPEED)
			SetMovementSpeed("crouching")
		false:
			ANIMATION_PLAYER.play("Crouching", 0, -CROUCH_SPEED, true)
			SetMovementSpeed("default")

func UncrouchCheck():
	if CROUCH_SHAPECAST.is_colliding() == false:
		crouching(false)
	elif CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		UncrouchCheck()
	
func SetMovementSpeed(state : String):
	match state:
		"default":
			speed = SPEED_DEFAULT
		"crouching":
			speed = SPEED_CROUCHING


func _on_animation_player_animation_started(anim_name):
	if anim_name == "Crouching":
		isCrouching = !isCrouching

func testGit():
	pass
