extends Area3D

@export var damage : float = 1.0

signal body_part_hit(damage)


func hit():
	emit_signal("body_part_hit", damage)
