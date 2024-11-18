class_name WeaponRecoil
extends Node3D


var recoil_amount : Vector3
var snap_amount : float
var speed : float

@onready var hitRay = %hitRay
@onready var endOfHitRay = %endOfHitRay


var current_rotation : Vector3
var target_rotation : Vector3

var maxRecoil : int = 1

func _ready() -> void:
	Global.recoil = self
	#EventBus.weaponFired.connect(addRecoil)
	

func _process(delta : float) -> void:
	pass
	#target_rotation = lerp(target_rotation, Vector3.ZERO, speed * delta)
	#current_rotation = lerp(current_rotation, target_rotation, snap_amount * delta)
	#basis = Quaternion.from_euler(current_rotation)


	
