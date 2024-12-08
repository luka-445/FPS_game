class_name WeaponsSystems

extends Node3D

signal weaponFired

@export var weaponResourcesAux: Array[Weapon]
@export var startWeapons: Array[String]
var currentWeapon : Weapon
var isAttacking : bool = false
var weaponDict = {} # Dictionary of all weapon resources.
var weaponStack = [] #current weapons array.


var bulletTracer = load("res://Scenes/bullet_tracer.tscn")
var bulletInstance

var canFire : bool = true

# weapon variables
@onready var ak47_barrel = $AK47/akMeshModel/ak_barrel

@onready var m1911_barrel = $m1911_handgun/m1911_barrel
var anim
var barrel
# weapon animation players
@onready var weaponSwitching = $weaponSwitching
@onready var ak47_animPlayer = $AK47/AnimationPlayer
@onready var m1911Handgun_animPlayer = $m1911_handgun/AnimationPlayer


var hitRayStartPosition : Vector3 
var endRayStartPosition : Vector3 

var currentWeaponID : int = -1
var canShoot = true
enum _weapons {
	PRIMARY,
	SECONDARY
}


func _ready():
	InitWeapon()
	if Global.player != null:
		hitRayStartPosition = Global.player.hitRay.position
		endRayStartPosition = Global.player.endOfHitRay.position

func _input(event):
	# input for automatic weapons.
	if event.is_action_pressed("attack") and currentWeapon.autoFire == true and canShoot:
		isAttacking = true

	if event.is_action_released("attack") and currentWeapon.autoFire == true:
		isAttacking = false
	
	# Input for semi automatic weapons.
	if event.is_action_pressed("attack") and currentWeapon.semiAuto == true and canShoot and canFire:
		Shoot_semiAuto()
		
	# pull out primary weapon.
	if event.is_action_pressed("primaryWeapon"):
		_raiseWeapon(_weapons.PRIMARY)
	
	# pull out secondary weapon
	if event.is_action_pressed("secondaryWeapon"):
		_raiseWeapon(_weapons.SECONDARY)
	
func _process(_delta):
	if isAttacking == true:
		Shoot()

func _physics_process(delta):
	# Reset recoil
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

# play lower animation
func _lowerWeapon():
	match currentWeaponID:
		_weapons.PRIMARY:
			weaponSwitching.play("lower_ar")
		_weapons.SECONDARY:
			weaponSwitching.play("lower_pistol")

# play raise animaton
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
				
		currentWeapon = weaponDict[weaponStack[currentWeaponID]]

		canShoot = true


 #Attack: function creates a raycast when attack input is read.

func Shoot() -> void:
	
	if !anim.is_playing():
		weaponFired.emit()
		bulletInstance = bulletTracer.instantiate()
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
	
	if !anim.is_playing():
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
	

func _on_weapon_fired():
	addRecoil()
