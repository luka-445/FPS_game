class_name WeaponRecoil
extends Node3D


var recoil_amount : Vector3
var snap_amount : float
var speed : float

var aimcone : float
@export var weapon : WeaponsManager



var current_rotation : Vector3
var target_rotation : Vector3

func _ready() -> void:
	Global.recoil = self
	EventBus.weaponFired.connect(addRecoil)
	

func _process(delta : float) -> void:
	if weapon.currentWeaponAmmo > 0:
		aimcone = 0.1 / weapon.currentWeaponAmmo
	else: 
		aimcone = 1
	target_rotation = lerp(target_rotation, Vector3.ZERO, speed * delta)
	current_rotation = lerp(current_rotation, target_rotation, snap_amount * delta)
	basis = Quaternion.from_euler(current_rotation)

func addRecoil() -> void:
	target_rotation += Vector3(randf_range(-recoil_amount.x, recoil_amount.x) * 4.0,
	randf_range(-recoil_amount.y, recoil_amount.y) * 4.0,
	randf_range(-recoil_amount.z, recoil_amount.z))
	
	
