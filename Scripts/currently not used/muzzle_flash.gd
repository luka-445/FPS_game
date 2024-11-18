extends Node3D


@export var weapon : WeaponsManager
@export var flashTime : float = 0.05

@export var light : OmniLight3D
@export var particles : GPUParticles3D


func _ready() -> void:
	EventBus.weaponFired.connect(addMuzzleFlash)

func addMuzzleFlash() -> void:
	light.visible = true
	#particles.emitting = true
	await get_tree().create_timer(flashTime).timeout
	light.visible = false
	
	
