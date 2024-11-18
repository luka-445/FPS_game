class_name ViewModel

extends Camera3D

@export var WEAPON_RIG : Node3D
@export var SWAY_STRENGTH : float = 0.0002

var alpha : float = 5.0


func _process(delta):
	WEAPON_RIG.position.x = lerp(WEAPON_RIG.position.x, 0.0, alpha * delta)
	WEAPON_RIG.position.y = lerp(WEAPON_RIG.position.y, 0.0, alpha * delta)
	
# function to move weapon rig from left to right when moving.
func sway(sway_amount : Vector2):
	WEAPON_RIG.position.x -= sway_amount.x * SWAY_STRENGTH 
	WEAPON_RIG.position.y += sway_amount.y * SWAY_STRENGTH 
