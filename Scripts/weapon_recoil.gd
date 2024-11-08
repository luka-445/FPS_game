class_name WeaponRecoil
extends Node3D


@export var recoil_amount : Vector3
@export var snap_amount : float
@export var speed : float

@export var weapon : WeaponsManager


var current_rotation : Vector3
var target_rotation : Vector3

func _ready() -> void:
	
	weapon.weaponFired.connect(addRecoil)

func _process(delta : float) -> void:
	target_rotation = lerp(target_rotation, Vector3.ZERO, speed * delta)
	current_rotation = lerp(current_rotation, target_rotation, snap_amount * delta)
	basis = Quaternion.from_euler(current_rotation)

func addRecoil() -> void:
	target_rotation += Vector3(recoil_amount.x, randf_range(-recoil_amount.y, recoil_amount.y),0)
