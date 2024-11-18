class_name WeaponsManager

extends Node3D

signal weaponFired

@export var weaponResourcesAux: Array[Weapon]
@export var startWeapons: Array[String]
var currentWeapon : Weapon
var isAttacking : bool = false
var weaponDict = {} # Dictionary of all weapon resources.
var weaponStack = []

var bulletDecal = load("res://Scenes/bullet_hole.tscn")
var bulletTracer = load("res://Scenes/bullet_tracer.tscn")
var bulletInstance

var bullets = 30
var timeToFire : float
var canFire : bool = true

# weapon variables
@onready var ak47_barrel = $AK47/akMeshModel/ak_barrel
@onready var m9Bayonet = $M9_bayonet
@onready var m1911_barrel = $m1911_handgun/m1911_barrel
var shootingCooldown : float = 60.0
var anim
var barrel
# weapon animation players
@onready var weaponSwitching = $weaponSwitching
@onready var ak47_animPlayer = $AK47/AnimationPlayer
@onready var m9Bayonet_animPlayer = $M9_bayonet/AnimationPlayer
@onready var m1911Handgun_animPlayer = $m1911_handgun/AnimationPlayer


var hitRayStartPosition : Vector3 
var endRayStartPosition : Vector3 

var currentWeaponID : int = -1
var canShoot = true
enum _weapons {
	PRIMARY,
	SECONDARY,
	MELEE
}


func _ready():
	InitWeapon()
	if Global.player != null:
		hitRayStartPosition = Global.player.hitRay.position
		endRayStartPosition = Global.player.endOfHitRay.position

func _input(event):
	if event.is_action_pressed("attack") and currentWeapon.autoFire == true and canShoot:
		isAttacking = true

	if event.is_action_released("attack") and currentWeapon.autoFire == true:
		isAttacking = false
	
	if event.is_action_released("attack") and canShoot and currentWeapon.meleeWeapon == true:
		isAttacking = true
		meleeAttack()
	
	if event.is_action_pressed("attack") and currentWeapon.semiAuto == true and canShoot and canFire:
		Shoot_semiAuto()
		
	# pull out primary weapon.
	if event.is_action_pressed("primaryWeapon"):
		_raiseWeapon(_weapons.PRIMARY)
	
	# pull out secondary weapon
	if event.is_action_pressed("secondaryWeapon"):
		_raiseWeapon(_weapons.SECONDARY)
	
	# pull out melee weapon
	if event.is_action_pressed("meleeWeapon"):
		_raiseWeapon(_weapons.MELEE)

func _process(_delta):
	if Global.debug.visible:
		Global.debug.AddProperty("BulletCount", bullets,3)
	
	if isAttacking == true:
		Shoot()
func _physics_process(delta):
	if Global.player.hitRay.position != hitRayStartPosition and isAttacking == false:
		Global.player.hitRay.position = lerp(Global.player.hitRay.position, 
		hitRayStartPosition, currentWeapon.recoilResetSpeed * delta)

	if Global.player.endOfHitRay.position != endRayStartPosition and isAttacking == false:
		Global.player.hitRay.position = lerp(Global.player.hitRay.position,
		 hitRayStartPosition, currentWeapon.recoilResetSpeed * delta)

func InitWeapon():
	# Create dictionary for reference to weapons.
	for weapon in weaponResourcesAux:
		weaponDict[weapon.weaponName] = weapon
	
	# Insert starting weapons into current weapon stack.
	for i in startWeapons:
		weaponStack.push_back(i)
	
	anim = ak47_animPlayer
	barrel = ak47_barrel
	currentWeapon = weaponDict[weaponStack[_weapons.PRIMARY]]
	currentWeaponID = _weapons.PRIMARY
	weaponSwitching.play("raise_ar")
	await get_tree().create_timer(0.4).timeout

func _lowerWeapon():
	match currentWeaponID:
		_weapons.PRIMARY:
			weaponSwitching.play("lower_ar")
		_weapons.SECONDARY:
			weaponSwitching.play("lower_pistol")
		_weapons.MELEE:
			weaponSwitching.play("lower_knife")

func _raiseWeapon(newWeapon):
	if currentWeaponID != newWeapon:
		canShoot = false
		_lowerWeapon()
		currentWeaponID = newWeapon
		await get_tree().create_timer(0.4).timeout
		match currentWeaponID:
			_weapons.PRIMARY:
				weaponSwitching.play("raise_ar")
				anim = ak47_animPlayer
				barrel = ak47_barrel
			_weapons.SECONDARY:
				weaponSwitching.play("raise_pistol")
				anim = m1911Handgun_animPlayer
				barrel = m1911_barrel
			_weapons.MELEE:
				weaponSwitching.play("raise_knife")
				anim = m9Bayonet_animPlayer
		currentWeapon = weaponDict[weaponStack[currentWeaponID]]
		bullets = currentWeapon.shotCount
		canShoot = true


 #Attack: function creates a raycast when attack input is read.

func Shoot() -> void:
	if bullets == 0: 
		bullets = 30
	
	if !anim.is_playing():
		weaponFired.emit()
		bulletInstance = bulletTracer.instantiate()
		bullets -= 1
		anim.play(currentWeapon.animationFire)
		
		if Global.player.hitRay.is_colliding():
			bulletInstance.init(barrel.global_position, Global.player.hitRay.get_collision_point())
			get_parent().get_parent().add_child(bulletInstance)
			if Global.player.hitRay.get_collider().is_in_group("enemy"):
				Global.player.hitRay.get_collider().hit()
				bulletInstance.triggerParticles(Global.player.hitRay.get_collision_point(), 
				barrel.global_position, true)
			else:
				bulletInstance.triggerParticles(Global.player.hitRay.get_collision_point(), 
				barrel.global_position, false)
		else:
			bulletInstance.init(barrel.global_position, Global.player.endOfHitRay.global_position)
			get_parent().get_parent().add_child(bulletInstance)

func Shoot_semiAuto():
	if bullets == 0: 
		bullets = 30
	
	
	if !anim.is_playing():
		bullets -= 1
		anim.play(currentWeapon.animationFire)
	
		weaponFired.emit()
		bulletInstance = bulletTracer.instantiate()
		if Global.player.hitRay.is_colliding():
			bulletInstance.init(barrel.global_position, Global.player.hitRay.get_collision_point())
			get_parent().get_parent().add_child(bulletInstance)
			if Global.player.hitRay.get_collider().is_in_group("enemy"):
				Global.player.hitRay.get_collider().hit()
				bulletInstance.triggerParticles(Global.player.hitRay.get_collision_point(), 
				barrel.global_position, true)
			else:
				bulletInstance.triggerParticles(Global.player.hitRay.get_collision_point(), 
				barrel.global_position, false)
		else:
			bulletInstance.init(barrel.global_position, Global.player.endOfHitRay.global_position)
			get_parent().get_parent().add_child(bulletInstance)
	

func addRecoil() -> void:
	var spread = currentWeapon.recoilSpread
	var randomSpreadRay = Vector3(randf_range(-spread, spread), randf_range(-spread, spread), -1)
	var randomSpreadEndRay = randomSpreadRay
	randomSpreadEndRay.z = -101
	Global.player.hitRay.position = randomSpreadRay
	Global.player.endOfHitRay.position = randomSpreadEndRay
	
	

func meleeAttack():
	anim.play(currentWeapon.animationFire)
# bulletHole: This function spawns bullet decal when raycast collides with world object.
# Parameters:
# position : Vector3; intersection of raycast and physics body it collided with,
#                     in other words the position where the bullet hole needs to be spawned.
# normal : Vector3;   The normal of the raycast vector, each raycast has a normal property
#                     the normal dictates the perpendicular aspect, needed for properly rotating 
#                     the bullet hole decal. 
func bulletHole(pos : Vector3, normal : Vector3 ) -> void:

	# Create instance of bullet hole scene and add it to current scene root.
	var instance = bulletDecal.instantiate()
	get_tree().root.add_child(instance)
	
	# Set position of decal to where raycast hit.
	instance.global_position = position
	
	# Rotate bullet decal if surface is not already pointing up.
	#instance.look_at(instance.global_transform.origin + normal, Vector3.UP)
	#if normal != Vector3.UP and normal != Vector3.DOWN:
		#instance.rotate_object_local(Vector3(1, 0, 0), 90)
	
	# Create timer for how long bullet decal should stay, then fade out bullet hole before deleting it
	# from the scene
	await get_tree().create_timer(3).timeout
	var fade = get_tree().create_tween()
	fade.tween_property(instance, "modulate:a", 0, 1.5)
	await get_tree().create_timer(1.5).timeout
	instance.queue_free()
	
func _on_weapon_fired():
	addRecoil()
