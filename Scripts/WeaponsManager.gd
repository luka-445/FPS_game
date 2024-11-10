class_name WeaponsManager

extends Node3D

signal weaponFired
@onready var ak_muzzle_flash = %ak_muzzle_flash
@onready var m1911_muzzle_flash = %ak_muzzle_flash


@export var ANIMATION_PLAYER : AnimationPlayer
var weaponIndicator : int = 0 # index of weapon in weaponStack.
var currentWeapon : Weapon
var currentWeaponTotalAmmo : int
var currentWeaponAmmo : int
var _nextWeapon : String
var isAttacking : bool = false
var bulletDecal = preload("res://Scenes/bullet_hole.tscn")
var weaponDict = {} # Dictionary of all weapon resources.
# array of weapons held by current player.
# array index 0 holds primary weapon.
# index 1 holds secondary weapon.
# index 2 holds melee weapon.
var weaponStack = []
var muzzleFlash = preload("res://Scenes/muzzle_flash.tscn")
# auxilary array used to build dictionary.
@export var weaponResourcesAux: Array[Weapon]

# holds starting weapons.
# this is in case more weapons are added later on.
# makes this system modular and expandable.
@export var startWeapons: Array[String]

var bullets = 30
var timeToFire : float
var nextTimeToFire : float = 0

func _ready():
	
	# Initilizes start of weapon state machine.
	InitWeapon()
	
	

func _input(event):
	if event.is_action_pressed("attack"):
		isAttacking = true
		Attack()
	
	if event.is_action_released("attack"):
		isAttacking = false
		
	
	
	# pull out primary weapon.
	if event.is_action_pressed("primaryWeapon"):
		exit(weaponStack[0])
	
	# pull out secondary weapon
	if event.is_action_pressed("secondaryWeapon"):
		exit(weaponStack[1])
	
	# pull out melee weapon
	if event.is_action_pressed("meleeWeapon"):
		exit(weaponStack[2])

func _process(delta):
	nextTimeToFire = delta + 1 / currentWeapon.fireRate
	
func _physics_process(delta):
	pass

func InitWeapon():
	
	# Create dictionary for reference to weapons.
	for weapon in weaponResourcesAux:
		weaponDict[weapon.weaponName] = weapon
	
	# Insert starting weapons into current weapon stack.
	for i in startWeapons:
		weaponStack.push_back(i)
	
	# set current weapon to frist weapon held by player in weapon stack and call enter.
	currentWeapon = weaponDict[weaponStack[0]]
	enter()


# call when entering into next weapon.
func enter():
	# Play pullout animation
	ANIMATION_PLAYER.queue(currentWeapon.animationPullout)
	
	# Set ammo count
	currentWeaponAmmo = currentWeapon.shotCount
	currentWeaponTotalAmmo = currentWeapon.shotCount
	timeToFire = 1 / (currentWeapon.fireRate / 60)
	
	
	Global.debug.AddProperty("Ammo", currentWeaponTotalAmmo, 4)
	
	# set weapon recoil amount
	Global.recoil.recoil_amount = currentWeapon.recoilAmount
	Global.recoil.snap_amount = currentWeapon.snapAmount
	Global.recoil.speed = currentWeapon.speed
	Global.debug.AddProperty("recoilAmount", currentWeapon.recoilAmount, 5)
	Global.debug.AddProperty("snapAmount", currentWeapon.snapAmount, 6)
	Global.debug.AddProperty("recoil_speed", currentWeapon.speed, 7)
	
	# set weapon recoil physics amount
	Global.recoil_physics.recoil_amount = currentWeapon.recoilAmountPhysics
	Global.recoil_physics.snap_amount = currentWeapon.snapAmountPhysics
	Global.recoil_physics.speed = currentWeapon.speedPhysics
	
	# Set weapon muzzle flash position
	
# Call exit before changing weapon.
func exit(nextWeapon):
	# if next is current than don't switch.
	if nextWeapon == currentWeapon.weaponName:
		return
	
	if ANIMATION_PLAYER.get_current_animation() != currentWeapon.animationPutaway:
		ANIMATION_PLAYER.play(currentWeapon.animationPutaway)
		_nextWeapon = nextWeapon

# Updates current weapon.
func ChangeWeapon(weaponName):
	# update current weapon to new weapon.
	currentWeapon = weaponDict[weaponName]
	# Reset next Weapon to empty string.
	_nextWeapon = ""
	# Enter new weapon.
	enter()

# sends signal when current animation is finished playing.
func _on_animation_player_animation_finished(anim_name):
	# when signal triggered, if anim_name == animationPutaway then change weapon.
	if anim_name == currentWeapon.animationPutaway:
		ChangeWeapon(_nextWeapon)
	
	if anim_name == currentWeapon.animationFire and currentWeapon.autoFire == true:
		if isAttacking:
			await get_tree().create_timer(nextTimeToFire).timeout
			Attack()
	

# Attack: function creates a raycast when attack input is read.
func Attack() -> void:
	Global.debug.AddProperty("Ammo", currentWeaponAmmo, 4)
	
	if currentWeaponAmmo <= 0:
		print("gun empty")
		currentWeaponAmmo = currentWeaponTotalAmmo
		Global.debug.AddProperty("Ammo", currentWeaponAmmo, 4)
	
	ANIMATION_PLAYER.play(currentWeapon.animationFire)
	var flash = muzzleFlash.instantiate()
	if currentWeapon.weaponName == "AK-47":
		get_node("RecoilPosition/muzzle_flash_position/ak_muzzle_flash").add_child(flash)
		flash.position = ak_muzzle_flash.position
	
	if currentWeapon.weaponName == "1911":
		get_node("RecoilPosition/muzzle_flash_position/m1911_muzzle_flash").add_child(flash)
		flash.position = m1911_muzzle_flash.position
	
	currentWeaponAmmo -= 1
	EventBus.weaponFired.emit()
	# get fps controller camera reference.
	var camera = Global.player.CAMERA_RECOIL
	# Get space state of camera.
	var spaceState = get_world_3d().direct_space_state
	# get origin or center of screen
	var centerOfScreen = get_viewport().size / 2
	# get origin point for array, i.e starting point of raycast.
	var origin = camera.project_ray_origin(centerOfScreen)
	# get endpoint of raycast.
	var end = origin + camera.project_ray_normal(centerOfScreen) * currentWeapon.range
	# create raycast.
	var query =  PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	var result = spaceState.intersect_ray(query)
	if result and !currentWeapon.meleeWeapon:
		bulletHole(result.get("position"), result.get("normal"))

# bulletHole: This function spawns bullet decal when raycast collides with world object.
# Parameters:
# position : Vector3; intersection of raycast and physics body it collided with,
#                     in other words the position where the bullet hole needs to be spawned.
# normal : Vector3;   The normal of the raycast vector, each raycast has a normal property
#                     the normal dictates the perpendicular aspect, needed for properly rotating 
#                     the bullet hole decal. 
func bulletHole(position : Vector3, normal : Vector3 ) -> void:

	# Create instance of bullet hole scene and add it to current scene root.
	var instance = bulletDecal.instantiate()
	get_tree().root.add_child(instance)
	
	# Set position of decal to where raycast hit.
	instance.global_position = position
	
	# Rotate bullet decal if surface is not already pointing up.
	instance.look_at(instance.global_transform.origin + normal, Vector3.UP)
	if normal != Vector3.UP and normal != Vector3.DOWN:
		instance.rotate_object_local(Vector3(1, 0, 0), 90)
	
	# Create timer for how long bullet decal should stay, then fade out bullet hole before deleting it
	# from the scene
	await get_tree().create_timer(3).timeout
	var fade = get_tree().create_tween()
	fade.tween_property(instance, "modulate:a", 0, 1.5)
	await get_tree().create_timer(1.5).timeout
	instance.queue_free()

func knifeLine(position : Vector3, normal : Vector3 ) -> void:
	pass
