class_name Player 

extends CharacterBody3D

#@export var ACCELERATION : float = 0.1
#@export var DECELERATION : float = 0.25
#@export var SPEED_DEFAULT : float = 5.0
#@export var SPEED_SPRINT : float = 7.0
#@export var JUMP_VELOCITY : float = 4.5
@export var MOUSE_SENSITIVITY : float = 0.4
#@export_range(5, 10, 0.1) var CROUCH_SPEED : float = 7.0
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATION_PLAYER : AnimationPlayer
@export var CROUCH_SHAPECAST : ShapeCast3D

var lastPosition = Vector3.ZERO
var currentVelocity : Vector3
var currentSpeed : String
var mouseInput : bool
var rotationInput : float
var tiltInput : float
var mouseRotation : Vector3
var playerRotation : Vector3
var cameraRotation : Vector3
#var _speed : float

var isCrouching : bool = false
var isFullscreen : bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Global.player = self
	# Set mouse input to capture in screen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Add exception to crouch shapecast to exlude CharacterBody3D node.
	CROUCH_SHAPECAST.add_exception($".")

func _input(event):
	if event.is_action_pressed("fullScreen") and isFullscreen == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		isFullscreen != isFullscreen
	
	# If Exit key (mapped to escape) is pressed, quit out.
	if event.is_action_pressed("exit"):
		get_tree().quit()
	

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
	
	rotationInput = 0.0
	tiltInput = 0.0
	

func _process(delta):
	# Add movement speed to debug panel
	Global.debug.AddProperty("MovementSpeed", currentSpeed , 2)
	Global.debug.AddProperty("MouseRotation", mouseRotation, 3)
	
	if Global.debug.visible:
		currentVelocity = (position - lastPosition) / delta
		lastPosition = position
		currentSpeed = "%.2f" % Vector3.ZERO.distance_to(currentVelocity)
		
func _physics_process(delta):
	UpdateCamera(delta)

func UpdateGravity(delta) -> void:
	velocity.y -= gravity * delta

func UpdateInput(speed: float, acceleration: float, deceleration: float) -> void:
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration) 
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration) 
		velocity.z = move_toward(velocity.z, 0, deceleration)
		
func UpdateVelocity() -> void:
	move_and_slide()
