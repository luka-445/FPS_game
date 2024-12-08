class_name Player 

extends CharacterBody3D

# Aim ray variables
@onready var hitRay = %hitRay
@onready var endOfHitRay = %endOfHitRay

# Timers
@onready var healthTimer = $HealthTimer

# UI
@onready var hitTexture = $UserInterface/hitTexture

# Player variables

@export_group("Mouse Settings")
@export var MOUSE_SENSITIVITY : float = 0.4
@export_group("Camera Settings")
@export_subgroup("Camera Tilt Limits")
@export var TILT_UPPER_LIMIT : float = deg_to_rad(90.0)
@export var TILT_LOWER_LIMIT : float = deg_to_rad(-90.0)
@export_subgroup("Camera nodes")
@export var CAMERA_CONTROLLER : Camera3D
@export var VIEWPORT_CAMERA : Camera3D
@export var WEAPON_SUB_VIEWPORT : SubViewport
@export_category("Other")
@export var ANIMATION_PLAYER : AnimationPlayer
const HIT_STAGGER : float = 5.0
const PLAYER_HEALTH : float = 100.0
const HEALING_RATE : float = 1.5
var currentHealth : float = PLAYER_HEALTH
var canHeal : bool = false

# Debug Variables
var lastPosition = Vector3.ZERO
var currentVelocity : Vector3
var currentSpeed : String

# Update input Variables
var mouseInput : bool
var rotationInput : float
var tiltInput : float
var mouseMovement : Vector2
# Update camera variables
var mouseRotation : Vector2
var playerRotation : Vector3
var cameraRotation : Vector3
var swayMin = Vector2(-20, -20)
var swayMax = Vector2(20, 20)



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")



	
func _ready():
	# Set global variable to this script
	Global.player = self
	# Set mouse input to capture in screen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	WEAPON_SUB_VIEWPORT.size = DisplayServer.window_get_size()
	SettingsSignalBus.on_mouse_sensitivity_changed.connect(load_data)

func load_data(value : float):
	MOUSE_SENSITIVITY = value

func _input(event):
	
	# unlock mouse or caputre mouse, these are only meant for the developer
	if event.is_action_pressed("unlockMouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("captureMouse"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	

# Get mouse input.
func _unhandled_input(event):
	mouseInput = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if mouseInput:
		rotationInput = -event.relative.x * MOUSE_SENSITIVITY 
		tiltInput = -event.relative.y * MOUSE_SENSITIVITY 
		mouseMovement = event.relative
		mouseMovement = mouseMovement.clamp(swayMin, swayMax)
		

# Update the camera
func UpdateCamera(delta):
	# Set weapon viewport camera to same position as main camera.
	VIEWPORT_CAMERA.global_transform = CAMERA_CONTROLLER.global_transform
	
	# Get mouse x and y rotation, and clamp x to tilt limits.
	mouseRotation.x += tiltInput * delta
	mouseRotation.x = clamp(mouseRotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	mouseRotation.y += rotationInput * delta
	
	# Isolate x and y rotations of mouse
	playerRotation = Vector3(0.0, mouseRotation.y, 0.0)
	cameraRotation = Vector3(mouseRotation.x, 0.0, 0.0)
	
	# Tilt Camera up and down along the x axis. 
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(cameraRotation)
	# Rotate player left and right along the y axis
	global_transform.basis = Basis.from_euler(playerRotation)
	
	# Set camerea z rotation to z, we don't want to rotate along this axis because of euler angles 
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	# Reset inputs for next update.
	rotationInput = 0.0
	tiltInput = 0.0

func _process(delta):
	# Add movement speed to debug panel
	if Global.debug.visible:
		Global.debug.AddProperty("Health", currentHealth, 1)
		## Calculate current speed.
		#currentVelocity = (position - lastPosition) / delta
		#lastPosition = position
		#currentSpeed = "%.2f" % Vector3.ZERO.distance_to(currentVelocity)
		#Global.debug.AddProperty("MovementSpeed", currentSpeed , 5)
		#Global.debug.AddProperty("MouseRotation", mouseRotation, 6)
	
	# Heal the player on cooldown timeout and if not already at max health
	if currentHealth < PLAYER_HEALTH and canHeal == true:
		_healPlayer()
	
	updateHitTexture()

# Call updateCamera in physics process instead of process this is because
# process is frame dependent and does not run at a fixed framerate
# Physics need to be updated at a fixed rate otherwise weird things happen
func _physics_process(delta):
	UpdateCamera(delta)
	VIEWPORT_CAMERA.sway(mouseMovement)
	
# Updates gravity.
func UpdateGravity(delta) -> void:
	velocity.y -= gravity * delta

# Updates keyboard direction inputs.
func UpdateInput(speed: float, acceleration: float, deceleration: float) -> void:
	# Get input direction
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
	
	# Create direction transform vector.
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# If there is a direction input accelerate in that direction, otherwise decelerate to 0
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration) 
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration) 
		velocity.z = move_toward(velocity.z, 0, deceleration)

# Moves the player.
func UpdateVelocity() -> void:
	move_and_slide()

# Detects if player has been hit and decrements health
func hit(dir, damage):
	healthTimer.start()
	canHeal = false
	currentHealth -= damage
	velocity += dir * HIT_STAGGER

# Heals the player
func _healPlayer():
	# Gradually heal the player
	currentHealth = move_toward(currentHealth, PLAYER_HEALTH, HEALING_RATE)

# start healing on timeout
func _on_health_timer_timeout():
	canHeal = true

func updateHitTexture():
	var tween = create_tween()
	var ratio = currentHealth / PLAYER_HEALTH
	var opacity = lerp(1.0, 0.0, ratio)
	tween.tween_property(hitTexture, "self_modulate:a", opacity, 1.0)

	
